#!/bin/bash

# ===========================================
# GreenDevCorp - Week 10: Kubernetes (Minikube)
# Despliega, testea, escala y prueba resiliencia
# ===========================================

set -e

# Se puede ejecutar desde donde sea este script

DOCKER_USERNAME="eusebiuboloc"
NGINX_IMAGE="$DOCKER_USERNAME/nginx-gsx:v2"
BACKEND_IMAGE="$DOCKER_USERNAME/python-http-server:v1"
K8S_DIR="$(dirname "$0")/kubernetes"

echo "================================================================================"
echo "  GreenDevCorp - Week 10: Kubernetes"
echo "================================================================================"
echo ""

# ===============================================================================
# PASO 1: Verificar que minikube esta corriendo
# NECESITAMOS 8GB de RAM y 2 CPUs PARA EL CORRECTO FUNCIONAMIENTO DE KUBERNETES
# ===============================================================================
echo "PASO 1: Verificando Minikube..."
if ! minikube status | grep -q "Running"; then
  echo "Minikube no esta corriendo. Arrancando..."
  minikube start
else
  echo "Minikube ya esta corriendo"
fi
echo ""

# ===============================================================
# PASO AUXILIAR: GreenDevCorp - Pull y Load imagenes en Minikube
# Hace pull solo si no existe en local
# Hace load solo si no existe en Minikube
# ===============================================================

echo "================================================================================"
echo "  GreenDevCorp - Pull & Load imagenes"
echo "================================================================================"
echo ""

# ===========================================
# Pull si no existe en local
# ===========================================
pull_if_needed() {
  IMAGE=$1
  echo "Comprobando si '$IMAGE' existe en local..."
  if docker image inspect "$IMAGE" > /dev/null 2>&1; then
    echo "Ya existe en local, saltando pull"
  else
    echo "No existe, haciendo pull..."
    docker pull "$IMAGE"
    echo "Pull completado"
  fi
  echo ""
}

# ===========================================
# Load si no existe en Minikube
# ===========================================
load_if_needed() {
  IMAGE=$1
  echo "Comprobando si '$IMAGE' existe en Minikube..."
  if minikube image ls | grep -q "$IMAGE"; then
    echo "Ya existe en Minikube, saltando load"
  else
    echo "No existe en Minikube, haciendo load..."
    minikube image load "$IMAGE"
    echo "Load completado"
  fi
  echo ""
}

# ===========================================
# NGINX
# ===========================================
echo "NGINX:"
pull_if_needed "$NGINX_IMAGE"
load_if_needed "$NGINX_IMAGE"

# ===========================================
# BACKEND
# ===========================================
echo "BACKEND:"
pull_if_needed "$BACKEND_IMAGE"
load_if_needed "$BACKEND_IMAGE"

# ===========================================
# Comprobación de si se ha cargado correctamente
# ===========================================
echo "================================================================================"
echo "Imagenes disponibles en Minikube:"
minikube image ls | grep eusebiuboloc
echo "================================================================================"

# ===========================================
# PASO 2: Desplegar en Kubernetes
# ===========================================
echo "PASO 2: Desplegando en Kubernetes..."
minikube kubectl -- apply -f "$K8S_DIR/"
echo ""

echo "Esperando a que los pods arranquen..."
minikube kubectl -- wait --for=condition=ready pod -l app=backend --timeout=120s
minikube kubectl -- wait --for=condition=ready pod -l app=nginx --timeout=120s
echo ""

# ===========================================
# PASO 3: Verificar pods y servicios
# ===========================================
echo "PASO 3: Verificando pods y servicios..."
echo ""
echo "PODS:"
minikube kubectl -- get pods
echo ""
echo "SERVICES:"
minikube kubectl -- get services
echo ""

# ===========================================
# PASO 4: Test de comunicacion entre servicios
# El servidor Python escucha en 8080
# El Service python-backend expone el puerto 8080
# ===========================================
echo "PASO 4: Testeando comunicacion entre servicios..."
NGINX_POD=$(minikube kubectl -- get pod -l app=nginx -o jsonpath="{.items[0].metadata.name}")
echo "Ejecutando curl desde el pod Nginx ($NGINX_POD) hacia python-backend:8080..."
minikube kubectl -- exec $NGINX_POD -- sh -c "curl -s http://python-backend:8080" && echo "" || echo "Error en la comunicacion entre servicios"
echo ""

# ===========================================
# PASO 5: Test de escalado
# ===========================================
echo "PASO 5: Testeando escalado..."
echo "Escalando Nginx a 3 replicas..."
minikube kubectl -- scale deployment nginx --replicas=3
echo "Esperando a que arranquen los nuevos pods..."
sleep 5
minikube kubectl -- get pods
echo ""
echo "Volviendo a 1 replica..."
minikube kubectl -- scale deployment nginx --replicas=1
sleep 3
minikube kubectl -- get pods
echo ""

# ===========================================
# PASO 6: Test de resiliencia
# ===========================================
echo "PASO 6: Testeando resiliencia..."
BACKEND_POD=$(minikube kubectl -- get pod -l app=backend -o jsonpath="{.items[0].metadata.name}")
echo "Eliminando pod backend: $BACKEND_POD"
minikube kubectl -- delete pod $BACKEND_POD
echo "Esperando a que Kubernetes lo reinicie automaticamente..."
sleep 5
minikube kubectl -- get pods
echo ""

# ===========================================
# RESULTADO FINAL
# ===========================================
echo "================================================================================"
echo "Week 10 completada"
echo "================================================================================"
echo ""
echo "URL del frontend:"
minikube service nginx-service --url
echo ""
echo "Comandos utiles:"
echo "  minikube kubectl -- get pods                        # Ver pods"
echo "  minikube kubectl -- get services                    # Ver servicios"
echo "  minikube kubectl -- logs <pod-name>                 # Ver logs"
echo "  minikube kubectl -- describe pod <pod-name>         # Detalles del pod"
echo "  minikube service nginx-service --url                # URL del frontend"
echo ""
echo "Para limpiar todo:"
echo "  minikube kubectl -- delete -f kubernetes/"