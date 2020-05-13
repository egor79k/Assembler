.model tiny
.186
.data
Count	dw 1
Buf		db 50d
File_Name	db "log.txt", 0
Tester	dw 1

.code
org 100h

Start:

Old28h		dd	0

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

File_err:
		mov ah, 09h
		mov dx, offset File_err
		int 21h
		ret

New28h	proc
		pusha
		push es ds

		cmp [Tester], 0
		je Out28h

		mov	ah, 3dh			;Opening file
		mov	al, 1
		mov	dx, offset File_Name
		int	21h
		jc File_err

		mov	bx, ax
		mov	ah, 40h			;Writing buffer into file
		mov	cx, Count
		mov	dx, offset Buf
		int	21h

		mov	ax, 3eh			;Closing file
		int	21h

		mov [Tester], 0
Out28h:
		pop ds es
		popa
		iret
		endp
EndLabel:
end 	Start