;**************************************************************************
; sbm 2019. estructura básica de un programa en ensamblador
;
; pareja 14
;**************************************************************************
; definicion del segmento de datos
datos segment
INPUT_ASK	DB	"Introduce una cadena de caracteres:", 10, 13
ERROR	DB	"You did something wrong", 10, 13
INPUT	DB	128 DUP(0)
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

	mov ah, 9h
	mov dx, OFFSET ERROR
	int 21h

	mov ah, 4Ch
	int 21h 

	get_input:
		mov dx, OFFSET INPUT
		mov ah, 0Ah
		int 21h
		xor bx, bx

inicio endp

code ends

endp inicio