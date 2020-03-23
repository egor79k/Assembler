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

prcnt 		db '%'
Stk_offset	equ 8

;:::Number systems buffers:::
Bin 		dd 2
		db "01"

Oct 		dd 8
		db "01234567"

Decim 		dd 10
		db "0123456789"

Hex		dd 0x10
		db "0123456789ABCDEF"
		
;:::Errors:::
Error_1		db 10, "Error: Invalid specificator!", 10
Er1_len		equ $ - Error_1



section .bss
num 		resb 32				;Buffer for %d parser



section		.text

printf:		
		push rbp			;Saving old RBP
		mov rbp, rsp 			;Mov stack pointer to RBP
		mov rbx, [rbp + 2 * Stk_offset]	;Take first arg from stack
		add rbp, Stk_offset * 3		;Mov stack pointer to next arg
		dec rbx
..@Handler:					;Return-point for markers parser
		inc rbx				;Skip marker id (letter after %)
		mov r8, rbx
.Repeat:	
		cmp byte [rbx], '%'		;Check for marker
		je Marker
		cmp byte [rbx], 0		;Check for EOL
		je .End_str
		inc rbx
		jmp .Repeat
.End_str:
		mov rsi, r8			;Print last piece of format string before '/0'
		mov rdx, rbx
		sub rdx, r8
		call Print_str

		pop rbp
		mov rax, 0
		ret 				;return 0;


;==================================================
; Switch types of markers
;==================================================
Marker:
		mov rsi, r8
		mov rdx, rbx
		sub rdx, r8
		call Print_str

		inc rbx
		cmp byte [rbx], 'd'
		je Decimal
		cmp byte [rbx], 'c'
		je Char
		cmp byte [rbx], 's'
		je String
		cmp byte [rbx], 'x'
		je Hexadecimal
		cmp byte [rbx], 'o'
		je Octal
		cmp byte [rbx], 'b'
		je Binary
		cmp byte [rbx], '%'
		je Percent

		mov rsi, Error_1
		mov rdx, Er1_len
		call Print_str

		pop rbp
		mov rax, 1
		ret 				;return 1;


;==================================================
; Print decimal number
;==================================================
Decimal:	
		mov rdi, Decim
		jmp Number


;==================================================
; Print hexadecimal number
;==================================================
Hexadecimal:
		mov rdi, Hex
		jmp Number


;==================================================
; Print octal number
;==================================================
Octal:
		mov rdi, Oct
		jmp Number


;==================================================
; Print binary number
;==================================================
Binary:
		mov rdi, Bin
		jmp Number


;==================================================
; Print char
;==================================================
Char:
		mov rsi, rbp
		add rbp, Stk_offset
		call Putchar
		jmp ..@Handler


;==================================================
; Print string from arg
;==================================================
String:
		mov rsi, [rbp]
		add rbp, Stk_offset
		xor rdx, rdx
		dec rdx
.Repeat:
		inc rdx
		cmp byte [rsi + rdx], 0
		jne .Repeat

		call Print_str
		jmp ..@Handler


;==================================================
; Print percent
;==================================================
Percent:
		mov rsi, prcnt
		call Putchar
		jmp ..@Handler


;==================================================
; Print number in different number systems (NS)
; Entry: RDI - NS buffer in format: dd <radix> db "1...<radix-1>"
; Destr:
;==================================================
Number:
		mov eax, [rbp]
		add rbp, Stk_offset
		xor rcx, rcx
.Repeat:	
		xor rdx, rdx
		div dword [rdi]
		mov sil, [rdi + rdx + 4]
		mov byte [num + rcx + 32], sil
		dec rcx
		cmp eax, 0
		jne .Repeat

		neg rcx
		mov rdx, rcx
		mov rsi, num + 33
		sub rsi, rcx
		call Print_str
		jmp ..@Handler


;==================================================
; Print string in std output
; Entry: RSI - String addr
;	 RDX - Symbs num
; Destr: RAX RCX RDI
;==================================================
Print_str:
		mov rax, 0x01
		mov rdi, 1
		syscall
		ret


;==================================================
; Print char in std output
; Entry: RSI - Char addr
; Destr: RAX RCX RDX RSI RDI
;==================================================
Putchar:
		mov rax, 0x01
		mov rdi, 1
		mov rdx, 1
		syscall
		ret