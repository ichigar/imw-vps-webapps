#!/usr/bin/env bash
# Script: 02_preparar_entorno.sh
# Objetivo: Verificar que los archivos Lua estén en su lugar
# Este script debe ejecutarse cada vez que cambia el código fuente

set -e

echo "=== 02 - Preparar entorno de la aplicación ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Carpeta del proyecto: ${PROJECT_DIR}"

if [[ ! -f "${PROJECT_DIR}/app.lua" ]]; then
  echo "ERROR: No se ha encontrado app.lua en ${PROJECT_DIR}"
  exit 1
fi

echo "[1/2] Verificando archivo Lua..."
# Verificar sintaxis básica (si luac está disponible)
if command -v luac >/dev/null 2>&1; then
  if luac -p "${PROJECT_DIR}/app.lua" >/dev/null 2>&1; then
    echo "✓ app.lua tiene sintaxis válida"
  else
    echo "⚠ Advertencia: No se pudo verificar la sintaxis de app.lua"
  fi
else
  echo "⚠ luac no está disponible, omitiendo verificación de sintaxis"
fi

echo "[2/2] Verificando permisos..."
chmod 644 "${PROJECT_DIR}"/*.lua 2>/dev/null || true

echo ""
echo "=== Entorno preparado correctamente. ==="

# Reiniciar OpenResty si está configurado
if systemctl is-enabled openresty >/dev/null 2>&1 || systemctl is-active --quiet openresty 2>/dev/null; then
  echo ""
  if systemctl reload openresty 2>/dev/null; then
    echo "✓ OpenResty recargado automáticamente."
  else
    echo "⚠ Para aplicar los cambios, recarga OpenResty manualmente:"
    echo "  sudo systemctl reload openresty"
  fi
fi

echo ""
echo "Para probar la aplicación, accede a:"
echo "  http://localhost:PUERTO (por defecto 80 si está libre, si no 8080, o el valor de APP_PORT configurado)"
