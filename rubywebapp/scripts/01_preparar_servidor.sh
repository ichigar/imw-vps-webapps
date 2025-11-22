#!/usr/bin/env bash
# Script: 01_preparar_servidor.sh
# Objetivo: Instalar Ruby y dependencias del sistema necesarias
# Este script solo necesita ejecutarse una vez o cuando se actualiza el servidor

set -e

echo "=== 01 - Preparar servidor para aplicación Ruby ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

echo "[1/2] Actualizando lista de paquetes..."
apt-get update -y

echo "[2/2] Instalando Ruby, Bundler y compiladores..."
apt-get install -y ruby-full ruby-bundler build-essential

echo ""
echo "Verificando instalación..."
if command -v ruby >/dev/null 2>&1; then
  echo "✓ Ruby instalado: $(ruby --version)"
else
  echo "✗ ERROR: Ruby no se ha instalado correctamente."
  exit 1
fi

if command -v bundler >/dev/null 2>&1; then
  echo "✓ Bundler instalado: $(bundler --version)"
else
  echo "✗ ERROR: Bundler no se ha instalado correctamente."
  exit 1
fi

echo ""
echo "=== Servidor preparado correctamente. ==="

