.section .text
.global leer_coordenadas
.global kmeans
.global actualizar_centroides
.global asignar_clusters
.global distancia_manhattan

.section .data
max_iters: .word 100
tolerance: .float 0.0001

.section .data
filename:      .asciz "r"
file_descriptor: .word 0

.section .data
float_format:  .asciz "%f"
coord_format:  .asciz " %f %f"

.section .data
coordenadas:   .skip 256    @ espacio para almacenar coordenadas

.section .bss
buffer:   .skip 64         @ buffer para almacenar temporales


;;;;;;
.section .data
filename:      .asciz "coordenadas.txt"

.section .text
.global main

main:
    @ llama a la función leer_coordenadas
    ldr r0, =filename
    bl leer_coordenadas

    @ verifica si se leyeron coordenadas
    cmp r0, #0
    beq end_program

    @ establece el número de clústeres utilizando la ecuación proporcionada
    ldr r1, [r0]           @ carga la dirección de coordenadas en r1
    ldr r1, [r1]           @ carga la primera coordenada (asumiendo que está en el formato adecuado)
    ldr r2, =coord_format  @ carga el formato de cadena para coordenadas (" %f %f")
    ldr r3, =k             @ carga la dirección de la variable para el número de clústeres
    bl sscanf              @ llama a la función sscanf para convertir el texto a un número entero

    @ llama a la función kmeans
    ldr r0, [r0]           @ carga la dirección de coordenadas en r0
    ldr r1, =k             @ carga la dirección de la variable para el número de clústeres
    bl kmeans

end_program:
    @ finaliza el programa
    mov r7, #1             @ syscall exit
    mov r0, #0             @ código de salida 0
    swi 0

.section .data
k: .word 0


; distancia_manhattan:
distancia_manhattan:
    @ entrada:
    @   r0 = p1[0]
    @   r1 = p1[1]
    @   r2 = p2[0]
    @   r3 = p2[1]

    @ guarda el estado actual de lr (registro de enlace)
    push {lr}

    @ calcula abs(p1[0] - p2[0])
    sub r4, r0, r2
    cmp r4, #0
    blt neg_p1_p2_0
    bgt pos_p1_p2_0
    b abs_done_0

neg_p1_p2_0:
    neg r4, r4
    b abs_done_0

pos_p1_p2_0:
    abs_done_0:

    @ guarda el resultado temporal en r0
    mov r0, r4

    @ calcula abs(p1[1] - p2[1])
    sub r4, r1, r3
    cmp r4, #0
    blt neg_p1_p2_1
    bgt pos_p1_p2_1
    b abs_done_1

neg_p1_p2_1:
    neg r4, r4
    b abs_done_1

pos_p1_p2_1:
    abs_done_1:

    @ suma las dos diferencias
    add r0, r0, r4

    @ restaura el estado de lr
    pop {lr}

    bx lr    @ retorna con el valor en r0


; asignar_clusters:

asignar_clusters:
    @ entrada:
    @   r0 = dirección de coordenadas
    @   r1 = dirección de centroides
    @   r2 = número de coordenadas (longitud de la lista)
    @   r3 = número de centroides
    @   r4 = dirección de la función distancia_manhattan

    @ guarda el estado actual de los registros
    push {r4, r5, r6, r7, lr}

    mov r5, #0             @ r5 = índice de la coordenada actual
