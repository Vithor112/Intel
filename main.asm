.model small
.stack
.data
coluna0 db 0
coluna1 db 0
coluna2 db 0
coluna3 db 0
counter dw 0
total 	dw 0
charsLinha dw 0
handlerInput dw ?
handlerOutput dw ?
booleanError db 0
temp dw ?
tempByte db ?
Ten dw 10
Sixteen dw 16
SixteenByte db 16
pointerChar dw ?
pointerString dw ?
StringTemp db 20 dup(?)
NomeArquivo db 61 dup(?)
NomeSaida db 10 dup(?)
ResultadoString db 16 dup(?)


;================================================================================================================================================
; CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS 
;================================================================================================================================================

msgNomeArquivo  db "Insira o nome do arquivo:",CR,LF,ENDSTRING
msgOpeningError db "Ocorreu um erro durante a abertura do arquivo: ", ENDSTRING
msgCreatingError  db "Ocorreu um erro durante a criação do arquivo: ", ENDSTRING
breakLine db CR,LF,ENDSTRING
fimds db "Arquivo terminou :(", ENDSTRING
extensaoSaida db ".res", ENDSTRING
bytes db "Bytes: ", ENDSTRING
resultado db "Soma:  ", ENDSTRING
spaceStr db " ",ENDSTRING
zeroStr db "0", ENDSTRING



.code
.startup
	lea dx, msgNomeArquivo
	call printf_s
	call scanName
	call openInputFile
	call openOutputFile
	cmp booleanError, 1
	je	termina
	call processaDados
	call resultadoToString
	call printResultado


termina:
.exit


;================================================================================================================================================
; FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS 
;================================================================================================================================================
;; Printa Resultado da soma
	printResultado proc near
		lea dx, bytes
		call printf_s
		mov ax, total
		call printIntDec
		call printn
		lea dx, resultado
		call printf_s
		mov al, coluna0
		call printIntHex
		call printSpace
		mov al, coluna1
		call printIntHex
		call printSpace
		mov al, coluna2
		call printIntHex
		call printSpace
		mov al, coluna3
		call printIntHex
		ret
	printResultado endp

;; Escrevte Resultado no arquivo de saída conforme a especificação
	resultadoToString proc near 
		mov al, coluna0
		call auxResultado
		mov al, coluna1
		call auxResultado
		mov al, coluna2
		call auxResultado
		mov al, coluna3
		call auxResultado
		ret
	resultadoToString endp 

;; Auxiliar do ResultadotoString
	auxResultado proc near
		lea dx, StringTemp
		lea bx, zeroStr
		mov bp,dx
		mov [bp], ENDSTRING
		call appendString
		mov ah, 0
		mov Temp,dx
		mov dx,0
		div SixteenByte
		mov dx,Temp
		mov cl,al
		call hextoChar
		call findEndString
		mov [bp], cl
		inc bp
		mov [bp],ENDSTRING
		call writeInFormat
		mov cl,ah
		call hextoChar
		call findEndString
		dec bp
		mov [bp], cl
		call writeInFormat
		ret
	auxResultado endp
;; Escreve no formato de 8 chars por linha, recebe uma string em dx
	writeInFormat proc near
		push cx
		push dx
		push bx
		mov bx, handlerOutput
		call lengthString
		add charsLinha, cx
		cmp charsLinha, 8
		jne NoChangeLine
		mov charsLinha, 0
		call fwrite
		lea dx, breakLine
		mov cx, 2
NoChangeLine: call fwrite
		pop bx
		pop dx
		pop cx
		ret	
	writeInFormat endp

;; Processa os dados
	processaDados proc near
		mov bx, handlerInput
		mov ch, 0
loopProcessa: call fread
		jc fimArquivoProcessa
		cmp cl,0
		jl loopProcessa
		cmp cl, 7EH
		jg loopProcessa			;; Avalia se é um char ASCII
		mov ax, cx
		lea dx, StringTemp
		call intToHexString
		call writeInFormat

		cmp counter,0
		je zero
		cmp counter,1
		je one
		cmp counter,2
		je two
		cmp counter,3
		add total, 4
		mov counter, 0
		add coluna3, cl
		jmp loopProcessa
