locals @@
.model tiny

public memchr
public memcmp
public memset
public memcpy

.code
;============================================
; Finds symbol address in string
; Entry: CX - symbols num
;	 Al - symbol to find
;	 DS:[DI] - string addr
; Exit:	 DS:[BX] -> first finded symbol or 0 if no such symbol
; Destr: CX AH 
;============================================

memchr		proc far
		repne scasb
		je @@Finded
		mov di, 0
		ret
@@Finded:
		dec di
		ret
		endp


;============================================
; Compares two arrays (strings)
; Entry: CX - symbols num
;	 SI - first string addr
;	 DI - second string addr
; Exit:	 AH - compare result: =0 - equal, >0 - first > second, <0 - second > first
; Destr: CX
;============================================

memcmp		proc far
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
; Fills pointed array with one symbol
; Entry: CX - symbols num
;	 AL - symbol to fill
;	 DI - string addr
; Destr: CX DI
;============================================

memset		proc far
		rep stosb
		ret
		endp


;============================================
; Copies first array to pointed address
; Entry: CX - sympols num
;	 SI - first array addr (from)
;	 DI - second array addr (to)
; Desrt: CX BX BP AX
;============================================

memcpy		proc far
		rep movsb
		ret
		endp

end