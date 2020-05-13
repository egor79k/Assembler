locals @@
.186
.model tiny

.data
;Window::::::::::::::::::::::::::::::::::::
NL		equ 160d	; NewLine
X		equ 66d		; +--> x
Y		equ 1;		; |
HEIGH		equ 15d		; v y
LEN		equ 7d		; Length
COLOR 		equ 2Fh
SHADOW_COLOR	equ 70h
SHADOW_OFFSET	equ 1d

.code
org 100h

Start:
Old08h		dd 0

		xor ax, ax
		mov es, ax						;Zeroing es

		cli								;Disable hardware interrupts
		mov bx, 36d						; es:[bx] -> int 09h in ISR Table
	
		mov ax, word ptr es:[bx]
		mov Old09, ax
		mov ax, word ptr es:[bx+2]
		mov Old09+2, ax					;Saving old value

		mov word ptr es:[bx], offset New09h
		mov ax, cs
		mov word ptr es:[bx + 2], ax	;Putting new value

		mov bx, 32d						; es:[bx] -> int 08h in ISR Table
	
		mov ax, word ptr es:[bx]
		mov word ptr Old08h, ax
		mov ax, word ptr es:[bx+2]
		mov word ptr Old08h+2, ax		;Saving old value

		mov word ptr es:[bx], offset New08h
		mov ax, cs
		mov word ptr es:[bx + 2], ax	;Putting new value
		sti								;Enable hardware interrupts

		mov ax, 3100h
		mov dx, offset EndLabel
		shr dx, 4
		inc dx
		int 21h							;Terminate & Stay resident
		ret

HEX_BUFF		db "0123456789ABCDEF"
Regs_names 		db "SSESDSSPBPDISIDXCXBXAXRegView"

;========================================================
; Prints register's values
;========================================================

New08h		proc
		pusha
		push di es

		push ss es ds sp bp di si dx cx bx ax

		mov cx, 0B800h
		mov es, cx
		mov ah, COLOR
		mov di, (Y + 2) * 80d + X + LEN / 2 - 2
		shl di, 1
		mov cx, 11d

@@Repeat:
		mov bx, cx
		shl bx, 1
		mov al, byte ptr cs:[Regs_names[bx-2]]
		stosw
		mov al, byte ptr cs:[Regs_names[bx-1]]
		stosw
		mov al, ':'
		stosw

		pop bx 
		mov al, bh
		call Print_number
		mov al, bl
		call Print_number
		add di, 92h
		loop @@Repeat

		mov al, 20h
		out 20h, al

		;pop cx dx si di bp sp ds es ss

		pop es di
		popa
;		db 0EAh
;Old08		dw 0
;		dw 0

		iret
		endp


;========================================================
; Takes keyboard scan codes
;========================================================

New09h		proc
		push ax bx cx dx di es	;Save current register's values
		
		call Draw		;Drawing the window
		
		xor ax, ax
		in al, 60h		;Taking scan code of pushed key
		or al, 128d		;Equaling key's push and release SC-s
		sub al, 128d
		
		mov di, (Y + HEIGH - 1) * 80d + X + LEN / 2 + 3
		shl di, 1
		call Print_number
		
		pop es di dx cx bx ax	;Recover old register's values
		
		db 0EAh			;Jmp
Old09		dw 0
		dw 0

		iret

		endp


;=====================================================
; Writes hex number
; Entry: AL - number
;		 DI - (start row * 80d + start coloumn) * 2
; Destr: 
;=====================================================
Print_number	proc
		push cx
		mov cx, 0B800h
		mov es, cx

		mov cx, 10h
		xor ah, ah
		xor dx, dx
		div cx
		xor bx, bx
		mov bl, al
		mov al, byte ptr cs:[HEX_BUFF[bx]]
		mov ah, COLOR
		stosw
		mov bl, dl
		mov al, byte ptr cs:[HEX_BUFF[bx]]
		stosw
pop cx
		ret
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
		sub cx, 1
		mov al, 201d
		mov dh, 205d
		mov dl, 181d
		call WindowString

		mov al, 'R'		;Window header
		stosw

		mov cx, LEN		;Next half of first line
		shr cx, 1
		sub cx, 1
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