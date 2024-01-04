import random

def distancia_manhattan(p1, p2):
    return abs(p1[0] - p2[0]) + abs(p1[1] - p2[1])

def kmeans(coordenadas, k, max_iters=100, tol=1e-4):
    centroids = random.sample(coordenadas, k)

    for _ in range(max_iters):
        # Asignación de puntos a clusters
        labels = [min(range(k), key=lambda i: distancia_manhattan(p, centroids[i])) for p in coordenadas]

        # Actualización de centroides
        new_centroids = [(sum(p[0] for p, label in zip(coordenadas, labels) if label == j) / labels.count(j),
                          sum(p[1] for p, label in zip(coordenadas, labels) if label == j) / labels.count(j))
                         for j in range(k)]

        # Verifica convergencia
        if all(distancia_manhattan(new, old) < tol for new, old in zip(new_centroids, centroids)):
            break

        centroids = new_centroids

    # Ordena los centroides según la cantidad de puntos en cada clúster
    centroides_ordenados = sorted(centroids, key=lambda c: labels.count(centroids.index(c)), reverse=True)
    return centroides_ordenados

def main():
    # Lee las coordenadas desde un archivo de texto
    coordenadas = []
    with open("coordenadas.txt", "r") as file:
        for line in file:
            coordenadas.append((float(line.strip()), float(next(file).strip())))

    # Establece el número de clústeres utilizando la ecuación proporcionada
    k = int(len(coordenadas) / (2 * 2))

    # Ejecuta el algoritmo k-means
    centroides_ordenados = kmeans(coordenadas, k)

    # Imprime los centroides ordenados
    print("Centroides ordenados:")
    print(" ".join([f"({c[0]}, {c[1]})" for c in centroides_ordenados]))

if __name__ == "__main__":
    main()
