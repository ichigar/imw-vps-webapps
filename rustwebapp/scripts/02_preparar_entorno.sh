#!/usr/bin/env bash
# Script: 02_preparar_entorno.sh
# Objetivo: Compilar la aplicación Rust
# Este script debe ejecutarse cada vez que cambia el código fuente o las dependencias

set -e

echo "=== 02 - Preparar entorno de la aplicación ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Carpeta del proyecto: ${PROJECT_DIR}"

if [[ ! -f "${PROJECT_DIR}/Cargo.toml" ]]; then
  echo "ERROR: No se ha encontrado Cargo.toml en ${PROJECT_DIR}"
  exit 1
fi

cd "${PROJECT_DIR}"

# Asegurar que cargo esté en el PATH
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

echo "[1/2] Compilando aplicación Rust en modo release (esto puede tardar varios minutos)..."
cargo build --release

echo "[2/2] Verificando compilación..."
if [[ -f "${PROJECT_DIR}/target/release/rustwebapp" ]]; then
  echo "✓ Aplicación compilada correctamente"
else
  echo "✗ ERROR: No se ha generado el binario en target/release/rustwebapp"
  exit 1
fi

echo ""
echo "=== Entorno preparado correctamente. ==="

# Intentar reiniciar servicio si existe (puede requerir sudo)
if systemctl is-enabled rustwebapp.service >/dev/null 2>&1; then
  echo ""
  if systemctl restart rustwebapp.service 2>/dev/null; then
    echo "✓ Servicio reiniciado automáticamente."
  else
    echo "⚠ Para aplicar los cambios, reinicia el servicio manualmente:"
    echo "  sudo systemctl restart rustwebapp"
  fi
fi

echo ""
echo "Para ejecutar la aplicación manualmente:"
echo "  cd ${PROJECT_DIR} && PORT=3000 ./target/release/rustwebapp"

