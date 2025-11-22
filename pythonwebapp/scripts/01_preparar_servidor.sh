#!/usr/bin/env bash
# Script: 01_preparar_servidor.sh
# Objetivo: Preparar un servidor Ubuntu para ejecutar aplicaciones web en Python.
# - Actualiza el sistema
# - Instala Python, herramientas de entornos virtuales y Gunicorn
# - Instala herramientas básicas de seguridad

set -e  # Detener el script si ocurre cualquier error

echo "=== 01 - Preparar servidor para aplicaciones Python ==="

# Comprobamos si el script se está ejecutando con privilegios de administrador
if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (por ejemplo, usando sudo)."
  exit 1
fi

echo "[1/4] Actualizando lista de paquetes y sistema..."
apt-get update -y
apt-get upgrade -y

echo "[2/4] Instalando Python 3 y herramientas para entornos virtuales..."
apt-get install -y python3 python3-venv python3-pip

echo "[3/4] Instalando Gunicorn y utilidades de seguridad (ufw, unattended-upgrades)..."
apt-get install -y gunicorn ufw unattended-upgrades

echo "[4/4] Comprobando herramientas instaladas..."

check_command() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK: se ha encontrado el comando '$cmd'."
  else
    echo "ERROR: no se ha encontrado el comando '$cmd'."
    exit 1
  fi
}

check_command python3
check_command pip3
check_command gunicorn
check_command ufw

echo "=== Servidor preparado correctamente para aplicaciones web en Python. ==="
