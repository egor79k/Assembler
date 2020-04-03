global _start

section .data
password	db "password"
pswd_len	equ $ - password

instruction	db 10, "Enter the password: "
instruction_len equ $ - instruction

right_pswd	db 10, "Access is allowded!", 10
right_pswd_len	equ $ - right_pswd

wrong_pswd	db 10, "Access denied!", 10
wrong_pswd_len 	equ $ - wrong_pswd


section .bss
buffer		resb 20
buffer_len	equ $ - buffer


section .text
_start:
		mov rsi, instruction
		mov rdx, instruction_len
		call Print_str
		xor rbx, rbx
.Repeat:
		mov rax, 0x00
		mov rdi, 1
		mov rsi, buffer + rbx
		mov rdx, 1
		syscall
		cmp buffer[rbx], 13
		je Stop
		inc rbx
		cmp rbx, buffer_len
		jbe .Repeat
Stop:
		cmp rbx, pswd_len
		jne Wrong
		mov rcx, rbx
		mov rsi, offset buffer
		mov rdi, offset password
		repe cmpsb
		jne Wrong
		je Right
		ret

Right:
		mov rsi, right_pswd
		mov rdx, right_pswd_len
		call Print_str
		ret

Wrong:
		mov rsi, wrong_pswd
		mov rdx, wrong_pswd_len
		call Print_str
		ret


Print_str:	
		mov rax, 0x01
		mov rdi, 1
		syscall
		ret

end 		_start
