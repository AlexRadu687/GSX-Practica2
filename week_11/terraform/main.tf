# Declara quins plugins externs necessita Terraform per funcionar.
# En aquest cas, el provider de Kubernetes que sap com parlar amb l'API del clúster.
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes" # Descarregat del registre oficial de Terraform
      version = "~> 2.0"               # Qualsevol versió 2.x (no la 3.0 o superior)
    }
  }
}

# Configura la connexió amb el clúster de Kubernetes.
# Usa el fitxer que genera Minikube automàticament quan fas "minikube start".
provider "kubernetes" {
  config_path    = "~/.kube/config" # Fitxer amb les credencials del clúster
  config_context = "minikube"       # Especifica que volem el clúster de Minikube
}
