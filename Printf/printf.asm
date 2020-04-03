;==================================================
; Function printf()
;==================================================
global printf

section		.data

prcnt 		db '%'
Stk_offset	equ 8
Markers_table 	db "dcsxob%"
Markers_num 	equ 7
Jmp_table:
		dq Decimal
		dq Char
		dq String
		dq Hexadecimal
		dq Octal
		dq Binary
		dq Percent


;:::Number systems:::;
ASCII_nums	db "0123456789ABCDEF"

Bin 		dd 1				;Bits num in one digit for this system
		dd 0x00000001			;Mask for last digit

Oct 		dd 3
		dd 0x00000007

Hex		dd 4
		dd 0x0000000F

Decim 		equ 10				;Divider for decimal numbers
		
;:::Errors:::;
Error_1		db 10, "Error: Invalid specificator!", 10
Er1_len		equ $ - Error_1



section .bss
num_start	resb 32				;Buffer for numbers print
num_end:					;It's tail



section		.text
;==================================================
; Print string in std output, located between R8 and RBX pointers
; Entry: 1 arg  - String start
;	 2 arg - String end
; Destr: RAX RCX RDI
;==================================================
%macro Print_fromto 2
		mov rsi, %1
		mov rdx, %2
		sub rdx, %1
		call Print_str
%endmacro


printf:		
		push rbp			;Saving old RBP
		mov rbp, rsp 			;Mov stack pointer to RBP
		mov rbx, [rbp + 2 * Stk_offset]	;Take first arg from stack
		add rbp, Stk_offset * 3		;Mov stack pointer to next arg
		dec rbx
..@Handler:					;Return-point for markers parser
		inc rbx				;Skip marker id (letter after %)
		mov r8, rbx			;Save whole string part between markers
.Repeat:	
		cmp byte [rbx], '%'		;Check for marker
		je Marker
		cmp byte [rbx], 0		;Check for EOL
		je .End_str
		inc rbx
		jmp .Repeat
.End_str:
		Print_fromto r8, rbx		;Print last piece of format string before '/0'

		pop rbp
		mov rax, 0
		ret 				;return 0;


;==================================================
; Switch types of markers
;==================================================
Marker:
		Print_fromto r8, rbx		;Print last part of format string before '%'
		inc rbx

		mov al, byte [rbx]		;Determine type of marker
		mov rdi, Markers_table
		mov rcx, Markers_num
		repne scasb
		jne .Error

		sub rdi, Markers_table		;Jmp to corresponding label
		dec rdi
		shl rdi, 3
		add rdi, Jmp_table
		jmp [rdi]
.Error:
		mov rsi, Error_1		;Undefined marker id
		mov rdx, Er1_len
		call Print_str

		pop rbp
		mov rax, 1
		ret 				;return 1;


;==================================================
; Print decimal number
; Destr: EAX RCX EDX RSI RDI R9
;==================================================
Decimal:	
		mov edi, Decim			;Move decimal divider to EDI
		mov eax, [rbp]			;Put number into EAX
		add rbp, Stk_offset
		xor rcx, rcx 			;Reset buffer's counter
		xor r9, r9 			;Reset negative flag

		cmp eax, 0			;Check if num is negative
		jge .Repeat
		neg eax 			;Make it pos and turn neg flag on
		mov r9, 1			;R9 - flag, num is: 0 - positive 1 - negative
.Repeat:	
		xor edx, edx
		div edi				;Get the smallest digit in EDX
		mov sil, [ASCII_nums + edx]
		mov byte [num_end + rcx], sil	;Write number as a string in reversed buffer
		dec rcx				;Reversed buffer's counter
		cmp eax, 0			;Do while next digit != 0
		jne .Repeat

		cmp r9, 0			;If num is neg mov '-' in buff start
		je .Positive
		mov byte [num_end + rcx], '-'
		dec rcx
.Positive:
		neg rcx				; Printing buffer in usual oreder
		mov rdx, rcx
		mov rsi, num_end + 1
		sub rsi, rcx
		call Print_str
		jmp ..@Handler


;==================================================
; Print hexadecimal number
;==================================================
Hexadecimal:
		mov rdi, Hex
		jmp TPS_Num


;==================================================
; Print octal number
;==================================================
Octal:
		mov rdi, Oct
		jmp TPS_Num


;==================================================
; Print binary number
;==================================================
Binary:
		mov rdi, Bin
		jmp TPS_Num


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
		mov rsi, [rbp]			;Get string addr from stack
		add rbp, Stk_offset
		xor rdx, rdx
		dec rdx
.Repeat:
		inc rdx
		cmp byte [rsi + rdx], 0		;Find string end
		jne .Repeat

		call Print_str			;Print string
		jmp ..@Handler


;==================================================
; Print percent
;==================================================
Percent:
		mov rsi, prcnt
		call Putchar			;Print '%'
		jmp ..@Handler


;==================================================
; Print 4 byte number in two-powered number systems (TPS)
; Entry: RDI - NS buffer in format: dd <radix> db "1...<radix-1>"
; Destr: RAX RCX RDX RSI
;==================================================
TPS_Num:					;"Two-powered system number"
		mov eax, [rbp]			;Put number into EAX
		add rbp, Stk_offset
		xor r9, r9
.Repeat:	
		mov edx, eax			;Get the smallest digit into EDX
		and edx, [rdi + 4]
		xor rcx, rcx			;Shift number on one digit right
		mov ecx, [rdi]
		.lp: shr eax, 1
		loop .lp
		mov sil, [ASCII_nums + edx]
		mov byte [num_end + r9], sil	;Write number as a string in reversed buffer
		dec r9				;Reversed buffer's counter
		cmp eax, 0
		jne .Repeat

		neg r9				; Printing buffer in usual oreder (left->right)
		mov rdx, r9
		mov rsi, num_end + 1
		sub rsi, r9
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