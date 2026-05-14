## 1. Overview of the Project

Aquest projecte consisteix en el disseny i implementació d'una infraestructura web altament segura utilitzant un enfocament de **Infrastructure as Code (IaC)**.

L'objectiu principal és desplegar un entorn de microserveis (Nginx Proxy i Python Backend) sobre **Kubernetes** mitjançant **Terraform**, aplicant capes de seguretat avançades (**NetworkPolicies**) per garantir l'aïllament del tràfic i la protecció del backend segons el principi de mínim privilegi.

## 2. Quick Start: How to get the system running?

Segueix aquests passos per aixecar tot el sistema des de zero:

```bash
# 1. Iniciar el clúster amb suport per a polítiques de xarxa
minikube start --cni=calico

# 2. Desplegar la infraestructura automatitzada
cd week_11/terraform && terraform apply -auto-approve

# 3. Aplicar les regles de segmentació de xarxa
# Nota: Executar des de l'arrel del projecte o ajustar el path
kubectl apply -f week_12/network-policies/

# 4. Verificar el funcionament i obtenir la URL d'accés
minikube service nginx-proxy --url

```

## 3. Links to Other Documentation

Per a una comprensió profunda del sistema i les evidències de les proves, consulteu:

*   [**Full Integration Test**](./full-integration-test.md): Detalls pas a pas de com s'ha validat tot el sistema.
*   [**Main Documentation**](./documentation.md): On es troba l'Arquitectura, el Runbook i la Guia de Troubleshooting.
*   [**Network Analysis (W12)**](../week_12/security-analysis.md): Anàlisi detallat de seguretat realitzat a la setmana anterior.
*   [**Identity Management**](../week_12/identity-management.md): Documentació sobre la gestió d'identitats al clúster.
