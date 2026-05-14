#!/bin/bash

# ==============================================================================
# Script de configuració de l'entorn de treball - GreenDevCorp (Setmana 13)
# Aquest script instal·la Docker, Terraform, Kubectl i Minikube.
# ==============================================================================

# Comprovem si l'script s'executa com a root
if [[ $EUID -ne 0 ]]; then
   echo "[!] Aquest script s'ha d'executar amb privilegis de root (fent servir sudo)."
   exit 1
fi

echo "[+] Iniciant la preparació de l'entorn de treball..."

# 1. Actualitzar el sistema
apt update && apt upgrade -y

# 2. Instal·lar dependències bàsiques
apt install -y curl gnupg software-properties-common apt-transport-https ca-certificates lsb-release

# 3. Instal·lar Docker
if ! command -v docker &> /dev/null; then
    echo "[+] Instal·lant Docker..."
    apt install -y docker.io
    systemctl start docker
    systemctl enable docker
else
    echo "[v] Docker ja està instal·lat."
fi

# 4. Instal·lar Terraform (Mètode oficial per a Ubuntu/Debian)
if ! command -v terraform &> /dev/null; then
    echo "[+] Instal·lant Terraform..."
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt update && apt install -y terraform
else
    echo "[v] Terraform ja està instal·lat."
fi

# 5. Instal·lar kubectl
if ! command -v kubectl &> /dev/null; then
    echo "[+] Instal·lant kubectl..."
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
    apt update && apt install -y kubectl
else
    echo "[v] kubectl ja està instal·lat."
fi

# 6. Instal·lar Minikube
if ! command -v minikube &> /dev/null; then
    echo "[+] Instal·lant Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
else
    echo "[v] Minikube ja està instal·lat."
fi

# 7. Configuració de permisos d'usuari (gsx)
USUARI="gsx"
if id "$USUARI" &>/dev/null; then
    if ! groups "$USUARI" | grep -q docker; then
        echo "[+] Afegint l'usuari $USUARI al grup docker..."
        usermod -aG docker "$USUARI"
    else
        echo "[v] L'usuari $USUARI ja pertany al grup docker."
    fi
else
    echo "[!] L'usuari $USUARI no existeix en aquest sistema. No s'han canviat els permisos de grup."
fi

echo ""
echo "======================================================================"
echo "[SUCCESS] Instal·lació completada correctament."
echo "[INFO] IMPORTANT: Has de tancar la sessió i tornar a entrar (o reiniciar)"
echo "       perquè els canvis de grup de Docker tinguin efecte."
echo "======================================================================"