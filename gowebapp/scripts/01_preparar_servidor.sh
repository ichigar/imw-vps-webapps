#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# 01_preparar_servidor.sh
# Prepara un servidor Ubuntu 24.04 para ejecutar
# aplicaciones web en Go (nivel sistema).
# - Instala Go y herramientas básicas.
# - No toca el código de la aplicación ni compila.
# =====================================================

es_root() {
  [ "${EUID}" -eq 0 ]
}

necesita_sudo() {
  if ! es_root; then
    if command -v sudo >/dev/null 2>&1; then
      return 0
    else
      echo "ERROR: Este script requiere sudo o ejecutarse como root." >&2
      exit 1
    fi
  fi
  return 1
}

run_apt() {
  if necesita_sudo; then
    sudo "$@"
  else
    "$@"
  fi
}

echo "=== Preparando servidor Ubuntu 24.04 para apps Go ==="

echo "-> Actualizando índice de paquetes..."
run_apt apt-get update -y

# Puedes comentar el upgrade si no quieres actualizar todo el sistema
echo "-> Actualizando paquetes del sistema (upgrade)..."
run_apt apt-get upgrade -y

echo "-> Instalando herramientas básicas y Go..."
run_apt apt-get install -y \
  build-essential \
  git \
  curl \
  wget \
  ca-certificates \
  golang-go

echo "-> Limpieza de paquetes no necesarios..."
run_apt apt-get autoremove -y
run_apt apt-get autoclean -y

echo "-> Versiones instaladas:"
go version || echo "Go no disponible en PATH. Comprueba la instalación."

echo "=== Preparación del servidor completada ==="
