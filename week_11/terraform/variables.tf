# ─────────────────────────────────────────
# IMATGES DOCKER
# ─────────────────────────────────────────

# Imatge de Nginx que es descarregarà de Docker Hub.
# Si vols actualitzar a una versió nova (v3, v4...),
# només cal canviar aquest valor, no cal tocar el main.tf.
variable "nginx_image" {
  description = "Imatge Docker de Nginx"
  type        = string
  default     = "eusebiuboloc/nginx-gsx:latest"
}

# Imatge del backend Python que es descarregarà de Docker Hub.
variable "backend_image" {
  description = "Imatge Docker del backend Python"
  type        = string
  default     = "eusebiuboloc/python-http-server:latest"
}

# ─────────────────────────────────────────
# RÈPLIQUES
# ─────────────────────────────────────────

# Nombre de pods de Nginx que s'executaran simultàniament.
# Amb 2 rèpliques, si un pod cau l'altre segueix funcionant (alta disponibilitat).
# Es pot augmentar fàcilment si hi ha més tràfic sense canviar el codi.
variable "nginx_replicas" {
  description = "Nombre de rèpliques del servei Nginx"
  type        = number
  default     = 2
}

# El backend té 1 rèplica perquè és stateless i simple.
# Si calgués escalar, només caldria canviar aquest valor.
variable "backend_replicas" {
  description = "Nombre de rèpliques del servei Backend"
  type        = number
  default     = 1
}

# ─────────────────────────────────────────
# PORTS
# ─────────────────────────────────────────

# Port estàndard HTTP. Separat del main.tf per si mai calgués
# canviar-lo.
variable "nginx_port" {
  description = "Port on escolta Nginx"
  type        = number
  default     = 80
}

# Port del backend Python. 
variable "backend_port" {
  description = "Port on escolta el backend Python"
  type        = number
  default     = 8080
}

# ─────────────────────────────────────────
# KUBERNETES
# ─────────────────────────────────────────

# Namespace de Kubernetes on es desplegaran tots els recursos.
# "default" és el namespace que existeix per defecte a qualsevol clúster.
variable "app_namespace" {
  description = "Namespace de Kubernetes on desplegar"
  type        = string
  default     = "default"
}