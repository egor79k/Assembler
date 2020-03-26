;==================================================
; Testing program for printf function
;==================================================
global _start
extern printf

section 	.data
Stk_offset	equ 8
NewLine 	db 10

Format_str_1 	db "This is the great test string%c A[%d] %c %d | (%d)%c", 0
Arg_1_1		db '!'
Arg_1_2		dd 25
Arg_1_3		db '='
Arg_1_4		dd -1234567890
Arg_1_5		dd -2

Format_str_2	db "%s%c %s number %d%c%c", 0
Arg_2_1		db "The second test string", 0
Arg_2_2		db '!'
Arg_2_3		db "It's really", 0
Arg_2_4		dd 2

Format_str_3 	db "%d-d test. Testing printf again...%c%x%c%x%c%x%c%x%c", 0
Arg_3_1		dd 3
Arg_3_3		dd 0x2F5ED7C0
Arg_3_4		dd 1024
Arg_3_5		dd 0xA51BB
Arg_3_6		dd 256

Format_str_4 	db "%o%% or %o%% that it's last test.%c", 0
Arg_4_1		dd 100q
Arg_4_2		dd 50

Format_str_5 	db "I %s %x %d%%%c%b", 0
Arg_5_1		db 'love', 0
Arg_5_2		dd 3802
Arg_5_3		dd 100
Arg_5_4		db '!'
Arg_5_5		dd 127

Format_str_6	db 10, 0

Format_str_7 	db "%d-d test. %c%b%c%b%c%b%c%b%c%b%c", 0
Arg_7_1		dd 7
Arg_7_3		dd 0x2F5ED7C0
Arg_7_4		dd 1024
Arg_7_5		dd 0xA51BB
Arg_7_6		dd 256
Arg_7_7		dd 0xFFFFFFFF

Format_str_8	db "%%%%%%%%%s%%%%%%%%", 10, 0
Arg_8_1		db "MAIN_MENU", 0

Format_str_9	db "Testing neg and pos nums:%c%d%c%d%c%d%c%d%c", 0
Arg_9_1		dd 256
Arg_9_2		dd -2000000001
Arg_9_3		dd 1
Arg_9_4		dd -1555


section 	.text
_start:		
		push qword [NewLine]
		push qword [Arg_1_5]
		push qword [Arg_1_4]
		push qword [Arg_1_3]
		push qword [Arg_1_2]
		push qword [Arg_1_1]
		push Format_str_1
		call printf
		add rsp, Stk_offset * 7

		push qword [NewLine]
		push qword [Arg_2_2]
		push qword [Arg_2_4]
		push Arg_2_3
		push qword [Arg_2_2]
		push Arg_2_1
		push Format_str_2
		call printf
		add rsp, Stk_offset * 7

		push qword [NewLine]
		push qword [Arg_3_6]
		push qword [NewLine]
		push qword [Arg_3_5]
		push qword [NewLine]
		push qword [Arg_3_4]
		push qword [NewLine]
		push qword [Arg_3_3]
		push qword [NewLine]
		push qword [Arg_3_1]
		push Format_str_3
		call printf
		add rsp, Stk_offset * 11

		push qword [NewLine]
		push qword [Arg_4_2]
		push qword [Arg_4_1]
		push Format_str_4
		call printf
		add rsp, Stk_offset * 4

		push qword [Arg_5_5]
		push qword [Arg_5_4]
		push qword [Arg_5_3]
		push qword [Arg_5_2]
		push Arg_5_1
		push Format_str_5
		call printf
		add rsp, Stk_offset * 6

		push Format_str_6
		call printf
		add rsp, Stk_offset

		push qword [NewLine]
		push qword [Arg_7_7]
		push qword [NewLine]
		push qword [Arg_7_6]
		push qword [NewLine]
		push qword [Arg_7_5]
		push qword [NewLine]
		push qword [Arg_7_4]
		push qword [NewLine]
		push qword [Arg_7_3]
		push qword [NewLine]
		push qword [Arg_7_1]
		push Format_str_7
		call printf
		add rsp, Stk_offset * 13

		push Arg_8_1
		push Format_str_8
		call printf
		add rsp, Stk_offset

		push qword [NewLine]
		push qword [Arg_9_4]
		push qword [NewLine]
		push qword [Arg_9_3]
		push qword [NewLine]
		push qword [Arg_9_2]
		push qword [NewLine]
		push qword [Arg_9_1]
		push qword [NewLine]
		push Format_str_9
		call printf
		add rsp, Stk_offset * 9

		mov rax, 0x3C
		xor rdi, rdi
		syscall 			;Exit (0)
		
		ret