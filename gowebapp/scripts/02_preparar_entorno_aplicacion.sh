#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# 02_preparar_entorno_aplicacion.sh
# Prepara el entorno del proyecto Go:
# - Verifica Go instalado
# - Ejecuta go mod tidy
# - Compila el binario (webapp)
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_NAME="${APP_NAME:-webapp}"

echo "=== Preparando entorno de la aplicación Go ==="
echo "Directorio del proyecto: ${PROJECT_DIR}"
echo "Binario esperado: ${APP_NAME}"

if ! command -v go >/dev/null 2>&1; then
  echo "ERROR: Go no está instalado en PATH."
  echo "Ejecuta primero scripts/01_preparar_servidor.sh"
  exit 1
fi

cd "${PROJECT_DIR}"

if [ ! -f "main.go" ]; then
  echo "ERROR: No se ha encontrado main.go en ${PROJECT_DIR}."
  exit 1
fi

if [ ! -f "go.mod" ]; then
  echo "-> go.mod no existe. Creando módulo básico 'webapp'..."
  go mod init webapp
fi

echo "-> Resolviendo dependencias (go mod tidy)..."
go mod tidy

echo "-> Compilando la aplicación..."
go build -o "${APP_NAME}" main.go

echo
echo "=== Entorno preparado correctamente ==="
echo "Ejecutable generado: ${PROJECT_DIR}/${APP_NAME}"
echo
echo "Para probar en primer plano (puerto por defecto en el código):"
echo "  cd \"${PROJECT_DIR}\""
echo "  ./${APP_NAME}"
echo
echo "Para usar otro puerto:"
echo "  PORT=9090 ./${APP_NAME}"
