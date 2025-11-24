#!/usr/bin/env bash
# Script: 01_preparar_servidor.sh
# Objetivo: Instalar Node.js y npm necesarios
# Este script solo necesita ejecutarse una vez o cuando se actualiza el servidor

set -e

echo "=== 01 - Preparar servidor para aplicación Node.js ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

echo "[1/3] Actualizando lista de paquetes..."
apt-get update -y

echo "[2/3] Instalando Node.js y npm..."
# Instalar Node.js desde NodeSource para obtener una versión reciente
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

echo "[3/3] Verificando instalación..."
if command -v node >/dev/null 2>&1; then
  echo "✓ Node.js instalado: $(node --version)"
else
  echo "✗ ERROR: Node.js no se ha instalado correctamente."
  exit 1
fi

if command -v npm >/dev/null 2>&1; then
  echo "✓ npm instalado: $(npm --version)"
else
  echo "✗ ERROR: npm no se ha instalado correctamente."
  exit 1
fi

echo ""
echo "=== Servidor preparado correctamente. ==="

