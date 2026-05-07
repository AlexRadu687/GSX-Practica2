# ─────────────────────────────────────────
# NGINX
# ─────────────────────────────────────────

# Mostra el nom amb el qual el servei de Nginx és conegut dins de Kubernetes.
# Útil per saber com altres serveis poden accedir-hi: http://nginx-proxy:80
output "nginx_service_name" {
  description = "Nom del servei Nginx a Kubernetes"
  value       = kubernetes_service.nginx_proxy.metadata[0].name
}

# Mostra el port extern que Kubernetes ha assignat al NodePort de Nginx.
# Kubernetes assigna automàticament un port entre 30000-32767.
# Amb aquest port pots accedir a Nginx des de fora del clúster:
# http://<ip-de-minikube>:<node_port>
output "nginx_node_port" {
  description = "Port extern per accedir a Nginx des de fora del clúster"
  value       = kubernetes_service.nginx_proxy.spec[0].port[0].node_port
}

# ─────────────────────────────────────────
# BACKEND
# ─────────────────────────────────────────

# Mostra el nom amb el qual el servei del backend és conegut dins del clúster.
# Nginx pot accedir al backend usant aquest nom: http://python-backend:8080
output "backend_service_name" {
  description = "Nom del servei Backend a Kubernetes"
  value       = kubernetes_service.python_backend.metadata[0].name
}

# Mostra la IP interna que Kubernetes ha assignat al servei del backend.
# Aquesta IP només és accessible des de dins del clúster (per això és ClusterIP).
# Útil per verificar que el servei s'ha creat correctament.
output "backend_cluster_ip" {
  description = "IP interna del servei Backend dins del clúster"
  value       = kubernetes_service.python_backend.spec[0].cluster_ip
}