# Servidor HTTP Senzill amb Python

Aquest és un servidor web minimalista escrit en **Python** que s'executa dins d'un contenidor **Docker**. El servidor està dissenyat per ser lleuger i respon a totes les peticions amb el missatge: `"Hello from container"`.

---

## Estructura i Explicació del Projecte

### server.py
Aquest fitxer conté la lògica del servidor:
* **`BaseHTTPRequestHandler`**: Utilitzem aquesta classe per gestionar les peticions d'entrada. Hem definit el mètode `do_GET` per capturar qualsevol visita al servidor.
* **Headers**: El servidor respon amb un codi d'estat `200 OK` i defineix el `Content-type` com a text pla.
* **Port 8080**: S'ha triat aquest port per evitar conflictes amb ports del sistema i facilitar l'execució en entorns de núvol.

### Dockerfile
Aquest fitxer s'utilitza per crear la imatge del contenidor:
* **`FROM python:3.11-slim`**: Utilitzem una versió reduïda de Python per minimitzar l'espai de disc i millorar la seguretat (menys eines instal·lades, menys riscos).
* **`WORKDIR /app`**: Creem un directori de treball aïllat dins del contenidor per evitar barrejar fitxers amb el sistema operatiu intern.
* **`COPY`**: Copiem el codi font local dins de la imatge de Docker.
* **`CMD`**: Estableix el procés principal del contenidor, en aquest cas, arrenca el servidor Python.

---

## Com executar-ho

Segueix aquests passos per posar en marxa el servidor utilitzant Docker:

### 1. Construir la imatge
Executa aquesta comanda des del directori on es troben els fitxers:
```bash
docker build -t python-http-server .
```

### 2. Executar el contenidor
```bash
docker run -p 8080:8080 python-http-server
```
* -p 8080:8080: Connecta el port 8080 del teu ordinador amb el 8080 del contenidor.

### 3. Comprovar el funcionament
Pots obrir el navegador a http://localhost:8080 o fer servir la terminal:
```bash
curl localhost:8080
```
---

## Aturar el projecte
Per aturar el servidor i eliminar el contenidor per netejar el sistema, executa:
```bash
# Atura el contenidor en execució
docker stop python-http-server

# Elimina el contenidor del sistema
docker rm python-http-server
```