;**************************************************************************
; sbm 2019. estructura básica de un programa en ensamblador
;
; pareja 14
;**************************************************************************

codigo segment
assume cs:codigo

org 256
;**************************************************************************
; main
;**************************************************************************

main:
; main function, handles parameters
; returns nothing
    mov si, 80h ; load number of bytes
    mov al, [si]
    cmp al, 0
    jne param_len

    mov ah, 9 ; imprimir info e instrucciones
    mov dx, offset meta_infoB
    int 21h

    mov ah, 9 ; imprimir string para el estado de instalacion
    mov dx, offset meta_infoA
    int 21h

    call check_sign
    mov dl, al ; save to print it
    add dl, 30h ; turn it to ascii

    mov ah, 2 ; print the number to indicate state
    int 21h

    jmp end_end

    param_len:
    cmp ax, 3 ; comprueba que son 3 bytes " /d" o " /i"
    jne user_error
    mov si, 81h ; load input bytes
    
    mov al, [si]
    cmp al, ' ' ; first char has to be a space
    jne user_error

    inc si ; next char

    mov al, [si]
    cmp al, '/' ; second char has to be a slash
    jne user_error

    inc si ; next char

    mov al, [si]
    cmp al, 'I' ; if third char is a D then uninstall
    je instalar

    cmp al, 'D' ; if third char is a D then uninstall
    je desinstalar

    jmp user_error ; if you didn't jump it's your fault

    instalar:
    call instalador
    jmp end_end

    desinstalar:
    call desinstalador
    jmp end_end

    user_error:
    jmp print_error

;
; banner lo mas guapo
;


;**************************************************************************
; datos
;**************************************************************************

    ORDEN		equ	6
    MAX_TAB		equ 35
    ENCODE		equ 10
    DECODE		equ 11

    polibio		db 'x', 'y', 'z', '0', '1', '2'
                db '3', '4', '5', '6', '7', '8'
                db '9', 'a', 'b', 'c', 'd', 'e'
                db 'f', 'g', 'h', 'i', 'j', 'k'
                db 'l', 'm', 'n', 'o', 'p', 'q'
                db 'r', 's', 't', 'u', 'v', 'w'

    polibio_b	db "| x y z 0 1 2 |", 10, 13
                db "| 3 4 5 6 7 8 |", 10, 13
                db "| 9 a b c d e |", 10, 13
                db "| f g h i j k |", 10, 13
                db "| l m n o p q |", 10, 13
                db "| r s t u v w |", 10, 13, "$"

    meta_infoA  db "- Estado de la rutina [0 = sin instalar / 1 = instalada]: ", '$'
    meta_infoB  db "- Pareja 14, Pablo Sanchez y Antonio Solana", 10, 13
                db "    - Sin parametros : imprime esta informacion", 10, 13
                db "    - Parametro /I   : instala la rutina", 10, 13
                db "    - Parametro /D   : desinstala la rutina", 10, 13
                db "- Ejecutar p4b.exe o p4c.exe para comprobar el funcionamiento", 10, 13

    error_str	db 10, "Error, YOU did something wrong!", 10, 13, '$'

rsi proc
    
    cmp ah, 10h
    jnz m_decode_proc

m_decode_proc:
	cmp ah, 11h
	jnz m_print_matrix
	call decode_proc

	m_print_matrix:
	call print_matrix

end_end_rsi:
	mov ax,4C00H							; FIN DE PROGRAMA Y VUELTA AL DOS
	int 21H


print_matrix:
	mov dx, offset polibio_b
	mov ah, 9
	int 21h

	pop dx ax

	ret

encode_proc:
	mov bx, dx

	xor si, si
	main_loop:
		mov ch, [bx][si] ;~ Get character

		mov di, -1
		cmp ch, '$' ; if end line, complete program
		jz main_end

		check_table:
			inc di
			cmp ch, polibio[di] ; Check if character is in the table
			je found_char ; we found it bois

			cmp di, MAX_TAB ; did we check everything?
			jne check_table ; keep looking
			jmp print_error_rsi ; not found

		found_char:
		mov ax, di
		mov ch, ORDEN
		div ch ; Transform the code into 2 ASCII characters
		mov ch, ah
		mov cl, al

		print:

			mov ah, 2
			add cl, 31h
			mov dl, cl
			int 21h ; Print first

			mov ah, 2
			add ch, 31h
			mov dl, ch
			int 21h ; Print second

			print_space:
				mov ah, 2
				mov dl, ' '
				int 21h ; Print a space

		skip:
			inc si
			jmp main_loop ; Loop

	main_end:
		mov ah, 2
		mov dl, 13 ; Carriage
		int 21h

		mov ah, 2
		mov dl, 10 ; Newline
		int 21h

	ret