zero:	inc counter
		add coluna0, cl
		jmp loopProcessa
one:	inc counter
		add coluna1, cl
		jmp loopProcessa
two:	inc counter
		add coluna2, cl
		jmp loopProcessa
fimArquivoProcessa: mov ax, counter
		add total, ax
		ret
	processaDados endp


;; Lê o nome do arquivo, armazena em NomeArquivo e armazena o nome de saída em nomeSaida
	scanName proc near
		push bx
		push dx
		push ax
		lea dx, NomeArquivo
		call scanf
		lea bx, nomeSaida
		call copyString
		mov dx, bx
		mov ah, SEPARADOR
		mov al, ENDSTRING
		call scanRep
		lea bx, extensaoSaida
		call appendString
		pop ax
		pop dx
		pop bx
		ret	
	scanName endp

;; Abre o Arquivo de entrada no modo de Leitura e salva seu Handler ou seta o booleano de erro caso haja um erro
	openInputFile proc near
		mov al,0 				;; Modo leitura
		lea dx, NomeArquivo
		call fopen
		jc erroInput
		mov handlerInput, ax
		ret 
erroInput: mov booleanError, 1
		ret
	openInputFile endp


;; Abre o Arquivo de saida no modo de Escrita e salva seu Handler ou seta o booleano de erro caso haja um erro
	openOutputFile proc near
		lea dx, nomeSaida
		call fcreate
		jc erroOutput
		mov al, 1 				;; Modo escrita
		call fopen
		jc erroOutput
		mov handlerOutput, ax
		ret 
erroOutput: mov booleanError, 1
		ret
	openOutputFile endp

;; 


;================================================================================================================================================
; IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  
;================================================================================================================================================
;; Dado um algarismo em cl em Hexa converte para String 
	hextoChar proc near
		cmp cl, 0AH
		jl inttoChar 
		sub cl, 0AH
		add cl, "A"
		ret
inttoChar: add cl,"0"
		ret
	hextoChar endp

;; Printa space
	printSpace proc near
		push dx
		lea dx, spaceStr
		call printf_s
		pop dx
		ret
	printSpace endp

;; Printa \n
	printn proc near
		push dx
		lea dx, breakLine
		call printf_s
		pop dx
		ret
	printn endp

LIMIT_SCAN equ 60
; Scanea caracteres do teclado, até um máximo de 60 e os armazena na string apontada por dx
	scanf proc near
		push bx
		push cx
		push ax
		mov bx,dx
		mov cx, LIMIT_SCAN          ;; Limite de Caracteres
		mov ah, 1			  		;; função 1
input:	int 21h				  		;; Chamada função DOS
		cmp al, CR			  		;; Verifica se recebeu um enter como entrada
		jz end_input			  	;; Se sim Termina de receber input
		cmp al, BACKSPACE
		jne charNormal
		cmp bx,dx
		je input
		inc cx
		dec bx
		jmp input
charNormal: mov byte ptr [bx],al			  	;; Se não coloca o char na string
		inc bx;				  		;; E Incrementa seu ponteiro
		loop input			 
end_input:	mov  byte ptr [bx], ENDSTRING	 	;; Coloca o terminador de String no Final da string
		pop ax
		pop cx
		pop bx
		ret
	scanf endp
	
; Printa a string que está no ponteiro dx, a string precisa terminar com $
	printf_s proc near
		push ax
		mov ah,9		
		int 21h
		pop ax
		ret
	printf_s endp

;================================================================================================================================================
; CONVERT FUNCS CONVERT FUNCS CONVERT FUNCS CONVERT FUNCS CONVERT FUNCS CONVERT FUNCS CONVERT FUNCS CONVERT FUNCS CONVERT FUNCS CONVERT FUNCS 
;================================================================================================================================================

;; Converte o inteiro em ax para uma string armazenada em dx
	intToString proc near
		push dx				;; Salva dx
		push bp				;; Salva bp
		push bx				;; Salva bx
		push cx 			;; Salva cx
		push ax				;; Salva ax
		mov bp,dx			
		mov cx,5		
		mov bx,10000		;; Pois 16 bits suportam no máximo um inteiro igual a 65535
		mov dx,0			;; Limpa dx, pois DX:AX/BX
