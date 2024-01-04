.global main

main:

	do:
		LDR R0, =pat
		LDR R1, =num
		BL scanf

		LDR R1, =num
		LDR R1, [R1]
		CMP R1, #0
		BEQ enddo
		MOV R2, #1

	while:
		CMP R1, #1
		BEQ endwhile
		MUL R3, R2, R1
		MOV R2, R3
		SUB R1, R1, #1
		B while

	endwhile:
		LDR R0, =txt
		MOV R1, R2
		BL printf

		LDR R1, =num
		LDR R1, [R1]
		CMP R1, #0
		BNE do

	enddo:
		MOV R7, #1
		MOV R0, #0
		SVC 0

.data
pat: .asciz "%d"
num: .word 0
txt: .asciz "factorial = %d\n"
