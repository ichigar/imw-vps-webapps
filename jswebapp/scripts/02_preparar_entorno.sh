#!/usr/bin/env bash
# Script: 02_preparar_entorno.sh
# Objetivo: Instalar dependencias Node.js de la aplicación
# Este script debe ejecutarse cada vez que cambia el código fuente o las dependencias

set -e

echo "=== 02 - Preparar entorno de la aplicación ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Carpeta del proyecto: ${PROJECT_DIR}"

if [[ ! -f "${PROJECT_DIR}/package.json" ]]; then
  echo "ERROR: No se ha encontrado package.json en ${PROJECT_DIR}"
  exit 1
fi

cd "${PROJECT_DIR}"

echo "[1/2] Instalando dependencias Node.js (esto puede tardar unos minutos)..."
npm install --production

echo "[2/2] Verificando instalación..."
if node -e "require('express')" 2>/dev/null; then
  echo "✓ Express instalado correctamente"
else
  echo "✗ ERROR: Express no se ha instalado correctamente."
  exit 1
fi

echo ""
echo "=== Entorno preparado correctamente. ==="

# Intentar reiniciar servicio si existe (puede requerir sudo)
if systemctl is-enabled jswebapp.service >/dev/null 2>&1; then
  echo ""
  if systemctl restart jswebapp.service 2>/dev/null; then
    echo "✓ Servicio reiniciado automáticamente."
  else
    echo "⚠ Para aplicar los cambios, reinicia el servicio manualmente:"
    echo "  sudo systemctl restart jswebapp"
  fi
fi

echo ""
echo "Para ejecutar la aplicación manualmente:"
echo "  cd ${PROJECT_DIR} && PORT=3000 node app.js"

