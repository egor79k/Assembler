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
;:::Consts:::
Oct 		dd 8
		db "01234567"

Decim 		dd 10
		db "0123456789"

Hex		dd 0x10
		db "0123456789ABCDEF"
		
Stk_offset	equ 8
ASCII_offset 	equ 48
tmp 		db '0'

;:::Errors:::
Error_1		db 10, "Error: Invalid specificator!", 10
Er1_len		equ $ - Error_1



section		.text

printf:		
		mov rbp, rsp 			;Mov stack pointer to RBP
		mov rbx, [rbp + Stk_offset]	;Take firs arg from stack
		add rbp, Stk_offset * 2		;Mov stack pointe to next arg
.Repeat:	
		cmp byte [rbx], '%'		;Check for marker
		je Marker

		mov rsi, rbx
		call Putchar
..@Handler:
		inc rbx
		cmp byte [rbx], 0		;Check for EOL
		jne .Repeat

		ret


;==================================================
; Switch types of markers
;==================================================
Marker:
		inc rbx
		cmp byte [rbx], 'd'
		je Decimal
		cmp byte [rbx], 'c'
		je Char
		cmp byte [rbx], 's'
		je String
		cmp byte [rbx], 'x'
		je Hexadecimal
		;cmp byte [rbx], 'o'
		;je Octal
;		cmp byte [rbx], '%'
;		je Percent

		mov rsi, Error_1
		mov rdx, Er1_len
		call Print_str

		mov rax, 0x3C
		mov rdi, 1
		syscall 			;Exit (1)


;==================================================
; Print decimal number
;==================================================
Decimal:	
		mov rdi, Decim
		jmp Number

		mov rcx, [rbp]
		mov eax, [rcx]
		add rbp, Stk_offset
		xor rcx, rcx
		xor rdx, rdx
.Repeat:	
		mov esi, 10
		xor edx, edx
		div esi
		add edx, ASCII_offset
		push rdx
		inc rcx
		cmp eax, 0
		jne .Repeat

		mov rax, 0x01
		mov rdi, 1
		mov rdx, 1
.Cycle:
		mov rsi, rsp
		push rcx
		syscall
		pop rcx
		pop rsi
		loop .Cycle

		jmp ..@Handler


;==================================================
; Print decimal number
;==================================================
Char:
		mov rsi, [rbp]
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
; Print Hexadecimal number
;==================================================
Hexadecimal:
		mov rdi, Hex
		jmp Number

		mov rcx, [rbp]
		mov eax, [rcx]
		add rbp, Stk_offset
		mov rcx, 2
.Repeat:	
		mov esi, 0x10
		xor edx, edx
		div esi
		mov rsi, [Hex + edx + 4]
		push rsi
		inc rcx
		cmp eax, 0
		jne .Repeat

		mov rsi, 'x'
		push rsi
		mov rsi, '0'
		push rsi
		mov rax, 0x01
		mov rdi, 1
		mov rdx, 1
.Cycle:
		mov rsi, rsp
		push rcx
		syscall
		pop rcx
		pop rsi
		loop .Cycle

		jmp ..@Handler


;==================================================
; Print Hexadecimal number
;==================================================
Number:
		mov rcx, [rbp]
		mov eax, [rcx]
		add rbp, Stk_offset
		xor rcx, rcx
.Repeat:	
		mov esi, dword [rdi]
		xor rdx, rdx
		div esi
		mov rsi, [rdi + rdx + 4]
		push rsi
		inc rcx
		cmp eax, 0
		jne .Repeat

		mov rax, 0x01
		mov rdi, 1
		mov rdx, 1
.Cycle:
		mov rsi, rsp
		push rcx
		syscall
		pop rcx
		pop rsi
		loop .Cycle

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