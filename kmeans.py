import random
import math
import matplotlib.pyplot as plt

# Lee las coordenadas desde un archivo de texto
def read_coordinates_from_file(file_path):
    coordinates = []
    with open(file_path, 'r') as file:
        for line in file:
            coordinates.append(float(line.strip()))
    return [(coordinates[i], coordinates[i+1]) for i in range(0, len(coordinates), 2)]

# Calcula la distancia euclidiana entre dos puntos
def euclidean_distance(point1, point2):
    return math.sqrt((point1[0] - point2[0])**2 + (point1[1] - point2[1])**2)

# Implementa el algoritmo k-means Lloyd
def kmeans_lloyd(data, k, max_iters=100, tol=1e-4):
    # Inicialización de centroides de forma aleatoria
    centroids = random.sample(data, k)
    
    for _ in range(max_iters):
        # Paso 1: Asignación de puntos a clusters
        labels = [min(range(k), key=lambda i: euclidean_distance(point, centroids[i])) for point in data]
        
        # Paso 2: Actualización de centroides
        new_centroids = [(sum(point[0] for point, label in zip(data, labels) if label == j) / labels.count(j),
                          sum(point[1] for point, label in zip(data, labels) if label == j) / labels.count(j))
                         for j in range(k)]
        
        # Verifica convergencia
        if all(euclidean_distance(new, old) < tol for new, old in zip(new_centroids, centroids)):
            break
        
        centroids = new_centroids
    
    return centroids, labels

# Ingresa la ruta del archivo de texto
file_path = input("Ingresa la ruta del archivo de texto: ")

# Lee las coordenadas desde el archivo de texto
data = read_coordinates_from_file(file_path)

# Ingresa el número de clusters
k = int(input("Ingresa el número de clusters (k): "))

# Ejecuta el algoritmo
centroids, labels = kmeans_lloyd(data, k)

# Imprime los centroides en la consola
print("Centroides:")
for centroid in centroids:
    print(f"({centroid[0]}, {centroid[1]})")

# Visualiza los resultados
plt.scatter([point[0] for point in data], [point[1] for point in data], c=labels, s=50, cmap='viridis')
plt.scatter([centroid[0] for centroid in centroids], [centroid[1] for centroid in centroids], c='red', s=200, marker='X', label='Centroides')
plt.title("Resultados de k-means Lloyd sin bibliotecas externas")
plt.legend()
plt.show()
