;==================================================
; Function printf()
; >Parametrs:
;	-Format string
;	-Arguments
; >Returns:
;	-
;==================================================
global printf

section		.data

Format_str 	db "Hello %d world!", 10, 0
Arg_1		dd 1854390267

;:::Errors:::
Error_1		db 10, "Invalid specificator"
Er1_len		equ $ - Error_1


section		.text

printf:
		push Arg_1
		push Format_str
		pop rbp
		;mov rbp, Format_str

Repeat:
		cmp byte [rbp], '%'
		je Marker

		call Putchar
Handler:
		inc rbp
		cmp byte [rbp], 0
		jne Repeat

		mov rax, 0x3C
		xor rdi, rdi
		syscall

		ret


Marker:
		inc rbp
		cmp byte [rbp], 'd'
		je Decimal
;		cmp byte [rbp], 'c'
;		je Char
;		cmp byte [rbp], 's'
;		je String
;		cmp byte [rbp], 'x'
;		je Hexademical
;		cmp byte [rbp], 'o'
;		je Octal
;		cmp byte [rbp], '%'
;		je Percent

		mov rsi, Error_1
		mov rdx, Er1_len
		call Print_str

		mov rax, 0x3C
		mov rdi, 1
		syscall




Decimal:
		jmp Handler



Print_str:
		mov rax, 0x01
		mov rdi, 1
		syscall
		ret



Putchar:
		mov rax, 0x01
		mov rdi, 1
		mov rsi, rbp
		mov rdx, 1
		syscall
		ret