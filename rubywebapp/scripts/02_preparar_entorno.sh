#!/usr/bin/env bash
# Script: 02_preparar_entorno.sh
# Objetivo: Instalar dependencias Ruby de la aplicación
# Este script debe ejecutarse cada vez que cambia el código fuente o las dependencias

set -e

echo "=== 02 - Preparar entorno de la aplicación ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Carpeta del proyecto: ${PROJECT_DIR}"

if [[ ! -f "${PROJECT_DIR}/Gemfile" ]]; then
  echo "ERROR: No se ha encontrado Gemfile en ${PROJECT_DIR}"
  exit 1
fi

cd "${PROJECT_DIR}"

echo "[1/2] Configurando Bundler..."
bundle config set --local path "vendor/bundle"

echo "[2/2] Instalando dependencias Ruby (esto puede tardar unos minutos)..."
bundle install --jobs 4

echo ""
echo "Verificando instalación..."
if bundle exec puma --version >/dev/null 2>&1; then
  echo "✓ Puma instalado correctamente"
else
  echo "✗ ERROR: Puma no se ha instalado correctamente."
  exit 1
fi

echo ""
echo "=== Entorno preparado correctamente. ==="

# Intentar reiniciar servicio si existe (puede requerir sudo)
if systemctl is-enabled rubywebapp.service >/dev/null 2>&1; then
  echo ""
  if systemctl restart rubywebapp.service 2>/dev/null; then
    echo "✓ Servicio reiniciado automáticamente."
  else
    echo "⚠ Para aplicar los cambios, reinicia el servicio manualmente:"
    echo "  sudo systemctl restart rubywebapp"
  fi
fi

echo ""
echo "Para ejecutar la aplicación manualmente:"
echo "  cd ${PROJECT_DIR} && bundle exec puma -p 3000"

