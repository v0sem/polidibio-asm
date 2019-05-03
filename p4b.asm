;**************************************************************************
; sbm 2019. estructura básica de un programa en ensamblador
;
; pareja 14
;**************************************************************************
; definicion del segmento de datos
datos segment
debug		db "hola mundo$"
debug_dec	db 43, 54, 51, 32, 52, 64, 53, 35, 54, '$'
datos ends

;**************************************************************************
; definicion del segmento de pila
pila segment stack "stack"
pila ends

;**************************************************************************
; definicion del segmento extra
extra segment
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

mov dx, offset debug
mov ah, 10h

int 57h

mov dx, offset debug_dec
mov ah, 11h

int 57h

mov ax, 4C00h
int 21h
inicio endp
; fin del segmento de codigo
code ends
; fin del programa indicando donde comienza la ejecucion
end inicio