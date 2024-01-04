.global _start

.section .data
file_name:    .asciz "archivo.txt"
buffer:       .space 1024

.section .text
_start:
    // Llamada al sistema para abrir el archivo
    ldr r0, =file_name
    ldr r1, =O_RDONLY  // Modo de apertura: solo lectura
    mov r7, #5         // Número de la llamada al sistema para open
    svc 0              // Realizar la llamada al sistema

    // Guardar el descriptor de archivo
    mov r4, r0

    // Verificar si hubo errores al abrir el archivo
    cmp r0, #0
    blt error_open

    // Llamada al sistema para leer el archivo
    mov r0, r4          // Usar el descriptor de archivo guardado
    mov r2, #1024       // Número de bytes a leer
    ldr r1, =buffer
    mov r7, #3          // Número de la llamada al sistema para read
    svc 0               // Realizar la llamada al sistema

    // Verificar si hubo errores al leer el archivo
    cmp r0, #0
    blt error_read

    // Imprimir el contenido del archivo
    ldr r0, =buffer
    bl imprimir_cadena

    // Llamada al sistema para cerrar el archivo
    mov r0, r4          // Utilizamos el descriptor de archivo devuelto por open
    mov r7, #6          // Número de la llamada al sistema para close
    svc 0               // Realizar la llamada al sistema

    // Salir del programa
    mov r7, #1          // Número de la llamada al sistema para exit
    mov r0, #0          // Código de salida 0
    svc 0               // Realizar la llamada al sistema

error_open:
    // Manejar error al abrir el archivo
    mov r7, #4          // Número de la llamada al sistema para write
    ldr r0, =mensaje_error_open
    ldr r2, =longitud_error_open
    mov r1, #2          // Canal de error estándar (stderr)
    svc 0               // Realizar la llamada al sistema
    b salir_programa

error_read:
    // Manejar error al leer el archivo
    mov r7, #4          // Número de la llamada al sistema para write
    ldr r0, =mensaje_error_read
    ldr r2, =longitud_error_read
    mov r1, #2          // Canal de error estándar (stderr)
    svc 0               // Realizar la llamada al sistema
    b salir_programa

imprimir_cadena:
    // Llamada al sistema para escribir una cadena
    mov r7, #4          // Número de la llamada al sistema para write
    svc 0               // Realizar la llamada al sistema
    bx lr

salir_programa:
    // Salir del programa con un código de error
    mov r7, #1          // Número de la llamada al sistema para exit
    mov r0, #1          // Código de salida 1
    svc 0               // Realizar la llamada al sistema

.section .data
mensaje_error_open:      .asciz "Error al abrir el archivo.\n"
longitud_error_open:     .equ 26

mensaje_error_read:      .asciz "Error al leer el archivo.\n"
longitud_error_read:     .equ 26