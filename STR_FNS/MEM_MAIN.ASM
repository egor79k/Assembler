locals @@
.model tiny

.data
CR			equ 13
LF			equ 10
CRLF			equ CR, LF

NL		db CRLF, '$'

Memchr_start	db CRLF, "memchr testing...", CRLF, '$'
Memcmp_start	db CRLF, "memcmp testing...", CRLF, '$'
Memset_start	db CRLF, "memset testing...", CRLF, '$'
Memcpy_start	db CRLF, "memcpy testing...", CRLF, '$'

;TESTING STRINGS:
Array_1		db "This is long test string!$"
Array_2		db "This is long test string!$"
Array_3		db "Medium test string$"
Array_4		db "Short string$"


.code
org 100h

extrn 		memchr:far
extrn		memcmp:far
extrn		memset:far
extrn		memcpy:far

Start:		
	;MEMCHR TEST...
		mov dx, offset Memchr_start
		mov ah, 09h
		int 21h

		mov di, offset Array_1
		mov al, '!'
		mov cx, 25d
		call memchr

		call Results_memchr

		mov di, offset Array_3
		mov al, 'A'
		mov cx, 18d
		call memchr

		call Results_memchr

		mov di, offset Array_4
		mov al, 'h'
		mov cx, 12d
		call memchr

		call Results_memchr



	;MEMCMP TEST...
		mov dx, offset Memcmp_start
		mov ah, 09h
		int 21h

		mov si, offset Array_1
		mov di, offset Array_2
		mov cx, 24d
		call memcmp

		call Results_memcmp

		mov si, offset Array_3
		mov di, offset Array_2
		mov cx, 17d
		call memcmp

		call Results_memcmp

		mov si, offset Array_4
		mov di, offset Array_3
		mov cx, 11d
		call memcmp

		call Results_memcmp


	;MEMSET TEST...
		mov dx, offset Memset_start
		mov ah, 09h
		int 21h

		mov di, offset Array_1
		mov cx, 10d
		mov ax, '%'
		call memset

		mov dx, offset Array_1
		mov ah, 09h
		int 21h
		call NewLine

		mov di, offset Array_4
		mov cx, 3d
		mov ax, 1h
		call memset

		mov dx, offset Array_4
		mov ah, 09h
		int 21h
		call NewLine


	;MEMCPY TEST...
		mov dx, offset Memcpy_start
		mov ah, 09h
		int 21h

		mov si, offset Array_2
		mov di, offset Array_1
		mov cx, 7d
		call memcpy

		mov dx, offset Array_1
		mov ah, 09h
		int 21h
		call NewLine

		ret


Results_memcmp	proc
		mov dl, ah
		add dl, 30h
		mov ah, 02h
		int 21h
		call NewLine
		ret
endp	Results_memcmp


Results_memchr proc
		mov dl, [di]
		mov ah, 02h
		int 21h
		call NewLine
		ret
endp	Results_memchr


NewLine		proc
		mov dx, offset NL
		mov ah, 09h
		int 21h
		ret
endp		NewLine

end		Start