decode_proc:
	xor si, si
    mov bx, dx

	get_char:
		mov al, [bx][si]
		xor ah, ah
		mov dl, 10
		div dl ; al primero, ah segundo

		dec al
		mov dl, ah ; guardar segundo digito
		dec bx

		; segundo + ORDEN * primero
		xor ah, ah
		mov cx, ORDEN
		mul cx ; ORDEN * primero
		add dx, ax ; + segundo

		xor ax, ax
        mov si, dx
		mov al, polibio[si]

		mov dl, [bx][si] ; load again to check if we are finished

		cmp dl, '$' ; Check if finished
		je finish_printing ; if we are finished, jump to cont

		mov dx, ax
		mov ah, 2
		int 21h

		inc si

		jmp get_char ; go back

	finish_printing:
		mov ah, 2
		mov dl, 13 ; Carriage
		int 21h

		mov ah, 2
		mov dl, 10 ; Newline
		int 21h
	
	ret

print_error_rsi:
; takes no arguments and prints an error before exiting
; returns no arguments
	mov dx, offset error_str
	mov ah, 9h
	int 21h
	jmp end_end_rsi


rsi endp

timer proc

    cmp ah, 0
    jne timer_loop
    mov ah, 18

    timer_loop:
        dec al      ;-1 to the counter every 1/18th of a second
        cmp al, 0
        mov ah, 1   ;Sets ah to 1 if the second is finished 

timer endp

;**************************************************************************
; installer and uninstaller
;**************************************************************************

instalador proc
    ; check if installed
    call check_sign
    cmp ax, 1
    jne continue_instalation
    ret

    continue_instalation:
    ; instalar residente en 57h
    mov ax, 0
    mov es, ax
    mov ax, offset rsi
    mov bx, cs
    cli
    mov es:[57H*4-2], 0BEEFH ; sign this address to check later if its installed
    mov es:[57H*4], AX 
    mov es:[57H*4+2], BX
    sti

    mov ax, 0
    mov es, ax
    mov ax, offset timer
    mov bx, cs
    cli

    in al, 21H
	or al, 00000001B            ; closes timer
    mov es:[1CH*4-2], 0BEEFH ; sign this address to check later if its installed
    mov es:[1CH*4], AX 
    mov es:[1CH*4+2], BX
    sti

    mov dx, offset instalador
    int 27h

    ret
instalador endp

desinstalador proc
    ;check if installed
    call check_sign
    cmp ax, 0
    jne continue_uninstalation
    ret

    continue_uninstalation:
    ; desinstalar residente de 57h

    mov cx, 0
    mov ds, cx
    mov es, ds:[57h*4+2]
    mov bx, es:[2Ch]

    mov ah, 49h
    int 21H
    mov es, bx
    int 21H

    cli
    mov ds:[57h*4-2], cx ; remove the sign
    mov ds:[57h*4], cx
    mov ds:[57h*4+2], cx
    sti

    mov cx, 0
    mov ds, cx
    mov es, ds:[1Ch*4+2]
    mov bx, es:[2Ch]

    mov ah, 49h
    int 21H
    mov es, bx
    int 21H

    cli
    mov ds:[1Ch*4-2], cx ; remove the sign
    mov ds:[1Ch*4], cx
    mov ds:[1Ch*4+2], cx
    sti

    ret

desinstalador endp

;**************************************************************************
; utils
;**************************************************************************

check_sign:
    xor ax, ax
    mov es, ax
    mov ax, es:[57h*4-2] ; load the sign location
    cmp ax, 0BEEFH ; check if the value is there
    je signed

    mov ax, 0 ; return not signed
    ret

    signed:
    mov ax, 1 ; return signed
    ret

print_error:
; takes no arguments and prints an error before exiting
; returns no arguments
	mov dx, offset error_str
	mov ah, 9h
	int 21h
	jmp end_end

end_end:
	mov ax,4C00H
	int 21H

codigo ends
end main