;####################################################################
;																	#
;		Driver version 14; INT 57 Resident module					#
;		Authors: Pablo Sanchez, Antonio solana P14					#
;																	#
;####################################################################

code segment

	ORDEN		equ	6
	ENCODE		equ 10
	DECODE		equ 11

	polibio		db	'x', 'y', 'z', '0', '1', '2'
				db	'3', '4', '5', '6', '7', '8'
				db	'9', 'a', 'b', 'c', 'd', 'e'
				db	'f', 'g', 'h', 'i', 'j', 'k'
				db	'l', 'm', 'n', 'o', 'p', 'q'
				db	'r', 's', 't', 'u', 'v', 'w'
	debug		db	"hola mundo$" ; Should be 43 54 51 32 52 64 53 35 54

	assume cs: code
	inicio proc
	main:
		; In ah is the 'selector' and in ds:dx is where the string is
		;cmp ah, ENCODE
		;jz encode_proc
		;cmp ah, DECODE
		;jz decode_proc
		;ret

	encode_proc:
		;push bp
		;mov bp, sp						; Create the stack
		;push si di ax bx cx	dx			; Push em 

		mov bx, dx

		xor si, si
		main_loop:
			mov ch, debug[si]			; Get character

			mov di, -1
			cmp ch, ' '					; if space skip
			jz skip
			cmp ch, '$'					; if end line, complete program
			jz main_end

			check_table:
				inc di
				cmp ch, cs:polibio[di]	; Check if character is in the table
				jnz check_table

			mov ax, di
			mov ch, ORDEN
			div ch					; Transform the code into 2 ASCII characters					
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

			mov dl, 10					; Newline
			int 21h

			mov dl, 13					; Carriage return
			int 21h
		
		;pop dx cx bx ax di si bp
		;ret								; Return
	
	decode_proc:
		
		
inicio endp
code ends
end inicio
			

