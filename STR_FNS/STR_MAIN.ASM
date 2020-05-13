locals @@
.model tiny

.data
CR			equ 13
LF			equ 10
CRLF			equ CR, LF

NL		db CRLF, '$'

Strlen_start	db CRLF, "strlen testing...", CRLF, '$'
Strchr_start	db CRLF, "strchr testing...", CRLF, '$'
Strcmp_start	db CRLF, "strcmp testing...", CRLF, '$'
Strcpy_start	db CRLF, "strcpy testing...", CRLF, '$'

;TESTING STRINGS:
Array_1		db "This is long test string!", 0, '$'
Array_2		db "This is long test string!", 0
Array_3		db "Medium test string$", 0
Array_4		db "Short string$", 0


.code
org 100h

extrn		strlen:far
extrn 		strchr:far
extrn		strcmp:far
extrn		strcpy:far

Start:		
	;STRLEN TEST...
		mov dx, offset Strlen_start
		mov ah, 09h
		int 21h

		mov di, offset Array_1
		call strlen


	;STRCHR TEST...
		mov dx, offset Strchr_start
		mov ah, 09h
		int 21h

		mov di, offset Array_1
		mov al, '!'
		call strchr

		call Results_strchr

		mov di, offset Array_3
		mov al, 'A'
		call strchr

		call Results_strchr

		mov di, offset Array_4
		mov al, 'h'
		call strchr

		call Results_strchr


	;STRCMP TEST...
		mov dx, offset Strcmp_start
		mov ah, 09h
		int 21h

		mov di, offset Array_1
		mov si, offset Array_2
		call strcmp

		call Results_strcmp

		mov di, offset Array_3
		mov si, offset Array_2
		call strcmp

		call Results_strcmp

		mov di, offset Array_4
		mov si, offset Array_3
		call strcmp

		call Results_strcmp


	;STRCPY TEST...
		mov dx, offset Strcpy_start
		mov ah, 09h
		int 21h

		mov si, offset Array_1
		mov di, offset Array_2
		call strcpy

		mov dx, offset Array_2
		mov ah, 09h
		int 21h
		call NewLine

		ret


Results_strcmp	proc
		mov dl, ah
		add dl, 30h
		mov ah, 02h
		int 21h
		call NewLine
		ret
endp	Results_strcmp


Results_strchr proc
		mov dl, [di]
		mov ah, 02h
		int 21h
		call NewLine
		ret
endp	Results_strchr


NewLine		proc
		mov dx, offset NL
		mov ah, 09h
		int 21h
		ret
endp		NewLine

end		Start
