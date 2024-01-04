.global _start

.section .data
file_name:    .asciz "archivo.txt"
buffer:       .space 1024

.section .text
_start:
    
    ldr r0, =file_name
    ldr r1, =O_RDONLY  
    mov r7, #5         
    svc 0              

    
    cmp r0, #0
    blt error_open

    
    mov r2, #1024       
    ldr r1, =buffer
    mov r7, #3          
    svc 0               

    
    cmp r0, #0
    blt error_read

    
    ldr r0, =buffer
    bl imprimir_cadena

    
    mov r0, r4          
    mov r7, #6          
    svc 0               

    
    mov r7, #1          
    mov r0, #0          
    svc 0               

error_open:
    
    mov r7, #4          
    ldr r0, =mensaje_error_open
    ldr r2, =longitud_error_open
    mov r1, #2          
    svc 0               
    b salir_programa

error_read:
    
    mov r7, #4          
    ldr r0, =mensaje_error_read
    ldr r2, =longitud_error_read
    mov r1, #2          
    svc 0               
    b salir_programa

imprimir_cadena:
    
    mov r7, #4          
    svc 0               
    bx lr

salir_programa:
    
    mov r7, #1          
    mov r0, #1          
    svc 0               

.section .data
mensaje_error_open:      .asciz "Error al abrir el archivo.\n"
longitud_error_open:     .equ . - mensaje_error_open

mensaje_error_read:      .asciz "Error al leer el archivo.\n"
longitud_error_read:     .equ . - mensaje_error_read
