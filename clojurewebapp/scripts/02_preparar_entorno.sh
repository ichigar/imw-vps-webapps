#!/usr/bin/env bash
# Script: 02_preparar_entorno.sh
# Objetivo: Descargar dependencias Clojure de la aplicación
# Este script debe ejecutarse cada vez que cambia el código fuente o las dependencias

set -e

echo "=== 02 - Preparar entorno de la aplicación ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Carpeta del proyecto: ${PROJECT_DIR}"

if [[ ! -f "${PROJECT_DIR}/deps.edn" ]]; then
  echo "ERROR: No se ha encontrado deps.edn en ${PROJECT_DIR}"
  exit 1
fi

cd "${PROJECT_DIR}"

echo "[1/2] Descargando dependencias Clojure (esto puede tardar unos minutos)..."
clojure -P

echo "[2/2] Verificando instalación..."
if clojure -M:check 2>/dev/null || clojure -e "(require 'ring.adapter.jetty)" 2>/dev/null; then
  echo "✓ Dependencias instaladas correctamente"
else
  echo "⚠ Advertencia: No se pudo verificar todas las dependencias, pero continuando..."
fi

echo ""
echo "=== Entorno preparado correctamente. ==="

# Intentar reiniciar servicio si existe (puede requerir sudo)
if systemctl is-enabled clojurewebapp.service >/dev/null 2>&1; then
  echo ""
  if systemctl restart clojurewebapp.service 2>/dev/null; then
    echo "✓ Servicio reiniciado automáticamente."
  else
    echo "⚠ Para aplicar los cambios, reinicia el servicio manualmente:"
    echo "  sudo systemctl restart clojurewebapp"
  fi
fi

echo ""
echo "Para ejecutar la aplicación manualmente:"
echo "  cd ${PROJECT_DIR} && PORT=3000 clojure -M -m clojurewebapp.core"

