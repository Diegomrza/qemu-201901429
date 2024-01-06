.global main

main:
    LDR R0, =filename
    MOV R1, #0
    MOV R2, #0
    MOV R7, #5 @Para escribir
    SVC 0

    LDR R1, =bufferascii
    MOV R2, #150
    MOV R7, #3 @Para mandarle aqui
    SVC 0

    LDR R4, = bufferascii 
    MOV R5, #0
    MOV R6, #10
    MOV R8, #0
    MOV R9, #0
    MOV R12, #0


while:
    LDRB R0, [R4], #1 
    CMP R0, #0
    BEQ end_of_file 
    CMP R0, #10 
    BEQ increment 
    SUB R0, R0, #48
    MUL R1,R9,R6
    ADD R9,R0,R1
    B while

increment:
    ADD R12, R12, #1
    ADD R5, R5, #1

    CMP R12,#2
    CMP R8,#0
    BEQ process_y

    LDR R0, =open
    MOV R1,R9
    MOV R2,R7
    BL printf

    MOV R9, #0
    MOV R6, #10
    B reset_flag

process_y:
    MOV R7,R9

reset_flag:
    EOR R8,R8,#1
    B while


end_of_file:
    MOV R7, #6 @cerrar archivo 
    SVC 0

    @LDR R0, =bufferascii
    @BL printf   

    LSR R5, R5, #1
    LSR R5, R5, #1

    VMOV S0, R5
    VCVT.F32.S32 S0, S0 @conversion 
    VSQRT.F32 S0,S0

    @VMOV R12, S0

    LDR R0,=coordenadas
    @MOV R1,R12

    VCVT.F64.F32 D0,S0 @conversion
    VMOV R2,R3,D0
    BL printf

    MOV R7, #1
    SVC 0

.data
filename: .asciz "archivo.txt"
bufferascii: .space 1024
coordenadas: .asciz "Numero de clusters: %f\n"
open: .asciz "(%d)\n"
close: .asciz ")"
newline: .asciz "\n"
comma: .asciz ","    
