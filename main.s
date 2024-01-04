.global main

.section .data
filename: .asciz "archivo.txt"
entrada: .skip 500
format: .asciz "%s"

.section .text
main:
    MOV R0, #0
    LDR R1, =filename
    MOV R2, #0
    MOV R7, #5
    SVC 0
    MOV R4, R0

read_loop:
    MOV R0, R4
    LDR R1, =entrada
    MOV R2, #500
    MOV R7, #3
    SVC 0
    CMP R0, #0
    BEQ end_read

    LDR R0, =format
    LDR R1, =entrada
    BL printf
    B read_loop

end_read:
    MOV R7, #6
    SVC 0

    MOV R7, #1
    SVC 0
