#!/bin/bash

# Comprovem si l'script s'executa com a root
if [[ $EUID -ne 0 ]]; then
   echo "[!] Aquest script s'ha d'executar com a root (fent servir sudo)."
   exit 1
fi

# Instal·lar paquets només si no estan instal·lats
for pkg in docker.io kubectl terraform; do
    if ! command -v $pkg &> /dev/null; then
        apt install -y $pkg
    else
        echo "$pkg ja està instal·lat"
    fi
done

# Afegir usuari al grup docker només si no hi és ja
if ! groups gsx | grep -q docker; then
    usermod -aG docker gsx # (TU_USUARIO)
else
    echo "gsx ja pertany al grup docker"
fi

