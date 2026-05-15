# Gestió d'Infraestructura amb Docker Compose

L'objectiu és desplegar una arquitectura web completa composta per un servidor frontal (Nginx) i un backend (Python HTTP Server) de manera automatitzada i configurable.

---

## Arquitectura del Sistema

L'entorn utilitza una arquitectura de microserveis on cada component té una responsabilitat única:

- **Usuari/Client:** Accedeix al sistema a través del port definit (per defecte el 80).

- **Nginx (Frontal/Proxy):** Rep la petició i la redirigeix internament al backend. Això aïlla el servidor d'aplicacions del món exterior.

- **Backend (Python):** Processa la petició i retorna la resposta.

### Diagrama de Flux

```text
[ Client (Navegador) ]
                 |
           (Port 80 Ext)
                 v
       +-----------------------+
       |  Nginx Reverse Proxy  | 
       +-----------------------+
                 |
       (HTTP://python-backend:8080) <--- Comunicació Interna
                 v
       +-----------------------+ 
       |    Python Backend     | 
       +-----------------------+          
```

## Configuració i Gestió de Variables

S'ha implementat una gestió de configuració basada en variables d'entorn per evitar el "hardcoding" de valors dins del fitxer `docker-compose.yml`.

### Fitxer `.env`

Tota la configuració es centralitza en el fitxer `.env`:

| Variable | Valor per defecte | Descripció |
|---|---|---|
| `NGINX_IMAGE` | `eusebiuboloc/nginx-gsx:v2` | Imatge del servidor Nginx |
| `BACKEND_IMAGE` | `eusebiuboloc/python-http-server:v1` | Imatge del backend Python |
| `NGINX_PORT` | `80` | Port extern del servidor Nginx |
| `BACKEND_PORT` | `8080` | Port extern del backend Python |
| `NGINX_NAME` | `nginx-proxy` | Nom del contenidor Nginx |
| `BACKEND_NAME` | `python-backend` | Nom del contenidor backend |
| `NETWORK_NAME` | `gsx-network` | Nom de la xarxa virtual |

> **Nota de seguretat:** El fitxer `.env` està inclòs al `.gitignore` per evitar que configuracions locals es publiquin al repositori.

## Nota sobre la Persistència

Aquest sistema s'ha dissenyat sota un model Stateless (sense estat). Com que el backend processa peticions de manera efímera i no requereix l'escriptura de fitxers permanents, s'ha eliminat la dependència de volums compartits. Això millora la velocitat de desplegament i facilita l'escalabilitat en entorns de producció com Kubernetes.

## Xarxa i Comunicació (Networking)

Tots els serveis estan units a una xarxa virtual (per defecte `gsx-network`). Aquesta configuració permet:

- **Service Discovery:** L'Nginx pot comunicar-se amb el backend utilitzant el nom de servei (`http://python-backend:8080`) en lloc d'adreces IP variables.

- **Aïllament:** La comunicació entre contenidors és privada dins de la xarxa virtual.

## Instruccions d'Ús

### 1. Preparació

Crea o modifica el fitxer `.env` amb les variables desitjades (pots utilitzar els valors per defecte ja definits).

### 2. Aixecar l'entorn

```bash
docker-compose up -d
```

### 3. Verificació

```bash
# Comprova l'estat dels contenidors
docker-compose ps

# Verifica els logs en temps real
docker-compose logs -f

# Verifica que el sistema respon correctament (Proxy -> Backend)
curl http://localhost:80
```

### 4. Aturar l'entorn

```bash
docker-compose down
```
