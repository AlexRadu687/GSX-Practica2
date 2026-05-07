# Deployment: gestiona els pods del backend Python.
# Mateixa estructura que Nginx, però amb la imatge i configuració del backend.
resource "kubernetes_deployment" "python_backend" {
  metadata {
    name      = "python-backend"
    namespace = var.app_namespace
    labels = {
      app = "python-backend"
    }
  }

  spec {
    replicas = var.backend_replicas  # 1 rèplica (definit a variables.tf)

    selector {
      match_labels = {
        app = "python-backend"       # Ha de coincidir amb els labels del template
      }
    }

    template {
      metadata {
        labels = {
          app = "python-backend"
        }
      }

      spec {
        container {
          name  = "python-backend"
          image = var.backend_image  # Imatge de Docker Hub: eusebiuboloc/python-http-server:v1

          port {
            container_port = var.backend_port  # Port on escolta el backend (8080)
          }
        }
      }
    }
  }
}

# Service: exposa el backend però només dins del clúster.
resource "kubernetes_service" "python_backend" {
  metadata {
    name      = "python-backend"
    namespace = var.app_namespace
  }

  spec {
    selector = {
      app = "python-backend"         # Enruta el tràfic als pods del backend
    }

    port {
      port        = var.backend_port # Port pel qual s'accedeix al Service (8080)
      target_port = var.backend_port # Port del contenidor on es redirigeix (8080)
    }

    # ClusterIP perquè el backend NO necessita ser accessible des de fora.
    # Només Nginx hi ha de parlar, i Nginx és dins del clúster.
    # Més segur que NodePort perquè no exposa el port innecessàriament.
    type = "ClusterIP"
  }
}