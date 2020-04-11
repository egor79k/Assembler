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

hash_seed 	equ $


section .bss
buffer		resb 20


section .text
%macro Print_str 2	
		mov rax, 0x01
		mov rdi, 1
		mov rsi, %1
		mov rdx, %2
		syscall
%endmacro


_start:
		Print_str instruction, instruction_len
		mov rsi, buffer
.loop:
		mov rax, 0x00
		mov rdi, 1
		mov rdx, 1
		syscall
		inc rsi
		cmp byte [rsi - 1], 10
		jne .loop
Stop:
		sub rsi, buffer + 1		;Check pswd length
		cmp rsi, pswd_len
		jne Wrong

		mov rcx, pswd_len			;Check pswd hash
		mov rsi, buffer
		call Count_hash
		mov rbx, rdx
		mov rsi, password
		mov rcx, pswd_len
		call Count_hash;
		cmp rdx, rbx
		jne Wrong

		mov rcx, pswd_len 		;Check pswd's symbols
		mov rsi, buffer
		mov rdi, password
		repe cmpsb
		jne Wrong
		je Right
		jmp End

Right:
		Print_str right_pswd, right_pswd_len
		jmp End

Wrong:
		Print_str wrong_pswd, wrong_pswd_len
		jmp End

End:
		mov rax, 0x3C
		xor rdi, rdi
		syscall
		ret


;===================================================
; Count hash of string
; Entry: RSI - string addr
;	 RCX - string len
; Exit:  RDX - hash 
; Destr: RAX RCX RSI
;===================================================
Count_hash:
		mov rdx, hash_seed
.Repeat:
		mov rax, rdx
		shl rdx, 5
		add rdx, rax
		xor rax, rax
		mov al, byte [rsi]
		xor rdx, rax
		inc rsi
		loop .Repeat
		ret