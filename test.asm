;**************************************************************************
; sbm 2019. estructura básica de un programa en ensamblador
;
; pareja 14
;**************************************************************************
; definicion del segmento de datos
datos segment

	ORDEN		equ	6
	ENCODE		equ 10
	DECODE		equ 11

	polibio		db	'x', 'y', 'z', '0', '1', '2'
				db	'3', '4', '5', '6', '7', '8'
				db	'9', 'a', 'b', 'c', 'd', 'e'
				db	'f', 'g', 'h', 'i', 'j', 'k'
				db	'l', 'm', 'n', 'o', 'p', 'q'
				db	'r', 's', 't', 'u', 'v', 'w'

	polibio_b	db	"| x y z 0 1 2 |", 10, 13
				db	"| 3 4 5 6 7 8 |", 10, 13
				db	"| 9 a b c d e |", 10, 13
				db	"| f g h i j k |", 10, 13
				db	"| l m n o p q |", 10, 13
				db	"| r s t u v w |", 10, 13, "$"
	
	debug		db	"hola mundo$" 				; Should be 43 54 51 32 52 64 53 35 54

datos ends

;**************************************************************************
; definicion del segmento de pila
pila segment stack "stack"
pila ends

;**************************************************************************
; definicion del segmento extra
extra segment
result dw 0,0 ;ejemplo de inicialización. 2 palabras (4 bytes)
extra ends

;**************************************************************************
; definicion del segmento de codigo
code segment
assume cs: code, ds: datos, es: extra, ss: pila
; comienzo del procedimiento principal
inicio proc
; inicializa los registros de segmento con su valor
mov ax, datos
mov ds, ax
mov ax, pila
mov ss, ax
mov ax, extra
mov es, ax
mov sp, 64 ; carga el puntero de pila con el valor mas alto
; fin de las inicializaciones

;**************************************************************************
; comienzo del programa

main:
		; In ah is the 'selector' and in ds:dx is where the string is
		;cmp ah, ENCODE
		;jz encode_proc
		;cmp ah, DECODE
		;jz decode_proc
		call print_matrix
		mov ax,4C00H							; FIN DE PROGRAMA Y VUELTA AL DOS
		int 21H		
		call encode_proc

		mov ax,4C00H							; FIN DE PROGRAMA Y VUELTA AL DOS
		int 21H									; Return


	print_matrix:
		push ax dx

		mov dx, offset polibio_b
		mov ah, 9
		int 21h

		pop dx ax

		ret

	encode_proc:
		push bp
		mov bp, sp						; Create the stack
		push si di ax bx cx dx					; Push em

		mov bx, dx

		xor si, si
		main_loop:
			mov ch, debug[si]				;~ Get character

			mov di, -1
			cmp ch, ' '					; if space skip
			jz skip
			cmp ch, '$'					; if end line, complete program
			jz main_end

			check_table:
				inc di
				cmp ch, cs:polibio[di]			; Check if character is in the table
				jnz check_table

			mov ax, di
			mov ch, ORDEN
			div ch						; Transform the code into 2 ASCII characters
			mov ch, ah
			mov cl, al

			print:

				mov ah, 2
				add cl, 31h
				mov dl, cl
				int 21h					; Print first

				mov ah, 2
				add ch, 31h
				mov dl, ch
				int 21h					; Print second

				print_space:
					mov ah, 2
					mov dl, ' '
					int 21h				; Print a space

			skip:
				inc si
				jmp main_loop				; Loop

		main_end:
			mov ah, 2
			mov dl, 13					; Carriage
			int 21h

			mov ah, 2
			mov dl, 10					; Newline
			int 21h

		pop dx cx bx ax di si bp

		ret

	decode_proc:

; fin del programa
;**************************************************************************

inicio endp
; fin del segmento de codigo
code ends
; fin del programa indicando donde comienza la ejecucion
end inicio