toStringInt:	
		div bx				;; Divisão de 16 bits/16 bits
		add al, "0"			;; Converte o algarismo em char
		mov byte ptr [bp], al		;; Coloca na string 
		inc bp				;; Incrementa ponteiro
		mov ax,bx			;; ax = bx
		mov Temp,dx
		mov dx,0
		div Ten				;; ax /= 10 ( resto vai ser igual a 0 )
		mov dx,Temp
		mov bx,ax			;; bx = ax
		mov ax,dx			;; Transfere o resto para o dividendo 
		mov dx,0			;; Limpa o resto
		loop toStringInt
		mov byte ptr [bp], ENDSTRING ;; Coloca o terminador na Strings
		pop ax			;; Retorna ax
		pop cx			;; Retorna cx
		pop bx			;; Retorna bx
		pop bp			;; Retorna bp
		pop dx			;; Retorna dx
		ret
	intToString endp


	;; Converte o inteiro em ax para uma string representando o int em Hexadecimal armazenada em dx
	intToHexString proc near
		push dx				;; Salva dx
		push bp				;; Salva bp
		push bx				;; Salva bx
		push cx 			;; Salva cx
		push ax				;; Salva ax
		mov bp,dx			
		mov cx,2	
		mov bx,10H		
		mov dx,0			;; Limpa dx, pois DX:AX/BX
toHexStringInt:	
		div bx				;; Divisão de 16 bits/16 bits
		cmp al,10
		jl intHandling
		sub al,10
		add al,"A"
		jmp insertHex
intHandling: add al, "0"			;; Converte o algarismo em char
insertHex: mov byte ptr [bp], al		;; Coloca na string 
		inc bp				;; Incrementa ponteiro
		mov ax,bx			;; ax = bx
		mov Temp,dx
		mov dx,0
		div Sixteen			;; ax /= 16 ( resto vai ser igual a 0 )
		mov dx,Temp
		mov bx,ax			;; bx = ax
		mov ax,dx			;; Transfere o resto para o dividendo 
		mov dx,0			;; Limpa o resto
		loop toHexStringInt
		mov byte ptr [bp], ENDSTRING ;; Coloca o terminador na Strings
		pop ax			;; Retorna ax
		pop cx			;; Retorna cx
		pop bx			;; Retorna bx
		pop bp			;; Retorna bp
		pop dx			;; Retorna dx
		ret
	intToHexString endp

;================================================================================================================================================
; STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS 
;================================================================================================================================================
; Copia String em dx para a string em bx
	copyString proc near
		push bp
		push bx
		mov bp,dx
loopCopy: cmp byte ptr [bp], ENDSTRING
		je fimCopy
		mov al, byte ptr [bp]
		mov byte ptr [bx], al
		inc bp 
		inc bx
		jmp loopCopy
fimCopy: mov byte ptr [bx], ENDSTRING
		pop bx
		pop bp
		ret
	copyString endp 
; Adiciona String em bx no final da string apontada por dx
	appendString proc near
		push ax
		call findEndString
loopssa: mov al, byte ptr [bx]
		mov byte ptr [bp], al
		inc bx
		inc bp
		cmp byte ptr [bx], ENDSTRING
		jne loopssa
		mov byte ptr [bp], ENDSTRING
		pop ax
		ret 
	appendString endp

; Retorna o tamanho da String em dx em cx
	lengthString proc near
		push bp
		mov ch, ENDSTRING
		call findEndString
		mov cx,dx
		sub bp,cx
		mov cx,bp
		pop bp
		ret
	lengthString endp


; Scannea String em dx pela primeira ocorrência do char em ah e o troca por al 
	scanRep proc near
			push bp
			call findChar
			jc pulaScanRep
			mov byte ptr [bp],al
pulaScanRep: pop bp
			ret
	scanRep endp

		
