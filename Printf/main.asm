global _start
extern printf

section 	.data
Format_str_1 	db "This is the great test string%c A[%d] %c %d | (%d)%c", 0
Arg_1_1		db '!'
Arg_1_2		dd 25
Arg_1_3		db '='
Arg_1_4		dd 1234567890
Arg_1_5		dd 2
Arg_1_6		db 10	;'/n'

Format_str_2	db "%s%c %s number %d%c%c", 0
Arg_2_1		db "The second test string", 0
Arg_2_2		db '!'
Arg_2_3		db "It's really", 0
Arg_2_4		dd 2
Arg_2_5		db 10	;'/n'

Format_str_3 	db "%d-d test. Testing printf again...%c%x%c%x%c%x%c%x%c", 0
Arg_3_1		dd 3
Arg_3_2		dd 10	;'/n'
Arg_3_3		dd 0x2F5ED7C0
Arg_3_4		dd 1024
Arg_3_5		dd 0xA51BB
Arg_3_6		dd 256

Format_str_4 	db "%o%% or %o%% that it's last test.%c", 0
Arg_4_1		dd 100q
Arg_4_2		dd 50
Arg_4_3		dd 10	;'/n'


section 	.text
_start:		
		push Arg_1_6
		push Arg_1_5
		push Arg_1_4
		push Arg_1_3
		push Arg_1_2
		push Arg_1_1
		push Format_str_1
		call printf

		push Arg_2_5
		push Arg_2_2
		push Arg_2_4
		push Arg_2_3
		push Arg_2_2
		push Arg_2_1
		push Format_str_2
		call printf

		push Arg_3_2
		push Arg_3_6
		push Arg_3_2
		push Arg_3_5
		push Arg_3_2
		push Arg_3_4
		push Arg_3_2
		push Arg_3_3
		push Arg_3_2
		push Arg_3_1
		push Format_str_3
		call printf

		push Arg_4_3
		push Arg_4_2
		push Arg_4_1
		push Format_str_4
		call printf

		mov rax, 0x3C
		xor rdi, rdi
		syscall 			;Exit (0)
		
		ret