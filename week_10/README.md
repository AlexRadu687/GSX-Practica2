# Desplegament de Kubernetes amb Minikube

Aquest projecte implementa una infraestructura moderna per a **GreenDevCorp** utilitzant **Kubernetes** (via Minikube). Es despleguen dos serveis — un servidor **Nginx** i un servidor **Python** — que es comuniquen entre ells dins del clúster.

---

## Estructura i Explicació del Projecte

### kubernetes/configmap.yml
Centralitza la configuració de l'aplicació en un sol lloc:
* **`APP_PORT`**: Port on escolta el backend (8080). Canviar aquest valor aquí actualitza tots els serveis automàticament, sense tocar les imatges.
* **`APP_ENV`**: Entorn d'execució de l'aplicació (production).
* **`APP_NAME`**: Nom identificatiu de l'aplicació.

### kubernetes/backend.yml
Defineix dos recursos per al servidor Python:
* **`Deployment`**: Indica a Kubernetes que ha de mantenir 1 rèplica del servidor Python en execució en tot moment. Si el pod cau, Kubernetes el reinicia automàticament.
* **`Service (ClusterIP)`**: Dona un nom fix (`python-backend`) al backend perquè altres pods el puguin trobar. Exposa el port 8080 internament dins del clúster.

### kubernetes/nginx.yml
Defineix dos recursos per al servidor Nginx:
* **`Deployment`**: Gestiona les rèpliques del servidor Nginx. Permet escalar horitzontalment (1 → 3 → 1 rèpliques) sense temps d'inactivitat.
* **`Service (NodePort)`**: Exposa Nginx cap a l'exterior del clúster al port 30080, permetent accedir-hi des del navegador o curl de la màquina host.

### kubernetes.sh
Script que automatitza tots els passos del desplegament:
* **Pull & Load**: Descarrega les imatges de Docker Hub si no existeixen localment i les carrega a Minikube.
* **Deploy**: Aplica tots els manifests amb `kubectl apply`.
* **Verificació**: Comprova que els pods i serveis estan en execució.
* **Tests**: Prova la comunicació entre serveis, l'escalat i la resiliència automàticament.

---

## Arquitectura

```
Navegador / curl (host)
        │
        ▼
nginx-service (NodePort :30080)
        │
        ▼
   Pod Nginx
        │  proxy_pass http://python-backend:8080
        ▼
python-backend (ClusterIP :8080)
        │
        ▼
   Pod Python
```

El DNS intern de Kubernetes resol `python-backend` automàticament a la IP del Service corresponent.

---

## Com executar-ho

Segueix aquests passos per posar en marxa la infraestructura:

### 1. Assegurar-se que Minikube està en execució
```bash
minikube start
```

### 2. Executar el script de desplegament
```bash
chmod +x kubernetes.sh
./kubernetes.sh
```

El script fa automàticament:
* Comprova que Minikube està actiu
* Descarrega i carrega les imatges si cal
* Desplega tots els recursos de Kubernetes
* Verifica pods i serveis
* Prova la comunicació, l'escalat i la resiliència

### 3. Accedir al frontend
```bash
minikube service nginx-service --url
# Retorna: http://192.168.49.2:30080
```

Obre la URL al navegador o fes:
```bash
curl http://192.168.49.2:30080
```

---

## Verificació Manual

### Veure l'estat dels pods
```bash
minikube kubectl -- get pods
```

### Veure els serveis
```bash
minikube kubectl -- get services
```

### Provar la comunicació entre serveis
```bash
minikube kubectl -- exec -it <nginx-pod> -- sh
curl http://python-backend:8080
# Resultat: Hello from container
```

### Escalar Nginx
```bash
# Escalar a 3 rèpliques
minikube kubectl -- scale deployment nginx --replicas=3

# Tornar a 1 rèplica
minikube kubectl -- scale deployment nginx --replicas=1
```

### Provar la resiliència
```bash
# Eliminar el pod del backend
minikube kubectl -- delete pod <backend-pod>

# Kubernetes el reinicia automàticament en ~30 segons
minikube kubectl -- get pods --watch
```

---

## Aturar el projecte

### Eliminar tots els recursos de Kubernetes
```bash
minikube kubectl -- delete -f kubernetes/
```

### Aturar Minikube
```bash
minikube stop
```