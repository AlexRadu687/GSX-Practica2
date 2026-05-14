# Documentació del Projecte: GreenDevCorp Infrastructure

## 1. Arquitectura del Sistema

L'arquitectura es basa en un model de **Proxy Invers** segmentat dins d'un clúster de Kubernetes, seguint els principis de "Defense-in-Depth".

### Diagrama d'Arquitectura

```text
[ Tràfic Extern ]
       |
       v (Port 80/NodePort)
+-------------------------------------------------------------+
|                  CLÚSTER KUBERNETES (Minikube)              |
|                                                             |
|    [ Capa d'Entrada ]              [ Capa d'Aplicació ]     |
|    +----------------+              +------------------+     |
|    |  Service:      |              |  Service:        |     |
|    |  nginx-proxy   |------------->|  python-backend  |     |
|    +-------|--------+              +--------|---------+     |
|            |                                |               |
|    +-------v--------+              +--------v---------+     |
|    |  Pod: Nginx    |              |  Pod: Python     |     |
|    |  (app: proxy)  |              |  (app: backend)  |     |
|    +-------|--------+              +--------|---------+     |
|            |                                |               |
|    [ NetPol: Nginx ]               [ NetPol: Backend ]      |
|    (Permet Port 80)                (Només des de Nginx)     |
+-------------------------------------------------------------+

```

### Flux de Dades

1. L'usuari accedeix mitjançant el **NodePort** exposat pel servei Nginx.
2. El **Nginx-Proxy** rep la petició i la redirigeix internament al nom de DNS `python-backend`.
3. Les **NetworkPolicies** validen que el pod Nginx té permís de sortida (Egress) i que el pod Backend té permís d'entrada (Ingress) des del Proxy.
4. El **Python-Backend** processa la petició i retorna la resposta a través del túnel establert.

---

## 2. Documentació de Components

### **Nginx Proxy (Frontend/Gateway)**

* **Funció:** Punt d'entrada únic. Gestiona la terminació HTTP i el rebuig de tràfic no desitjat.
* **Dependències:** Servei `python-backend:8080`.
* **Configuració:** Definit via Terraform. Utilitza el port 80 internament.
* **Deployment:** `nginx.tf` (2 rèpliques per a alta disponibilitat).

### **Python Backend (Microservei)**

* **Funció:** Servei de lògica que retorna dades en format text/JSON.
* **Dependències:** Cap externa.
* **Configuració:** Port d'escolta 8080.
* **Deployment:** `backend.tf` (1 rèplica).

---

## 3. Guia Operacional (Runbook)

### **Gestió de Versions**

Per actualitzar una imatge:

1. Modifica el camp `image` al recurs `kubernetes_deployment` de Terraform.
2. Executa `terraform apply`. Kubernetes realitzarà un desplegament progressiu (*RollingUpdate*).

### **Escalat de Serveis**

Per augmentar la capacitat de resposta:

```bash
kubectl scale deployment/nginx-proxy --replicas=5

```

### **Inspecció i Monitoratge**

* **Logs en temps real:** `kubectl logs -f deployment/nginx-proxy`
* **Estat de la xarxa:** `kubectl describe networkpolicy backend-policy`

---

## 4. Resolució de Problemes (Troubleshooting)

| Símptoma | Possible Causa | Acció de Diagnòstic |
| --- | --- | --- |
| **502 Bad Gateway** (Nginx) | El backend no està "Ready". | `kubectl get pods` per verificar l'estat del backend. |
| **Connection Timeout** | NetworkPolicy bloquegen el tràfic. | Revisar que les etiquetes (`labels`) dels pods coincideixin amb el `podSelector` de la política. |
| **Err: Bad Address** | Bloqueig de resolució DNS. | Verificar que les NetworkPolicies tenen permès l'Egress al port 53 UDP/TCP. |
