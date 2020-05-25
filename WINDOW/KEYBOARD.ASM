.model tiny

.data
;Window::::::::::::::::::::::::::::::::::::
NL		equ 160d	; NewLine
X		equ 34d		; +--> x
Y		equ 16d 	; |
HEIGH		equ 3d		; v y
LEN		equ 8d		; Length
COLOR 		equ 2Fh
SHADOW_COLOR	equ 70h
SHADOW_OFFSET	equ 1d

;Key reading:::::::::::::::::::::::::::::::
EXIT_KEY	equ 41d
ASCII_OFFSET	equ 48d

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
		
		call Draw		;Drawing the window
		
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
		mov di, (Y + HEIGH / 2 + 1) * 80d + X + LEN / 2
		shl di, 1		;Counting an addr in video memory
		mov ah, COLOR
		stosw			;Printint tens
		mov al, dl
		add al, ASCII_OFFSET
		stosw			;Printing units

		pop es di dx cx bx ax	;Recover old register's values
		
		db 0EAh			;Jmp
Old09		dw 0
		dw 0

		iret

		endp


;=====================================================
; Writes one string of window
; Entry: AH - color attr
;		 AL - first  symb
;		 DH - middle symb
;		 DL - last   symb 
;		 DI - start row * 80d + start coloumn
;		 CX - number of middle symbs
; Destr: AL DI CX
;=====================================================


WindowString	proc
		push 0B800h
		pop es
		stosw
		mov al, dh
		rep stosw
		mov al, dl
		stosw
		ret
endp		WindowString


;=====================================================
; Draws a window with pointed params
; Destr: AL CX BX DX DI
;=====================================================

Draw		proc
		mov ax, 0B800h		;Drawing shadow
		mov es, ax
		mov bx, (Y + SHADOW_OFFSET) * 80d + X + SHADOW_OFFSET
		shl bx, 1
		inc bx
		mov di, bx
		mov cx, HEIGH + 2d
		mov ah, SHADOW_COLOR
		@@Repeat1:
		push cx
		mov cx, LEN + 2d
		@@Repeat2:
		mov byte ptr es:[di], ah
		add di, 2d
		loop @@Repeat2
		add bx, NL
		mov di, bx
		pop cx
		loop @@Repeat1

		mov bx, Y * 80d + X	;Half of first line
		shl bx, 1
		mov di, bx
		mov ah, COLOR
		mov cx, LEN
		shr cx, 1
		sub cx, 2
		mov al, 201d
		mov dh, 205d
		mov dl, 181d
		call WindowString

		mov al, 'k'		;Window header
		stosw
		mov al, 'b'
		stosw

		mov cx, LEN		;Next half of first line
		shr cx, 1
		sub cx, 2
		mov al, 198d
		mov dl, 187d
		call WindowString

		mov al, 186d
		mov dh, 32d
		mov dl, 186d

		mov cx, HEIGH
@@Repeat:				;Drawing middle part of the window
		push cx
		add bx, NL
		mov di, bx
		mov cx, LEN
		call WindowString
		pop cx
		loop @@Repeat

		mov cx, LEN		;Drawing last line
		add bx, NL
		mov di, bx
		mov al, 200d
		mov dh, 205d
		mov dl, 188d
		call WindowString

		ret
endp		Draw

EndLabel:
end		Start