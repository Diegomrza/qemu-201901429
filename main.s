.global main
.global kmeans
.global read_coordinates

.section .data


.section .text
main:
    ldr r0, =file_path
    bl read_coordinates

    ldr r0, =coor_array
    ldr r1, =k_value
    ldr r2, =max_iters
    ldr r3, =tolerance

    bl kmeans

    @ Ahora r0 contiene la dirección de los centroides ordenados
    @ Puedes imprimir los resultados o realizar otras operaciones

    mov r7, #1   @ Syscall para salir del programa
    swi 0

kmeans:
    @ Código de kmeans (igual al ejemplo anterior)

read_coordinates:
    @ Argumentos:
    @ r0 - Dirección del buffer para almacenar las coordenadas leídas

    ldr r1, =file_path

    @ Syscall para abrir el archivo
    mov r7, #5     @ Código de la llamada al sistema para open
    mov r2, #0     @ Modo de apertura (lectura)
    swi 0

    mov r4, r0     @ r4 contiene el descriptor de archivo abierto

    @ Verifica si hubo errores al abrir el archivo
    cmp r4, #0
    blt file_error

    @ Syscall para leer desde el archivo
    mov r7, #3     @ Código de la llamada al sistema para read
    ldr r0, =coor_array
    ldr r1, =12     @ Número total de bytes para leer (6 pares de coordenadas * 2 bytes cada uno)
    swi 0

    @ Syscall para cerrar el archivo
    mov r7, #6     @ Código de la llamada al sistema para close
    mov r0, r4     @ Descriptor de archivo
    swi 0

    bx lr

file_error:
    mov r0, #0     @ Establece r0 en 0 (dirección del buffer)
    bx lr

.data
coor_array:    .word 6      @ Reserva espacio para almacenar las coordenadas (3 pares)
k_value:       .word 2      @ Número de clústeres
max_iters:     .word 100    @ Máximo de iteraciones
tolerance:     .float 1e-4  @ Tolerancia

file_path:     .asciz "coordenadas.txt"

