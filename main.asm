.model small
.stack
.data
coluna1 db 0
coluna2 db 0
coluna3 db 0
coluna4 db 0
temp dw ?
Ten dw 10
Sixteen dw 16
pointerChar dw ?
pointerString dw ?
StringTemp db 20 dup(0)
NomeArquivo db 61 dup(0)
NomeSaida db 10 dup(0)


;================================================================================================================================================
; CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS 
;================================================================================================================================================

msgNomeArquivo  db "Insira o nome do arquivo:",CR,LF,ENDSTRING
msgOpeningError db "Ocorreu um erro durante a abertura do arquivo: ", ENDSTRING
breakLine db CR,LF,ENDSTRING
fimds db "Arquivo terminou :(", ENDSTRING
extensaoSaida db ".res", ENDSTRING


.code
.startup
	lea dx, msgNomeArquivo
	lea bx, StringTemp
	call copyString
	mov bx, dx
	call printf_s
	call printn
	lea dx, StringTemp
	call printf_s


.exit


;================================================================================================================================================
; FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS 
;================================================================================================================================================

;; Ler o nome do arquivo e armazenar o nome de saída
	scanName proc near
		lea dx, NomeArquivo
		call scanf
		mov ah, SEPARADOR
		mov al, ENDSTRING
		call scanRep
		lea bx, extensaoSaida
		call appendString
		ret	
	scanName endp



;================================================================================================================================================
; IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  IO FUNCS  
;================================================================================================================================================

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
charNormal: mov [bx],al			  	;; Se não coloca o char na string
		inc bx;				  		;; E Incrementa seu ponteiro
		loop input			 
end_input:	mov [bx], ENDSTRING	 	;; Coloca o terminador de String no Final da string
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
		mov cx,4	;; TODO 2 OPTIONS (2 BYTE AND 1 BYTE)
		mov bx,1000H		;; Pois 16 bits suportam no máximo um inteiro igual a FFFFH
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
		call findEndString
loopssa: mov al, [bx]
		mov byte ptr [bp], al
		inc bx
		inc bp
		cmp byte ptr [bx], ENDSTRING
		jne loopssa
		mov byte ptr [bp], ENDSTRING
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


; Abre Arquivo cujo nome está na string apontada por dx, abre em modo de leitura e armazena o handler em ax
	fopen proc near
		mov ah,ENDSTRING
		mov al,NULL
		call scanRep
		mov ah,3DH
		mov al,00
		int 21h
		jnc no_error
		lea dx, msgOpeningError
		call getErrorMessage
		call printf_s
no_error: push ax
		mov ah, NULL
		mov al, ENDSTRING
		call scanRep
		pop ax
		ret
	fopen endp

; Lê um byte do arquivo em bx e armazena em cx, seta CF se o arquivo terminou   
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
		mov cx, [bp]		;; Move char lido para cx
		clc
endFread:pop dx				;; Resgata registradores
		pop bp
		pop ax
		ret
fimArquivo: stc 			;; Seta CF
		jmp endFread

	fread endp
;================================================================================================================================================
; DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS DEBUG FUNCS 
;================================================================================================================================================
; PORQUE NINGUÉM MERECE USAR ESSE CODE VIEW KKKKKKK ( desculpa não gostei )

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
		
