global _start
extern printf

;section 	.data

section 	.text
_start:
		call printf
		ret