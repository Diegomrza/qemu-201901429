import random

def distancia_manhattan(p1, p2):
    return abs(p1[0] - p2[0]) + abs(p1[1] - p2[1])

def asignar_clusters(coordenadas, centroides):
    labels = []
    for punto in coordenadas:
        min_distancia = float('inf')  # Inicializa la distancia mínima como infinito
        cluster_asignado = -1  # Inicializa el cluster asignado como -1
        i = 0  # Inicializa el contador
        for centroide in centroides:
            distancia = distancia_manhattan(punto, centroide)
            if distancia < min_distancia:  # Si la distancia es menor que la mínima actual
                min_distancia = distancia  # Actualiza la distancia mínima
                cluster_asignado = i  # Actualiza el cluster asignado
            i += 1  # Incrementa el contador
        labels.append(cluster_asignado)
    return labels

def actualizar_centroides(coordenadas, labels, k):
    nuevos_centroides = []
    for j in range(k):
        suma_x, suma_y, count = 0, 0, 0
        for i in range(len(coordenadas)):
            if labels[i] == j:
                suma_x += coordenadas[i][0]
                suma_y += coordenadas[i][1]
                count += 1
        if count > 0:
            nuevo_centroide = (suma_x / count, suma_y / count)
            nuevos_centroides.append(nuevo_centroide)
    return nuevos_centroides

def kmeans(coordenadas, k, max_iters=100, tol=1e-4):
    centroides = random.sample(coordenadas, k)

    for _ in range(max_iters):
        labels = asignar_clusters(coordenadas, centroides)
        nuevos_centroides = actualizar_centroides(coordenadas, labels, k)

        convergencia = True
        for i in range(len(nuevos_centroides)):
            if distancia_manhattan(nuevos_centroides[i], centroides[i]) >= tol:
                convergencia = False
                break

        if convergencia:
            break

        centroides = nuevos_centroides

    return centroides, labels

def leer_coordenadas(archivo):
    coordenadas = []
    with open(archivo, 'r') as f:
        while True:
            linea_x = f.readline().strip()
            linea_y = f.readline().strip()
            if linea_x and linea_y:  # Verifica si las líneas no están vacías
                try:
                    x = float(linea_x)
                    y = float(linea_y)
                    coordenadas.append((x, y))
                except ValueError:
                    print(f"Error al leer las líneas: {linea_x}, {linea_y}. Se esperaban números.")
            else:
                break
    return coordenadas

# Uso del algoritmo
coordenadas = leer_coordenadas('coordenadas.txt')
if coordenadas:  # Verifica si se leyeron coordenadas
    k = 2
    centroides_finales, labels = kmeans(coordenadas, k)

    # Resultados
    print("Centroides finales:", centroides_finales)
    print("Asignación de clústeres:", labels)
else:
    print("No se leyeron coordenadas del archivo.")