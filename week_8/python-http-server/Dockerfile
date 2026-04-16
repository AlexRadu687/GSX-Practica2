# Utilitzem una imatge lleugera de Python
FROM python:3.11-slim

# Establim el directori de treball
WORKDIR /app

# Copiem el fitxer del servidor
COPY server.py .

# Exposem el port
EXPOSE 8080

# Executem el servidor
CMD ["python", "server.py"]