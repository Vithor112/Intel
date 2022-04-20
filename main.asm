.model small
.stack
.data
Texto1  db "Insira o nome do arquivo:",CR,LF,endString
NomeArquivo db 61 dup(0)
msgError db " Houve um erro ", endString
.code
.startup
	lea dx, Texto1
	call printf_s
	lea bx, NomeArquivo
	call scanf
	lea dx, NomeArquivo
	call printf_s
	call open_f
.exit

; Scanea caracteres do teclado, até um máximo de 60 e os armazena na string apontada por bx
	scanf proc near
		mov cx,60
		mov ah,1
input:		int 21h
		cmp al,13
		jz end_input
		mov [bx],al
		inc bx;
		loop input
end_input:	mov [bx], endString
		ret
	scanf endp
	
; Printa a string que está no ponteiro dx, a string precisa terminar com $
	printf_s proc near
		mov ah,9
		int 21h
		ret
	printf_s endp

; Scannea String em dx pela primeira ocorrência do char em ch e o troca por cl
; o Char em ch precisa estar na string! 
        scanRep proc near
                push bp
                mov bp,dx
                dec bp
keepLooking:    inc bp  
                cmp [bp],ch
                jne keepLooking
                mov [bp],cl
                pop bp
                ret
        scanRep endp

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
		call printf_s
no_error:	mov ch, 00H
		mov cl, eddndString
		call scanRep
		ret
	open_f endp
		

CR		equ	 13
endString	equ	 36
null		equ 	00h
LF 		equ	 10

end
		
