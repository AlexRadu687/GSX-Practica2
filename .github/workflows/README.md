# CI/CD Pipeline

## Descripció

Aquest directori conté el pipeline de CI/CD per a la infraestructura de GreenDevCorp. Degut a una limitació tècnica important, el pipeline es divideix en dues parts:

**CI (Continuous Integration) a GitHub Actions** — s'executa automàticament al núvol cada vegada que es fa un push a `main`. Construeix les imatges Docker, les puja a Docker Hub i valida el codi de Terraform.

**CD (Continuous Deployment) local a Minikube** — s'executa manualment a la màquina local. Desplegla la infraestructura a Minikube usant Terraform amb les imatges produïdes per la CI.

## Per què aquesta divisió?

GitHub Actions executa els workflows en servidors remots d'internet. El clúster de Minikube corre localment a la nostra màquina, sense IP pública accessible des de l'exterior. Per tant, GitHub no pot accedir a Minikube per fer el desplegament automàticament.

```
GitHub Actions (internet)          La nostra màquina (local)
        │                                    │
        │   ← No hi ha connexió →            │
        │                                    │
  - Construeix imatges              - Desplega a Minikube
  - Puja a Docker Hub               - Verifica funcionament
  - Valida Terraform
```

## Estructura de fitxers

```
.github/
└── workflows/
    └── ci.yml    # Definició del pipeline de CI
```

## El pipeline CI: què passa en cada push?

Cada vegada que es fa `git push` a la branca `main`, GitHub Actions executa dos jobs en paral·lel:

### Job 1: `build-and-push`

S'encarrega de construir les imatges Docker i pujar-les a Docker Hub.

```
1. Checkout del codi
2. Login a Docker Hub (amb secrets de GitHub)
3. Build + push de la imatge de Nginx
4. Build + push de la imatge del backend Python
```

Cada imatge es puja amb dos tags simultàniament:
- `eusebiuboloc/nginx-gsx:<github.sha>` — identifica la versió exacta
- `eusebiuboloc/nginx-gsx:latest` — sempre apunta a la versió més recent

### Job 2: `validate-terraform`

S'encarrega de validar que el codi de Terraform és correcte sense tocar Minikube.

```
1. Checkout del codi
2. Instal·lació de Terraform
3. terraform fmt -check    → comprova el format dels fitxers
4. terraform init -backend=false  → descarrega el provider sense connectar-se al clúster
5. terraform validate      → valida la sintaxi dels fitxers
```

El flag `-backend=false` és clau: sense ell, Terraform intentaria connectar-se a Minikube (inaccessible des de GitHub) i el workflow fallaria.

## El tag de les imatges

Les imatges es taguegen simultàniament amb dos formats per oferir flexibilitat en el desplegament:

  - github.sha: Un codi únic (hash) vinculat al commit. Ideal per a desplegaments on es necessita una versió immutable i específica.

  - latest: Una etiqueta que sempre apunta a l'última versió construïda amb èxit.

```YAML
# Configuració al ci.yml
tags: |
  eusebiuboloc/nginx-gsx:${{ github.sha }}
  eusebiuboloc/nginx-gsx:latest
```
## Com aplicar els canvis a Minikube

Gràcies a que hem configurat image_pull_policy: Always en els manifests de Terraform, tens dues opcions per actualitzar el teu clúster local:

- **Opció A: Actualització automàtica**
  
  Com que les variables de Terraform apunten per defecte a :latest, només cal executar la comanda genèrica. Terraform detectarà que hi ha una nova versió al Docker Hub i forçarà la descàrrega:
  ```Bash
  terraform apply
  ```
- **Opció B: Desplegament d'una versió específica**
  
  Si necessites desplegar una versió concreta , pots sobreescriure el tag manualment:
  ```Bash
  # Substitueix <hash> pel SHA del commit que vulguis desplegar
  terraform apply -var="nginx_image=eusebiuboloc/nginx-gsx:<hash>"
  ```

## Secrets configurats a GitHub

Les credencials de Docker Hub mai s'escriuen al codi. Es guarden com a secrets xifrats a GitHub:

```
Repositori → Settings → Secrets and variables → Actions
```

| Secret | Descripció |
|---|---|
| `DOCKERHUB_USERNAME` | Usuari de Docker Hub (`eusebiuboloc`) |
| `DOCKERHUB_TOKEN` | Token d'accés amb permisos Read & Write |

## Flux de treball complet dia a dia

```
1. Fem un canvi (codi, Dockerfile, o IaC)
         │
         ▼
2. git add + git commit + git push origin main
         │
         ▼
3. GitHub Actions s'executa automàticament
   ├── build-and-push:
   │     - Construeix imatges amb tag :github_sha i :latest
   │     - Puja a Docker Hub
   └── validate-terraform:
         - fmt, init, validate → codi de Terraform és vàlid
         │
         ▼
4. Verifiquem que la CI és verda a GitHub → Actions
         │
         ▼
5. A la nostra màquina:
   minikube start
   cd week_11/terraform
   terraform apply
         │
         ▼
6. Minikube actualitzat amb la nova versió 
```

## Com verificar que el desplegament és correcte

Després de `terraform apply`:

```bash
# Comprova que els pods estan running
kubectl get pods

# Verifica que la imatge correcta s'està usant
kubectl describe pod <nom-pod-backend> | grep Image

# Accedeix a Nginx
minikube service nginx-proxy
```

## Credencials i seguretat

Els secrets de Docker Hub (`DOCKERHUB_USERNAME` i `DOCKERHUB_TOKEN`) s'emmagatzemen xifrats a GitHub i mai apareixen als logs ni al codi. Al `ci.yml` s'accedeix a ells amb la sintaxi `${{ secrets.NOM_SECRET }}` — GitHub els substitueix en temps d'execució sense mostrar-los.
