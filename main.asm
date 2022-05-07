.model small
.stack
.data
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

msgNomeArquivo  db "Insira o nome do arquivo:",CR,LF,endString
msgError db " Houve um erro ", endString
breakLine db CR,LF,endString


teste db ".res", endString


.code
.startup
	lea dx, msgNomeArquivo
	call printf_s
	call scanName
	lea dx, NomeArquivo
	call printf_s


.exit


;================================================================================================================================================
; FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS FUNÇÕES ESPECIFICAS 
;================================================================================================================================================

;; Ler o nome do arquivo e armazenar o nome de saída
	scanName proc near
		lea bx, NomeArquivo
		call scanf
		mov ah,SEPARADOR
		mov al, endString
		lea dx, NomeArquivo
		call scanRep
		lea bx, teste
		lea dx, NomeArquivo
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
;; TODO bug backspace and limit
; Scanea caracteres do teclado, até um máximo de 60 e os armazena na string apontada por bx
	scanf proc near
		push cx
		push ax
		mov cx,LIMIT_SCAN                 ;; Limite de Caracteres
		mov ah,1			  ;; função 1
input:		int 21h				  ;; Chamada função DOS
		cmp al,CR			  ;; Verifica se recebeu um enter como entrada
		jz end_input			  ;; Se sim Termina de receber input
		mov [bx],al			  ;; Se não coloca o char na string
		inc bx;				  ;; E Incrementa seu ponteiro
		loop input			 
end_input:	mov [bx], endString	 	  ;; Coloca o terminador de String no Final da string
		pop ax
		pop cx
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
		mov [bp], al		;; Coloca na string 
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
		mov [bp], endString ;; Coloca o terminador na Strings
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
		mov cx,4	
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
insertHex: mov [bp], al		;; Coloca na string 
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
		mov [bp], endString ;; Coloca o terminador na Strings
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

; Adiciona String em bx no final da string apontada por dx
	appendString proc near
		call findEndString
loopssa: mov al, [bx]
		mov [bp], al
		inc bx
		inc bp
		cmp byte ptr [bx], endString
		jne loopssa
		mov [bp], endString
		ret 
	appendString endp

; Retorna o tamanho da String em dx em cx
	lengthString proc near
		push bp
		mov ch, endString
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
			mov [bp],al
pulaScanRep: pop bp
			ret
	scanRep endp

		
;; Encontra a primeira ocorrÊncia do char em ah na string em dx e retorna um ponteiro para este char em bp e zera CF, se não encontrar liga CF
	findChar  proc near  
				call lengthString
                mov bp,dx			;; bp = dx
                dec bp				;; bp-- ( ajustar para o primeiro loop )
	lookChar:   inc bp				;; inc++
                cmp [bp],ah			
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
                cmp byte ptr [bp],endString			
                jne lookFinal		;; Se iguais termina
				ret
	findEndString endp


;================================================================================================================================================
; FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  
;================================================================================================================================================

	getErrorMessage proc near
		call findEndString 
		mov [bp], SPACE
		inc bp
		lea dx, StringTemp 
		call intToString 
		;; TODO
		ret
	getErrorMessage endp


; Abre Arquivo cujo nome está na string apontada por dx, abre em modo de leitura
	open_f proc near
		mov ah,endString
		mov al,00H
		call scanRep
		mov ah,3DH
		mov al,00
		int 21h
		jnc no_error
		lea dx, msgError
		;call getErrorMessage
		call printf_s
no_error:	mov ah, 00H
		mov al, endString
		call scanRep
		ret
	open_f endp
		
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
		call toHexStringInt
		call printf_s
		pop dx
		ret
	printIntHex endp


SEPARADOR equ 46
CR		equ	 13
endString	equ	 36
null		equ 	00h
LF 		equ	 10
SPACE		equ 	20h
end
		
