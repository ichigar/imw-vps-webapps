#!/usr/bin/env bash
# Script: 02_preparar_entorno.sh
# Objetivo: Restaurar dependencias y compilar la aplicación ASP.NET
# Este script debe ejecutarse cada vez que cambia el código fuente o las dependencias

set -e

echo "=== 02 - Preparar entorno de la aplicación ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Carpeta del proyecto: ${PROJECT_DIR}"

if [[ ! -f "${PROJECT_DIR}/aspnetwebapp.csproj" ]]; then
  echo "ERROR: No se ha encontrado aspnetwebapp.csproj en ${PROJECT_DIR}"
  exit 1
fi

cd "${PROJECT_DIR}"

echo "[1/2] Restaurando dependencias NuGet..."
dotnet restore

echo "[2/2] Publicando aplicación ASP.NET en modo release (esto puede tardar unos minutos)..."
dotnet publish -c Release -o ./publish

echo ""
echo "Verificando publicación..."
if [[ -f "${PROJECT_DIR}/publish/aspnetwebapp" ]]; then
  echo "✓ Aplicación publicada correctamente"
  chmod +x "${PROJECT_DIR}/publish/aspnetwebapp"
else
  echo "✗ ERROR: No se ha generado el binario en publish/aspnetwebapp"
  exit 1
fi

echo ""
echo "=== Entorno preparado correctamente. ==="

# Intentar reiniciar servicio si existe (puede requerir sudo)
if systemctl is-enabled aspnetwebapp.service >/dev/null 2>&1; then
  echo ""
  if systemctl restart aspnetwebapp.service 2>/dev/null; then
    echo "✓ Servicio reiniciado automáticamente."
  else
    echo "⚠ Para aplicar los cambios, reinicia el servicio manualmente:"
    echo "  sudo systemctl restart aspnetwebapp"
  fi
fi

echo ""
echo "Para ejecutar la aplicación manualmente:"
echo "  cd ${PROJECT_DIR} && PORT=3000 ./publish/aspnetwebapp"

