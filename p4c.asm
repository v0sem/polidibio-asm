;**************************************************************************
; sbm 2019. estructura básica de un programa en ensamblador
;
; pareja 14
;**************************************************************************
; definicion del segmento de datos
datos segment
INPUT_ASK	db "Introduce una cadena de caracteres:", 10, 13
ERROR		db "You did something wrong", 10, 13
INPUT		db 128 DUP(0)
ENCODE		db "encode"
DECODE		db "decode"
datos ends

pila segment stack "stack"
DB	64 DUP(?)
pila ends

code segment
assume cs: code, ds: datos, ss: pila

inicio proc

	mov ax, datos
	mov ds, ax
	mov ax, pila
	mov ss, ax
	mov sp, 64

	mov ah, 9h
	mov dx, OFFSET INPUT_ASK
	int 21h

	call get_input

	call get_code
	call comp_decode

	je decode
	call comp_encode
	je encode

user_error:
	mov ah, 9h
	mov dx, OFFSET ERROR
	int 21h

end_end:
	mov ah, 4Ch
	int 21h 

get_input:
	mov dx, OFFSET INPUT
	mov ah, 0Ah
	int 21h
	xor bx, bx

cmp_decode:
; Takes data from INPUT
; returns ax = 1 if it is equal to "decode"
	xor si, si

	cmp_d_loop:
	mov ax, INPUT[si]
	mov bx, DECODE[si]
	cmp ax, bx
	jne end_d_nequal

	inc si
	cmp si, 7 ; 6 de "decode" + 1 del "$"
	jne cmp_d_loop

	end_d_equal:
	mov ax, 1
	ret

	end_d_nequal:
	mov ax, 0
	ret

cmp_encode:
; Takes data from INPUT
; returns ax = 1 if it is equal to "encode"
	xor si, si

	cmp_e_loop:
	mov ax, INPUT[si]
	mov bx, ENCODE[si]
	cmp ax, bx
	jne end_e_nequal

	inc si
	cmp si, 7 ; 6 de "encode" + 1 del "$"
	jne cmp_e_loop

	end_e_equal:
	mov ax, 1
	ret

	end_e_nequal:
	mov ax, 0
	ret

inicio endp

code ends

endp inicio