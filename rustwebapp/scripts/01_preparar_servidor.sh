#!/usr/bin/env bash
# Script: 01_preparar_servidor.sh
# Objetivo: Instalar Rust y herramientas necesarias
# Este script solo necesita ejecutarse una vez o cuando se actualiza el servidor

set -e

echo "=== 01 - Preparar servidor para aplicación Rust ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

echo "[1/3] Actualizando lista de paquetes..."
apt-get update -y

echo "[2/3] Instalando dependencias básicas..."
apt-get install -y curl build-essential

echo "[3/3] Instalando Rust (rustup)..."
# Instalar rustup para el usuario que ejecuta sudo
TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo 'ubuntu')}"
HOME_DIR=$(getent passwd "$TARGET_USER" | cut -d: -f6)

# Instalar rustup como el usuario objetivo
sudo -u "$TARGET_USER" bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

# Añadir cargo al PATH del usuario
if [[ -f "$HOME_DIR/.cargo/env" ]]; then
  echo "source $HOME_DIR/.cargo/env" >> "$HOME_DIR/.bashrc"
fi

echo ""
echo "Verificando instalación..."
if sudo -u "$TARGET_USER" bash -c "command -v rustc" >/dev/null 2>&1; then
  echo "✓ Rust instalado: $(sudo -u "$TARGET_USER" bash -c 'rustc --version')"
else
  echo "⚠ Advertencia: Rust puede no estar en el PATH. Ejecuta 'source ~/.cargo/env' o reinicia la sesión."
fi

if sudo -u "$TARGET_USER" bash -c "command -v cargo" >/dev/null 2>&1; then
  echo "✓ Cargo instalado: $(sudo -u "$TARGET_USER" bash -c 'cargo --version')"
else
  echo "⚠ Advertencia: Cargo puede no estar en el PATH. Ejecuta 'source ~/.cargo/env' o reinicia la sesión."
fi

echo ""
echo "=== Servidor preparado correctamente. ==="
echo "Nota: Es posible que necesites ejecutar 'source ~/.cargo/env' o reiniciar la sesión para usar Rust."

