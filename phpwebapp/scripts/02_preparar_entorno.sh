#!/usr/bin/env bash
# Script: 02_preparar_entorno.sh
# Objetivo: Verificar que los archivos PHP estén en su lugar
# Este script debe ejecutarse cada vez que cambia el código fuente

set -e

echo "=== 02 - Preparar entorno de la aplicación ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Carpeta del proyecto: ${PROJECT_DIR}"

if [[ ! -f "${PROJECT_DIR}/index.php" ]]; then
  echo "ERROR: No se ha encontrado index.php en ${PROJECT_DIR}"
  exit 1
fi

if [[ ! -f "${PROJECT_DIR}/contact.php" ]]; then
  echo "ERROR: No se ha encontrado contact.php en ${PROJECT_DIR}"
  exit 1
fi

echo "[1/2] Verificando archivos PHP..."
if php -l "${PROJECT_DIR}/index.php" >/dev/null 2>&1; then
  echo "✓ index.php es válido"
else
  echo "✗ ERROR: index.php tiene errores de sintaxis."
  php -l "${PROJECT_DIR}/index.php"
  exit 1
fi

if php -l "${PROJECT_DIR}/contact.php" >/dev/null 2>&1; then
  echo "✓ contact.php es válido"
else
  echo "✗ ERROR: contact.php tiene errores de sintaxis."
  php -l "${PROJECT_DIR}/contact.php"
  exit 1
fi

echo "[2/2] Verificando permisos..."
chmod 644 "${PROJECT_DIR}"/*.php 2>/dev/null || true

echo ""
echo "=== Entorno preparado correctamente. ==="

# Reiniciar nginx si está configurado
if systemctl is-enabled nginx >/dev/null 2>&1; then
  echo ""
  if systemctl reload nginx 2>/dev/null; then
    echo "✓ Nginx recargado automáticamente."
  else
    echo "⚠ Para aplicar los cambios, recarga nginx manualmente:"
    echo "  sudo systemctl reload nginx"
  fi
fi

echo ""
echo "Para probar la aplicación manualmente:"
echo "  cd ${PROJECT_DIR} && php -S localhost:3000"

