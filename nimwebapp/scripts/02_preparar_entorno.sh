#!/usr/bin/env bash
# Script: 02_preparar_entorno.sh
# Objetivo: Instalar dependencias y compilar la aplicación Nim
# Este script debe ejecutarse cada vez que cambia el código fuente o las dependencias

set -e

echo "=== 02 - Preparar entorno de la aplicación ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Carpeta del proyecto: ${PROJECT_DIR}"

if [[ ! -f "${PROJECT_DIR}/nimwebapp.nimble" ]]; then
  echo "ERROR: No se ha encontrado nimwebapp.nimble en ${PROJECT_DIR}"
  exit 1
fi

cd "${PROJECT_DIR}"

# Asegurar que nim y nimble estén en el PATH
if [[ -f "$HOME/.nimble/bin/choosenim" ]]; then
  export PATH="$HOME/.nimble/bin:$PATH"
fi

echo "[1/3] Instalando dependencias Nim..."
nimble install -y

echo "[2/3] Compilando aplicación Nim en modo release (esto puede tardar unos minutos)..."
nimble build -d:release

echo "[3/3] Verificando compilación..."
if [[ -f "${PROJECT_DIR}/nimwebapp" ]]; then
  echo "✓ Aplicación compilada correctamente"
else
  echo "✗ ERROR: No se ha generado el binario nimwebapp"
  exit 1
fi

echo ""
echo "=== Entorno preparado correctamente. ==="

# Intentar reiniciar servicio si existe (puede requerir sudo)
if systemctl is-enabled nimwebapp.service >/dev/null 2>&1; then
  echo ""
  if systemctl restart nimwebapp.service 2>/dev/null; then
    echo "✓ Servicio reiniciado automáticamente."
  else
    echo "⚠ Para aplicar los cambios, reinicia el servicio manualmente:"
    echo "  sudo systemctl restart nimwebapp"
  fi
fi

echo ""
echo "Para ejecutar la aplicación manualmente:"
echo "  cd ${PROJECT_DIR} && PORT=3000 ./nimwebapp"

