# Deployment: gestiona el cicle de vida dels pods de Nginx.
# S'encarrega de crear-los, reiniciar-los si cauen i escalar-los.
resource "kubernetes_deployment" "nginx_proxy" {
  metadata {
    name      = "nginx-proxy"     # Nom que apareixerà a "kubectl get deployments"
    namespace = var.app_namespace # Namespace on es desplega (definit a variables.tf)
    labels = {
      app = "nginx-proxy" # Etiqueta per identificar aquest recurs
    }
  }

  spec {
    replicas = var.nginx_replicas # Quantes còpies del pod volem (definit a variables.tf)

    selector {
      match_labels = {
        app = "nginx-proxy" # El Deployment gestiona els pods amb aquest label
      }                     # Ha de coincidir exactament amb els labels del template
    }

    # Plantilla amb la qual es crearan tots els pods d'aquest Deployment
    template {
      metadata {
        labels = {
          app = "nginx-proxy" # Label que tindran els pods creats
        }                     # El Service usa aquest label per trobar els pods
      }

      spec {
        container {
          name  = "nginx-proxy"   # Nom del contenidor dins del pod
          image = var.nginx_image # Imatge de Docker Hub: eusebiuboloc/nginx-gsx:latest

          image_pull_policy = "Always" # Sempre descarrega la imatge més recent 

          port {
            container_port = var.nginx_port # Port on escolta Nginx dins del contenidor (80)
          }
        }
      }
    }
  }
}

# Service: exposa els pods de Nginx i enruta el tràfic cap a ells.
# Sense Service, els pods existeixen però no són accessibles.
resource "kubernetes_service" "nginx_proxy" {
  metadata {
    name      = "nginx-proxy"
    namespace = var.app_namespace
  }

  spec {
    selector = {
      app = "nginx-proxy" # Enruta el tràfic als pods que tinguin aquest label
    }

    port {
      port        = var.nginx_port # Port pel qual s'accedeix al Service (80)
      target_port = var.nginx_port # Port del contenidor on es redirigeix el tràfic (80)
    }

    # NodePort perquè Nginx és el punt d'entrada: necessita ser accessible
    # des de fora del clúster (el navegador, curl, etc.)
    type = "NodePort"
  }
}

