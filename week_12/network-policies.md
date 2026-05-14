# Kubernetes NetworkPolicies

## Justificació

Les NetworkPolicies de Kubernetes permeten controlar quin tràfic de xarxa és permès entre pods dins del clúster. Per defecte, tots els pods es poden comunicar entre ells sense restriccions, cosa que representa un risc de seguretat: si un pod és compromès, l'atacant pot accedir a tots els altres.

Implementem tres polítiques que reflecteixen el disseny de xarxa de GreenDevCorp:
1. Deny all per defecte
2. El backend només accepta tràfic de Nginx
3. Nginx accepta tràfic de l'exterior

---

## networkpolicy-default-deny.yml

```yaml
# Política per defecte: bloqueja TOT el tràfic entrant i sortint
# Tots els pods del namespace default queden aïllats
# A partir d'aquí, només s'obre el tràfic explícitament permès
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all        # Nom descriptiu de la política
  namespace: default            # S'aplica al namespace default
spec:
  podSelector: {}               # {} significa: aplica a TOTS els pods del namespace
  policyTypes:
    - Ingress                   # Bloqueja tràfic entrant
    - Egress                    # Bloqueja tràfic sortint
```

**Per què és important?**
Sense aquesta política, qualsevol pod pot parlar amb qualsevol altre. Si el pod del backend és compromès, un atacant podria accedir a la base de dades, al monitoratge o a qualsevol altre servei del clúster. Amb "deny all", forcem a declarar explícitament cada comunicació permesa.

---

## networkpolicy-backend.yml

```yaml
# Política pel backend: només accepta tràfic provinent de pods de Nginx
# El backend no ha de ser accessible des de cap altre lloc
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend              # S'aplica als pods amb etiqueta app=backend
  policyTypes:
    - Ingress                   # Controla el tràfic entrant al backend
    - Egress                    # Controla el tràfic sortint del backend
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: nginx        # Només els pods de Nginx poden enviar tràfic al backend
      ports:
        - protocol: TCP
          port: 8080            # Només al port 8080 (on escolta el servidor Python)
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system   # Permet DNS (necessari per resoldre noms)
      ports:
        - protocol: UDP
          port: 53              # Port DNS
        - protocol: TCP
          port: 53
```

**Per què limitem l'accés al backend?**
El backend conté la lògica de negoci i potencialment accés a dades sensibles. Restringir l'accés només als pods de Nginx garanteix que cap altre servei (ni un pod compromès) pugui accedir-hi directament. Segueix el principi de mínim privilegi.

---

## networkpolicy-nginx.yml

```yaml
# Política per Nginx: accepta tràfic de l'exterior i pot parlar amb el backend
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: nginx-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: nginx                # S'aplica als pods amb etiqueta app=nginx
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - ports:
        - protocol: TCP
          port: 80              # Accepta tràfic HTTP de qualsevol origen (Internet)
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: backend      # Nginx només pot parlar amb el backend
      ports:
        - protocol: TCP
          port: 8080
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system   # Permet DNS
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

**Per què Nginx necessita accés a DNS?**
Quan Nginx fa `proxy_pass http://python-backend:8080`, necessita resoldre el nom `python-backend` a una IP. Sense permetre el tràfic DNS al port 53 cap a `kube-system`, la resolució de noms fallaria i Nginx no podria trobar el backend.

---

## Com Aplicar les Polítiques

Perquè les polítiques de xarxa tinguin efecte, és imprescindible que el clúster de Kubernetes estigui gestionat per un controlador de xarxa compatible (CNI) com **Calico**.

### 1. Preparació de l'Entorn

Abans d'aplicar les polítiques, ens assegurem que el clúster s'inicia amb el suport necessari:

```bash
# Reiniciem el clúster amb el driver de xarxa Calico
minikube delete
minikube start --cni=calico

# Despleguem l'aplicació (si no està ja activa)
cd week_11/terraform
terraform apply -auto-approve

```

### 2. Aplicació de les NetworkPolicies

Un cop l'aplicació està corrent, apliquem les restriccions de seguretat definides als fitxers YAML:

```bash
# Apliquem totes les polítiques del directori
kubectl apply -f week_12/network-policies/

# Verifiquem que s'han creat correctament
kubectl get networkpolicies

```

---

## Com Provar les Polítiques

Realitzem proves per validar que la segmentació de xarxa funciona segons el disseny de "Defense-in-Depth".

### A. Test de Connectivitat Permesa

Verifiquem que el flux de dades legítim (**Nginx → Backend**) segueix actiu.

```bash
# Executem un curl des del pod de Nginx cap al servei del Backend
kubectl exec -it deployment/nginx-proxy -- curl --connect-timeout 2 http://python-backend:8080

```

* **Resultat esperat:** Resposta `200 OK` (p. ex. "Hello from container v2").

### B. Test d'Aïllament (Security Violation)

Verifiquem que la política `default-deny` i la restricció del backend bloquegen el tràfic no autoritzat.

```bash
# Intentem accedir al backend des d'un pod sense l'etiqueta 'app: nginx'
kubectl run mallory --image=busybox -it --rm --labels="app=intruder" -- wget -qO- --timeout=2 http://python-backend:8080

```

* **Resultat esperat:** `wget: bad address 'python-backend:8080`.
* **Significat:** La NetworkPolicy està descartant els paquets (DROP), complint amb l'objectiu de seguretat.