outer_loop:
    cmp r5, r2             @ compara el índice con la longitud de la lista
    bge end_asignar_clusters

    ldr r6, [r0, r5, LSL #3]  @ carga la coordenada actual (suponiendo que cada punto ocupa 8 bytes)
    mov r7, #0             @ r7 = índice del centroide actual
    mov r8, #0             @ r8 = distancia mínima (inicializada como infinito)
    mov r9, #-1            @ r9 = cluster asignado

inner_loop:
    cmp r7, r3             @ compara el índice con el número de centroides
    bge end_inner_loop

    ldr r10, [r1, r7, LSL #3]  @ carga el centroide actual (suponiendo que cada centroide ocupa 8 bytes)
    bl distancia_manhattan  @ llama a la función distancia_manhattan
    cmp r11, r8            @ compara la distancia con la mínima actual
    bge not_smaller

    mov r8, r11            @ actualiza la distancia mínima
    mov r9, r7             @ actualiza el cluster asignado

not_smaller:
    add r7, r7, #1         @ incrementa el índice del centroide
    b inner_loop

end_inner_loop:
    str r9, [r0, r5, LSL #2]  @ almacena el cluster asignado en el resultado (suponiendo que cada label es un entero de 4 bytes)
    add r5, r5, #1         @ incrementa el índice de la coordenada
    b outer_loop

end_asignar_clusters:
    @ restaura el estado de los registros y retorna
    pop {r4, r5, r6, r7, pc}

; actualizar_centroides:

actualizar_centroides:
    @ entrada:
    @   r0 = dirección de coordenadas
    @   r1 = dirección de labels
    @   r2 = número de coordenadas (longitud de la lista)
    @   r3 = número de clústeres (k)
    @   r4 = dirección de nuevos_centroides

    @ guarda el estado actual de los registros
    push {r4, r5, r6, r7, r8, r9, lr}

    mov r5, #0             @ r5 = índice del clúster actual
outer_loop:
    cmp r5, r3             @ compara el índice con el número de clústeres
    bge end_actualizar_centroides

    mov r6, #0             @ r6 = suma_x
    mov r7, #0             @ r7 = suma_y
    mov r8, #0             @ r8 = count

    mov r9, #0             @ r9 = índice de la coordenada actual
inner_loop:
    cmp r9, r2             @ compara el índice con la longitud de la lista
    bge end_inner_loop

    ldr r10, [r1, r9, LSL #2]  @ carga el label actual (suponiendo que cada label es un entero de 4 bytes)
    cmp r10, r5            @ compara el label con el clúster actual
    bne not_equal

    ldr r11, [r0, r9, LSL #3]  @ carga la coordenada actual (suponiendo que cada punto ocupa 8 bytes)
    add r6, r6, r11        @ suma la coordenada x al total de suma_x
    add r9, r9, #1         @ incrementa el índice de la coordenada

    ldr r11, [r0, r9, LSL #3]  @ carga la coordenada actual (suponiendo que cada punto ocupa 8 bytes)
    add r7, r7, r11        @ suma la coordenada y al total de suma_y

    add r8, r8, #1         @ incrementa count
    b inner_loop

not_equal:
    add r9, r9, #1         @ incrementa el índice de la coordenada
    b inner_loop

end_inner_loop:
    cmp r8, #0             @ verifica si count es mayor que cero
    beq end_outer_loop     @ si count es cero, salta al final del bucle externo

    mov r11, r8, LSL #1    @ r11 = count * 2 (para calcular el promedio)
    sdiv r6, r6, r11       @ divide suma_x por count
    sdiv r7, r7, r11       @ divide suma_y por count

    str r6, [r4, r5, LSL #3]  @ almacena el nuevo centroide x (suponiendo que cada nuevo centroide ocupa 8 bytes)
    str r7, [r4, r5, LSL #3], #4  @ almacena el nuevo centroide y (suponiendo que cada nuevo centroide ocupa 8 bytes)

end_outer_loop:
    add r5, r5, #1         @ incrementa el índice del clúster
    b outer_loop

end_actualizar_centroides:
    @ restaura el estado de los registros y retorna
    pop {r4, r5, r6, r7, r8, r9, pc}

;


kmeans:
    @ entrada:
    @   r0 = dirección de coordenadas
    @   r1 = número de coordenadas (longitud de la lista)
    @   r2 = número de clústeres (k)
    @   r3 = dirección de centroides
    @   r4 = dirección de nuevos_centroides
    @   r5 = dirección de asignar_clusters
    @   r6 = dirección de actualizar_centroides
    @   r7 = dirección de distancia_manhattan

    ldr r8, =max_iters     @ carga el número máximo de iteraciones
    ldr r9, =tolerance     @ carga la tolerancia

    bl random_sample       @ llama a la función random.sample para obtener centroides iniciales

    mov r10, r8            @ r10 = max_iters (contador de iteraciones)
iter_loop:
    cmp r10, #0            @ compara el contador con 0
    ble end_kmeans         @ si es menor o igual a cero, salta al final

    blx r5                 @ llama a asignar_clusters
    blx r6                 @ llama a actualizar_centroides

    mov r11, r4           @ r11 = dirección de nuevos_centroides
    mov r12, r3           @ r12 = dirección de centroides
    mov r13, r7           @ r13 = dirección de distancia_manhattan
    mov r14, r9           @ r14 = tolerancia
    bl convergencia_check  @ llama a la función convergencia_check

    cmp r0, #0            @ compara el resultado de convergencia_check con 0
    bne end_kmeans        @ si es diferente de cero, salta al final

    mov r3, r11           @ actualiza la dirección de centroides con la de nuevos_centroides
    sub r10, r10, #1      @ decrementa el contador de iteraciones
    b iter_loop

end_kmeans:
    bx lr                 @ retorna

.section .text
.global convergencia_check

convergencia_check:
    @ entrada:
    @   r11 = dirección de nuevos_centroides
    @   r12 = dirección de centroides
    @   r13 = dirección de distancia_manhattan
    @   r14 = tolerancia

    @ guarda el estado actual de los registros
    push {r4, r5, r6, r7, r8, lr}

    mov r4, r11            @ r4 = dirección de nuevos_centroides
    mov r5, r12            @ r5 = dirección de centroides
    mov r6, r13            @ r6 = dirección de distancia_manhattan
    mov r7, r14            @ r7 = tolerancia

    mov r8, #0             @ r8 = índice
    mov r9, #0             @ r9 = convergencia (inicializada como verdadera)

convergencia_loop:
    ldr r10, [r4, r8, LSL #3]  @ carga el nuevo centroide actual (suponiendo que cada nuevo centroide ocupa 8 bytes)
    ldr r11, [r5, r8, LSL #3]  @ carga el centroide actual (suponiendo que cada centroide ocupa 8 bytes)
    ldr r12, [r6, r8, LSL #2]  @ carga la distancia entre centroides actual (suponiendo que cada distancia es un float de 4 bytes)

    bl distancia_manhattan  @ llama a la función distancia_manhattan
    cmp r0, r7             @ compara la distancia con la tolerancia
    bge not_small_enough   @ si es mayor o igual a la tolerancia, salta a not_small_enough

    b convergencia_done    @ si llega aquí, los centroides son lo suficientemente cercanos, salta a convergencia_done

not_small_enough:
    mov r9, #1             @ actualiza la convergencia a falso
    b convergencia_done

convergencia_done:
    add r8, r8, #1         @ incrementa el índice
    cmp r8, r2             @ compara el índice con el número de clústeres
    bne convergencia_loop  @ si no ha terminado, vuelve a convergencia_loop

    @ restaura el estado de los registros y retorna
    pop {r4, r5, r6, r7, r8, pc}


; leer_coordenadas:
leer_coordenadas:
    @ entrada:
    @   r0 = dirección de la cadena que contiene la ruta del archivo

    @ guarda el estado actual de los registros
    push {r4, r5, r6, r7, r8, r9, r10, r11, lr}

    ldr r4, =buffer         @ carga la dirección del buffer
    mov r5, r0              @ r5 = dirección de la cadena que contiene la ruta del archivo

    @ llama a la función fopen
    ldr r6, =filename       @ carga la dirección de la cadena "r"
    ldr r7, =file_descriptor @ carga la dirección de la variable para el descriptor de archivo
    bl fopen

    cmp r7, #0              @ verifica si fopen fue exitoso
    beq end_leer_coordenadas @ si no, salta al final

read_loop:
    ldr r8, [r7, #0]        @ carga un caracter del archivo
    cmp r8, #10             @ compara el caracter con el salto de línea '\n'
    beq end_read_loop       @ si es un salto de línea, salta al final

    strb r8, [r4], #1       @ almacena el caracter en el buffer y avanza la posición en el buffer

    b read_loop

end_read_loop:
    mov r9, #0              @ r9 = índice del buffer
    ldr r10, =coordenadas   @ carga la dirección de la lista de coordenadas

parse_loop:
    ldrb r11, [r4, r9]      @ carga un byte del buffer
    cmp r11, #0             @ compara el byte con el final de la cadena '\0'
    beq end_parse_loop      @ si es el final de la cadena, salta al final

    bl is_whitespace        @ llama a la función is_whitespace para verificar si es un espacio en blanco
    cmp r0, #0              @ compara el resultado de is_whitespace con 0
    bne skip_whitespace     @ si no es un espacio en blanco, salta a skip_whitespace

    ldr r11, =float_format  @ carga el formato de cadena para float ("%f")
    ldr r12, =coord_format  @ carga el formato de cadena para coordenadas (" %f %f")
    ldr r13, =coordenadas   @ carga la dirección de la lista de coordenadas

    bl sscanf               @ llama a la función sscanf para convertir el texto a números de punto flotante
    cmp r0, #2              @ compara el número de conversiones exitosas con 2
    bne end_parse_loop      @ si no son 2 conversiones exitosas, salta al final

    ldr r13, =coordenadas   @ carga la dirección de la lista de coordenadas
    bl append_coordinate    @ llama a la función append_coordinate para agregar las coordenadas a la lista

skip_whitespace:
    add r9, r9, #1          @ avanza al próximo byte en el buffer
    b parse_loop

end_parse_loop:
    @ llama a la función fclose para cerrar el archivo
    ldr r6, =file_descriptor
    bl fclose

end_leer_coordenadas:
    @ restaura el estado de los registros y retorna
    pop {r4, r5, r6, r7, r8, r9, r10, r11, lr}
    bx lr


