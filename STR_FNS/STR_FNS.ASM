locals @@
.model tiny

public strlen
public strchr
public strcmp
public strcpy

.code
;==================================================
; Counts symbols num before EOF ('/0') in pointed string
; Entry: DS:[DI] - string addr
; Exit:	 CX - symbols num
; Destr: CX AL DI
;==================================================

strlen		proc far
		cld
		mov al, 0
		mov cx, 0FFFFh
		repne scasb
		mov ax, 0FFFFh
		sub ax, cx
		mov cx, ax
		ret
endp


;==================================================
; Finds symbol in pointed string before '/0'
; Entry: DS:[DI] - string addr
;	 AL - desired symbol
; Exit:	 DS:[DI]-> symbol addr or 0 if no such symbol
; Destr: CX
;==================================================

strchr		proc far
		push ax di
		call strlen
		pop di ax

		repne scasb
		je @@Finded
		mov di, 0
		ret
@@Finded:
		dec di
		ret
		endp


;============================================
; Compares two arrays (strings) before '/0'
; Entry: DS:[SI] - first string addr
;	 DS:[DI] - second string addr
; Exit:	 AH - compare result: =0 - equal, >0 - first > second, <0 - second > first
; Destr: CX
;============================================

strcmp		proc far
		push ax di
		call strlen
		pop di ax

		repe cmpsb
		ja Above
		jb Below

		mov ah, 0
		ret

Above:		mov ah, 1
		ret

Below:		mov ah, -1
		ret
		endp


;============================================
; Copies first array before '\0' to pointed address
; Entry: DS:[SI] - first array addr (from)
;	 DS:[DI] - second array addr (to)
; Desrt: DI SI
;============================================

strcpy		proc far
		push ax di
		call strlen
		pop di ax

		rep movsb
		ret
		endp


end