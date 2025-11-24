#!/usr/bin/env bash
# Script: 01_preparar_servidor.sh
# Objetivo: Instalar Nim y Nimble
# Este script solo necesita ejecutarse una vez o cuando se actualiza el servidor

set -e

echo "=== 01 - Preparar servidor para aplicación Nim ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

echo "[1/3] Actualizando lista de paquetes..."
apt-get update -y

echo "[2/3] Instalando dependencias básicas..."
apt-get install -y curl build-essential

echo "[3/3] Instalando Nim..."
# Instalar Nim desde el repositorio oficial
TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo 'ubuntu')}"
HOME_DIR=$(getent passwd "$TARGET_USER" | cut -d: -f6)
NIM_DIR="$HOME_DIR/.nimble"

# Descargar e instalar choosenim (instalador de Nim)
sudo -u "$TARGET_USER" bash -c "curl https://nim-lang.org/choosenim/init.sh -sSf | sh"

# Añadir nim y nimble al PATH del usuario
if [[ -f "$HOME_DIR/.nimble/bin/choosenim" ]]; then
  echo 'export PATH=$HOME/.nimble/bin:$PATH' >> "$HOME_DIR/.bashrc"
fi

echo ""
echo "Verificando instalación..."
if sudo -u "$TARGET_USER" bash -c "source $HOME_DIR/.bashrc && command -v nim" >/dev/null 2>&1; then
  echo "✓ Nim instalado: $(sudo -u "$TARGET_USER" bash -c 'source ~/.bashrc && nim --version | head -n 1')"
else
  echo "⚠ Advertencia: Nim puede no estar en el PATH. Ejecuta 'source ~/.bashrc' o reinicia la sesión."
fi

if sudo -u "$TARGET_USER" bash -c "source $HOME_DIR/.bashrc && command -v nimble" >/dev/null 2>&1; then
  echo "✓ Nimble instalado: $(sudo -u "$TARGET_USER" bash -c 'source ~/.bashrc && nimble --version | head -n 1')"
else
  echo "⚠ Advertencia: Nimble puede no estar en el PATH. Ejecuta 'source ~/.bashrc' o reinicia la sesión."
fi

echo ""
echo "=== Servidor preparado correctamente. ==="
echo "Nota: Es posible que necesites ejecutar 'source ~/.bashrc' o reiniciar la sesión para usar Nim."

