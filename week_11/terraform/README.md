# Infrastructure as Code amb Terraform

## Descripció

Aquest directori conté el codi de Terraform per desplegar la infraestructura de GreenDevCorp a Kubernetes (Minikube). En lloc d'aplicar fitxers YAML manualment amb `kubectl`, Terraform descriu l'estat desitjat de la infraestructura i s'encarrega de crear-la, actualitzar-la i destruir-la de forma reproduïble.

## Estructura de fitxers

```
terraform/
├── main.tf          # Configuració general: provider i connexió amb Minikube
├── nginx.tf         # Deployment + Service de Nginx
├── backend.tf       # Deployment + Service del backend Python
├── variables.tf     # Definició de totes les variables parametritzables
└── outputs.tf       # Informació útil que mostra Terraform després del desplegament
```

## Serveis desplegats

| Servei | Imatge | Port | Tipus de Service |
|---|---|---|---|
| nginx-proxy | eusebiuboloc/nginx-gsx:v2 | 80 | NodePort (accessible des de fora) |
| python-backend | eusebiuboloc/python-http-server:v1 | 8080 | ClusterIP (només intern) |

## Requisits previs

Abans de poder desplegar, cal tenir instal·lades les següents eines:

- **Terraform**
- **Minikube**
- **kubectl**

## Com desplegar des de zero

### 1. Engega Minikube

Terraform necessita que el clúster estigui actiu per poder connectar-s'hi.

```bash
minikube start
```

Verifica que el clúster funciona correctament:

```bash
kubectl cluster-info
minikube status
```

### 2. Inicialitza Terraform

Només cal fer-ho una vegada (o quan afegeixes nous providers). Descarrega el provider de Kubernetes.

```bash
cd terraform/
terraform init
```

Hauries de veure:
```
Terraform has been successfully initialized!
```

### 3. Planifica el desplegament

Mostra què farà Terraform **sense crear res**. Útil per revisar els canvis abans d'aplicar-los.

```bash
terraform plan
```

Hauries de veure:
```
Plan: 4 to add, 0 to change, 0 to destroy.
```

Els 4 recursos són: Deployment de Nginx, Service de Nginx, Deployment del backend i Service del backend.

### 4. Aplica el desplegament

Crea els recursos a Minikube. Terraform demanarà confirmació — escriu `yes`.

```bash
terraform apply
```

Al final veuràs els outputs:
```
Outputs:

backend_cluster_ip   = "10.96.x.x"
backend_service_name = "python-backend"
nginx_node_port      = 3xxxx
nginx_service_name   = "nginx-proxy"
```

### 5. Verifica que tot funciona

Comprova que els pods estan en execució:

```bash
kubectl get pods
```

Hauries de veure:
```
NAME                              READY   STATUS    RESTARTS   AGE
nginx-proxy-xxx                   1/1     Running   0          1m
nginx-proxy-yyy                   1/1     Running   0          1m
python-backend-xxx                1/1     Running   0          1m
```

Comprova els serveis:

```bash
kubectl get services
```

Accedeix a Nginx des del navegador o amb curl:

```bash
# Obté la IP de Minikube
minikube ip

# Accedeix a Nginx (substitueix el port pel nginx_node_port de l'output)
curl http://$(minikube ip):<nginx_node_port>
```

O directament amb Minikube:

```bash
minikube service nginx-proxy
```

## Com actualitzar la infraestructura

Si vols canviar algun valor (per exemple, augmentar les rèpliques de Nginx), edita `variables.tf` i torna a fer `terraform apply`. Terraform detecta automàticament la diferència entre l'estat actual i el desitjat i només aplica els canvis necessaris.

```bash
# Exemple: canviar les rèpliques de Nginx a 3
# Edita variables.tf: default = 3
terraform apply
```

O sense editar el fitxer, directament per línia de comandos:

```bash
terraform apply -var="nginx_replicas=3"
```

## Com destruir la infraestructura

Elimina tots els recursos creats per Terraform:

```bash
terraform destroy
```

Terraform demanarà confirmació — escriu `yes`. Útil per fer una prova de desplegament des de zero (destroy + apply).

## Decisió de disseny: per què Terraform?

Terraform és una eina **declarativa** — descrius l'estat final que vols i Terraform s'encarrega d'arribar-hi. L'alternativa seria Ansible, que és **procedimental** — descrius els passos a seguir. Terraform és més adequat per gestionar recursos de Kubernetes perquè:

- Manté un fitxer d'estat (`terraform.tfstate`) que sap exactament què ha creat
- És idempotent: pots fer `apply` múltiples vegades sense efectes secundaris
- Permet veure els canvis abans d'aplicar-los amb `terraform plan`
