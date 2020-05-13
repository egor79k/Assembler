.model tiny

.data
;Key reading:::::::::::::::::::::::::::::::
X		equ 34d
Y		equ 16d
COLOR 		equ 2Fh
EXIT_KEY	equ 41d
ASCII_OFFSET	equ 48d

file_name	db "log.txt", 0
Symb		db 0
Err1		db "File error!$"
count 		db 0

.code
org 100h

Start:		xor ax, ax
		mov es, ax			;Zeroing es

		cli				;Disable hardware interrupts
		mov bx, 36d			; es:[bx] -> int 09h in ISR Table
	
		mov ax, word ptr es:[bx]
		mov Old09, ax
		mov ax, word ptr es:[bx+2]
		mov Old09+2, ax			;Saving old value

		mov word ptr es:[bx], offset Handler
		mov ax, cs
		mov word ptr es:[bx + 2], ax	;Putting new value
		sti				;Enable hardware interrupts

		mov ax, 3100h
		mov dx, offset EndLabel
		shr dx, 4
		inc dx
		int 21h				;Terminate & Stay resident
		ret


;========================================================
; Takes keyboard scan codes
;========================================================

Handler		proc
		push ax bx cx dx di es	;Save current register's values
		
		mov ax, 0B800h		;Pushing video segment addr
		mov es, ax
		
		xor ax, ax
		in al, 60h		;Taking scan code of pushed key
		;cmp al, EXIT_KEY
		;je Stop
		or al, 128d		;Equaling key's push and release SC-s
		sub al, 128d
		
		mov cx, 10d
		xor dx, dx
		div cx			;Taking tens and units of scan code
		add al, ASCII_OFFSET
		mov di, Y * 80d + X
		shl di, 1		;Counting an addr in video memory
		mov ah, COLOR
		stosw			;Printint tens
		mov al, dl
		add al, ASCII_OFFSET
		mov [Symb], al
		stosw			;Printing units


		mov ah, 3Dh
		mov al, 1
		mov dx, offset file_name
		int 21h
		jc Error
		mov bx, ax

		mov ah, 40h
		mov cx, 1d
		mov dx, offset Symb
		int 21h

		mov ah, 42h
		mov al, 1d
		int 21h

		pop es di dx cx bx ax	;Recover old register's values
		
		db 0EAh			;Jmp
Old09		dw 0
		dw 0

		iret

		endp

Error:		mov ah, 09h
		mov dx, offset Err1
		int 21h
		ret		

EndLabel:
end		Start