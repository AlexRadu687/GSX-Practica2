# Gestió d'Infraestructura amb Docker Compose

L'objectiu és desplegar una arquitectura web completa composta per un servidor frontal (Nginx) i un backend (Python HTTP Server) de manera automatitzada i configurable.

---

## Arquitectura del Sistema

L'entorn es divideix en dos serveis principals que es comuniquen a través d'una xarxa virtual interna:

- **Nginx (Frontal):** Actua com a punt d'entrada web. Rep peticions al port extern definit al `.env` i les redirigeix al port 80 del contenidor.
- **Backend (Python):** Servidor HTTP desenvolupat en la fase anterior de la pràctica. Es carrega directament des de la imatge allotjada a Docker Hub (`eusebiuboloc/python-http-server:v1.0`) i escolta al port 8080.

## Configuració i Gestió de Variables

S'ha implementat una gestió de configuració basada en variables d'entorn per evitar el "hardcoding" de valors dins del fitxer `docker-compose.yml`.

### Fitxer `.env`

Tota la configuració es centralitza en el fitxer `.env`:

| Variable | Valor per defecte | Descripció |
|---|---|---|
| `NGINX_IMAGE` | `nginx:latest` | Imatge del servidor Nginx |
| `BACKEND_IMAGE` | `eusebiuboloc/python-http-server:v1.0` | Imatge del backend Python |
| `NGINX_PORT` | `80` | Port extern del servidor Nginx |
| `BACKEND_PORT` | `8080` | Port extern del backend Python |
| `NGINX_NAME` | `nginx-proxy` | Nom del contenidor Nginx |
| `BACKEND_NAME` | `python-backend` | Nom del contenidor backend |
| `NETWORK_NAME` | `gsx-network` | Nom de la xarxa virtual |
| `VOLUME_NAME` | `dades_compartides` | Nom del volum compartit |

> **Nota de seguretat:** El fitxer `.env` està inclòs al `.gitignore` per evitar que configuracions locals es publiquin al repositori.

## Persistència de Dades

Per garantir que les dades sobrevisquin al reinici dels contenidors, s'ha configurat un volum de Docker anomenat `dades_compartides`:

- **Ruta interna:** `/data`
- **Funcionament:** Ambdós contenidors (Nginx i Backend) tenen accés al mateix volum, permetent la persistència de fitxers i l'intercanvi de dades entre serveis.

## Xarxa i Comunicació (Networking)

Tots els serveis estan units a una xarxa virtual (per defecte `gsx-network`). Aquesta configuració permet:

- **Service Discovery:** L'Nginx pot comunicar-se amb el backend utilitzant el nom de servei (`http://backend:8080`) en lloc d'adreces IP variables.
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
```

### 4. Aturar l'entorn

```bash
docker-compose down
```

Per eliminar també els volums al aturar l'entorn:

```bash
docker-compose down -v
```
