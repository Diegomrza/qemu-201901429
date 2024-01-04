.global main

main:
	LDR R0, =filename
	MOV R1, #0x42
	MOV R2, #384
	MOV R7, #5
	SVC 0

	LDR R1, =entrada
	MOV R2, #11
	MOV R7, #3
	SVC 0

	MOV R7, #6
	SVC 0

	LDR R0, =entrada
	BL printf

	MOV R7, #1
	SVC 0

.data
filename: .asciz "archivo.txt"
entrada: .skip 500
