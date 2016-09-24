segment .data
mensaje_1 db "Indice fuera de rango" , 0
mensaje_2 db "División por cero" , 0
segment .bss
_esCierto resd 1
_msg1 resd 1
_msg2 resd 1
_a resd 1
_b resd 1
segment .text
global main
extern scan_int, scan_boolean
extern print_int, print_boolean, print_string, print_blank, print_endofline


	_suma:
	push ebp
	mov ebp, esp
	sub esp, 0
lea eax, [ebp+12]
push dword eax
lea eax, [ebp+8]
push dword eax
; cargar el segundo operando en edx
	pop dword edx
	mov dword edx, [edx]
; cargar el primer operando en eax
	pop dword eax
	mov dword eax, [eax]
; realizar la suma y dejar el resultado en eax
	add eax, edx
; apilar el resultado
	push dword eax
	pop dword eax
	mov dword esp, ebp
	pop dword ebp
	ret
	mov esp, ebp
	pop ebp
	ret 


main: 
mov ebp, esp
; numero_linea 10
	push dword 3
	pop dword eax
	mov dword [_a],eax
; numero_linea 11
	push dword 2
	pop dword eax
	mov dword [_b],eax
	push dword _a
	push dword _b
; cargar el segundo operando en edx
	pop dword edx
	mov dword edx, [edx]
; cargar el primer operando en eax
	pop dword eax
	mov dword eax, [eax]
; realizar la suma y dejar el resultado en eax
	add eax, edx
; apilar el resultado
	push dword eax
; numero_linea 13
	push dword 5
; cargar la segunda expresion en edx
	pop dword edx
; cargar la primera expresion en eax
	pop dword eax
; comparar y apilar el resultado
	cmp eax, edx
	je near igual0
	push dword 0
	jmp near fin_igual0
	igual0: push dword 1
	fin_igual0:
	pop eax
	cmp eax, 0
	je near fin_si1
	push dword _a
	push dword _a
; cargar la segunda expresion en edx
	pop dword edx
	mov dword edx, [edx]
; cargar la primera expresion en eax
	pop dword eax
	mov dword eax, [eax]
; comparar y apilar el resultado
	cmp eax, edx
	je near igual2
	push dword 0
	jmp near fin_igual2
	igual2: push dword 1
	fin_igual2:
	call print_boolean
	add esp,4
	call print_endofline
fin_si1:
	push dword _a
	push dword _b
; cargar el segundo operando en edx
	pop dword edx
	mov dword edx, [edx]
; cargar el primer operando en eax
	pop dword eax
	mov dword eax, [eax]
; realizar la suma y dejar el resultado en eax
	add eax, edx
; apilar el resultado
	push dword eax
; numero_linea 17
	push dword 5
; cargar la segunda expresion en edx
	pop dword edx
; cargar la primera expresion en eax
	pop dword eax
; comparar y apilar el resultado
	cmp eax, edx
	jne near distinto3
	push dword 0
	jmp near fin_distinto3
	distinto3: push dword 1
	fin_distinto3:
	pop eax
	cmp eax, 0
	je near fin_si4
	push dword _a
	push dword _a
; cargar la segunda expresion en edx
	pop dword edx
	mov dword edx, [edx]
; cargar la primera expresion en eax
	pop dword eax
	mov dword eax, [eax]
; comparar y apilar el resultado
	cmp eax, edx
	jne near distinto5
	push dword 0
	jmp near fin_distinto5
	distinto5: push dword 1
	fin_distinto5:
	call print_boolean
	add esp,4
	call print_endofline
fin_si4:
; numero_linea 22
	push dword 3
; numero_linea 22
	push dword 2
; cargar el segundo operando en edx
	pop dword edx
; cargar el primer operando en eax
	pop dword eax
; realizar la suma y dejar el resultado en eax
	add eax, edx
; apilar el resultado
	push dword eax
; numero_linea 22
	push dword 6
; cargar la segunda expresion en edx
	pop dword edx
; cargar la primera expresion en eax
	pop dword eax
; comparar y apilar el resultado
	cmp eax, edx
	je near igual6
	push dword 0
	jmp near fin_igual6
	igual6: push dword 1
	fin_igual6:
	pop eax
	cmp eax, 0
	je near fin_si7
; numero_linea 23
	push dword 1
	call print_boolean
	add esp,4
	call print_endofline
jmp near fin_sino7
fin_si7:
; numero_linea 26
	push dword 0
	call print_boolean
	add esp,4
	call print_endofline
fin_sino7:
; numero_linea 29
	push dword 1
	pop eax
	cmp eax, 0
	je near fin_si8
; numero_linea 30
	push dword 27
	call print_int
	add esp,4
	call print_endofline
jmp near fin_sino8
fin_si8:
; numero_linea 33
	push dword 3
	call print_int
	add esp,4
	call print_endofline
fin_sino8:
mov esp, ebp
	jmp near fin
error_1: push dword mensaje_1
call print_string
add esp, 4
jmp near fin
error_2: push dword mensaje_2
call print_string
mov esp, ebp
jmp near fin
mov esp, ebp
fin:ret