;; Encontra a primeira ocorrência do char em ah na string em dx e retorna um ponteiro para este char em bp e zera CF, se não encontrar liga CF
	findChar  proc near  
				call lengthString
                mov bp,dx			;; bp = dx
                dec bp				;; bp-- ( ajustar para o primeiro loop )
	lookChar:   inc bp				;; inc++
                cmp byte ptr [bp],ah			
                je finalFindChar		;; Se iguais termina
				loop lookChar			;; Caso não forem e não tiver chegado ao final da String, continua
				stc						;; Seta CF se não encontrar
				ret
finalFindChar:  clc						;; Limpa CF se encontrar
				ret
	findChar	  endp 


;; Retorna um ponteiro em bp para o final da String em dx ( deve terminar com $ )
	findEndString proc near
                mov bp,dx			;; bp = dx
                dec bp				;; bp-- ( ajustar para o primeiro loop )
	lookFinal:   inc bp				;; inc++
                cmp byte ptr [bp],ENDSTRING			
                jne lookFinal		;; Se iguais termina
				ret
	findEndString endp


;================================================================================================================================================
; FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  
;================================================================================================================================================
	;; Coloca o código de erro em AX no final da string em dx. 
	getErrorMessage proc near
		push dx
		call findEndString 
		mov byte ptr [bp], SPACE
		inc bp
		mov dx, bp 
		call intToString 
		pop dx
		ret
	getErrorMessage endp

;; Escreve o número de bytes especificado em cx da string em dx no arquivo em bx
	fwrite proc near
		push ax
		mov ah, 40H
		int 21H
		pop ax
		ret
	fwrite endp

; Abre Arquivo cujo nome está na string apontada por dx, abre em modo especificado em al e armazena o handler em ax
	fopen proc near
		push ax
		mov ah,ENDSTRING
		mov al,NULL
		call scanRep
		pop ax
		mov ah,3DH
		int 21h
		jnc no_error
		lea dx, msgOpeningError
		call getErrorMessage
		call printf_s
		stc
		ret
no_error: push ax
		mov ah, NULL
		mov al, ENDSTRING
		call scanRep
		pop ax
		clc
		ret
	fopen endp

	; Cria Arquivo cujo nome está na string apontada por dx, abre em modo especificado em al e armazena o handler em ax
	fcreate proc near
		push dx
		push ax
		push cx
		mov cx,0
		mov ah,ENDSTRING
		mov al,NULL
		call scanRep
		mov ah,3CH
		int 21h
		jnc no_errorFCreate
		lea dx, msgCreatingError
		call getErrorMessage
		call printf_s
		pop cx
		pop ax
		pop dx
		stc
		ret
no_errorFCreate:
		mov ah, NULL
		mov al, ENDSTRING
		call scanRep
		pop cx
		pop ax
		pop dx
		clc
		ret
	fcreate endp

; Lê um byte do arquivo em bx e armazena em cl, seta CF se o arquivo terminou   
	fread proc near
		push ax
		push bp
		push dx				;; Salva registradores
		lea dx, StringTemp
		mov cx, 1  			;; Lê um char
		mov ah,3FH			;; Código Função DOS para ler arquivo 
		int 21h				;; Função DOS
		cmp cx,ax			
		jne fimArquivo		;; Se Bytes Lidos != CX então arquivo terminou
		mov bp, dx			
		mov cl, byte ptr [bp]		;; Move char lido para cx
		clc
endFread: pop dx				;; Resgata registradores
		pop bp
		pop ax
		ret
fimArquivo: stc 			;; Seta CF
		jmp endFread

	fread endp
;================================================================================================================================================
; DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS 
;================================================================================================================================================

;; Printa o número em ax como um inteiro decimal
	printIntDec proc near
		push dx
		call intToString
		call printf_s
		pop dx
		ret
	printIntDec endp

;; Printa o número em ax como um inteiro hexadecimal
	printIntHex proc near
		push dx
		call intToHexString
		call printf_s
		pop dx
		ret
	printIntHex endp


SEPARADOR 	equ 046
CR			equ	013
ENDSTRING	equ	036
NULL		equ 00h
LF 			equ	010
SPACE		equ 20h
BACKSPACE 	equ 008
end
		
