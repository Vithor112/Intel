.model small
.stack
.data
temp dw ?
Ten dw 10
pointerChar dw ?
pointerString dw ?
StringTemp db 20 dup(0)
NomeArquivo db 61 dup(0)

;================================================================================================================================================
; CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS CONSTANTES STRINGS 
;================================================================================================================================================

msgNomeArquivo  db "Insira o nome do arquivo:",CR,LF,endString
msgError db " Houve um erro ", endString
breakLine db CR,LF,"$"


.code
.startup
	lea dx, msgNomeArquivo
	call printf_s
	lea bx, NomeArquivo
	call scanf
	lea dx, NomeArquivo
	call printf_s
	call open_f
.exit

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
; Scanea caracteres do teclado, até um máximo de 60 e os armazena na string apontada por bx
	scanf proc near
		mov cx,LIMIT_SCAN                 ;; Limite de Caracteres
		mov ah,1			  ;; função 1
input:		int 21h				  ;; Chamada função DOS
		cmp al,CR			  ;; Verifica se recebeu um enter como entrada
		jz end_input			  ;; Se sim Termina de receber input
		mov [bx],al			  ;; Se não coloca o char na string
		inc bx;				  ;; E Incrementa seu ponteiro
		loop input			 
end_input:	mov [bx], endString	 	  ;; Coloca o terminador de String no Final da string
		ret
	scanf endp
	
; Printa a string que está no ponteiro dx, a string precisa terminar com $
	printf_s proc near
		mov ah,9		
		int 21h
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

;================================================================================================================================================
; STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS STRING FUNCS 
;================================================================================================================================================

; Scannea String em dx pela primeira ocorrência do char em ch e o troca por cl
; o Char em ch precisa estar na string! 
	scanRep proc near
			push bp
			call findChar
			mov [bp],cl
			pop bp
			ret
	scanRep endp

		
;; Encontra a primeira ocorrÊncia do char em ch na string em dx e retorna um ponteiro para este char em bp
	findChar  proc near
                mov bp,dx			;; bp = dx
                dec bp				;; bp-- ( ajustar para o primeiro loop )
	lookChar:   inc bp				;; inc++
                cmp [bp],ch			
                jne lookChar		;; Se não forem iguais continua procurando
                ret
	findChar	  endp 


;; Retorna um ponteiro para o final da String ( deve terminar com $ )
	FindendString proc near
		mov bp, pointerChar
		mov ch, endString	
		call findChar
		ret
	FindendString endp


;================================================================================================================================================
; FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  FILE FUNCS  
;================================================================================================================================================

	getErrorMessage proc near
		call FindendString 
		mov [bp], SPACE
		inc bp
		lea dx, StringTemp 
		call intToString 
		;; TODO
		ret
	getErrorMessage endp


; Abre Arquivo cujo nome está na string apontada por dx, abre em modo de leitura
	open_f proc near
		mov ch,endString
		mov cl,00H
		call scanRep
		mov ah,3DH
		mov al,00
		int 21h
		jnc no_error
		lea dx, msgError
		;call getErrorMessage
		call printf_s
no_error:	mov ch, 00H
		mov cl, endString
		call scanRep
		ret
	open_f endp
		

CR		equ	 13
endString	equ	 36
null		equ 	00h
LF 		equ	 10
SPACE		equ 	20h
end
		
