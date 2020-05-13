;=====================================================
; This program draws a window size HEIGTH x LEN
; with left corner in (X,Y) point of screen
;=====================================================

locals @@
.model tiny

.code
org 100h

NL		equ 160d	; NewLine
X		equ 34d		; +--> x
Y		equ 17d 	; |
HEIGH		equ 5d		; v y
LEN		equ 21d		; Length
COLOR 		equ 2Fh
SHADOW_COLOR	equ 70h
SHADOW_OFFSET	equ 2d

Start:
		mov ax, 0B800h
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


		mov bx, 80d * Y + X
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

		mov al, '+'
		stosw

		mov cx, LEN
		shr cx, 1
		sub cx, 1
		mov al, 198d
		mov dl, 187d
		call WindowString

		mov al, 186d
		mov dh, 32d
		mov dl, 186d

		mov cx, HEIGH

	@@Repeat:
		push cx
		add bx, NL
		mov di, bx
		mov cx, LEN
		call WindowString
		pop cx
		loop @@Repeat

		mov cx, LEN
		add bx, NL
		mov di, bx
		mov al, 200d
		mov dh, 205d
		mov dl, 188d
		call WindowString

		ret


;=====================================================
; Writes one string of window in video memory
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

end		Start