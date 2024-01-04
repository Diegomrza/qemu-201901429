.global main

.section .data
num: .word 0
pat: .asciz "%d"

.section .text
main:
    MOV R2, #1

    LDR R0, =pat
    LDR R1, =num
    BL scanf

    LDR R1, [R1]
    CMP R1, #0
    BEQ enddo

do:
    MUL R2, R2, R1
    SUBS R1, R1, #1
    CMP R1, #0
    BNE do

enddo:
    MOV R0, R2
    BL printf
    BX LR