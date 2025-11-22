#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# 01_preparar_servidor.sh
# Script para preparar un servidor Ubuntu 24.04
# para ejecutar aplicaciones Elixir (Plug + Cowboy)
# a nivel de sistema.
#
# NO prepara el entorno específico del proyecto:
# - NO ejecuta mix deps.get
# - NO ejecuta mix compile
# - NO crea servicios systemd de la app
# =====================================================

# ---------- Funciones auxiliares ----------

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
  # Envía el comando a sudo si no eres root
  if necesita_sudo; then
    sudo "$@"
  else
    "$@"
  fi
}

# ---------- Inicio ----------

echo "=== Preparando servidor Ubuntu 24.04 para Elixir (Plug + Cowboy) ==="

echo "-> Actualizando índice de paquetes..."
run_apt apt-get update -y

# Opcional: puedes comentar esta línea si no quieres upgrade automático
echo "-> Actualizando paquetes del sistema (upgrade)..."
run_apt apt-get upgrade -y

echo "-> Instalando herramientas básicas..."
run_apt apt-get install -y \
  build-essential \
  git \
  curl \
  wget \
  ca-certificates \
  unzip

# build-essential: herramientas de compilación (gcc, make, etc.).
# Son necesarias porque muchas dependencias de Erlang/Elixir se compilan.
# git: por si necesitas volver a clonar o actualizar repositorios.
# curl/wget: utilidades para descargar archivos desde terminal.
# ca-certificates: certificados raíz para validar HTTPS.
# unzip: para descomprimir archivos ZIP si lo necesitas.

echo "-> Instalando Erlang y Elixir desde los repositorios de Ubuntu..."
run_apt apt-get install -y \
  erlang-base \
  erlang-dev \
  erlang-tools \
  erlang-ssl \
  elixir

# erlang-base: runtime básico de Erlang (máquina virtual BEAM).
# erlang-dev, erlang-tools, erlang-ssl: módulos típicos necesarios
# para que Elixir y Cowboy funcionen correctamente.
# elixir: lenguaje y herramientas (mix, iex, elixir, etc.).

# Si más adelante necesitas una versión concreta de Erlang/Elixir,
# puedes optar por herramientas como asdf en lugar de los paquetes de Ubuntu.

echo "-> Limpieza de paquetes no necesarios..."
run_apt apt-get autoremove -y
run_apt apt-get autoclean -y

echo "-> Versión instalada de Elixir y Erlang:"
elixir -v || echo "Elixir no disponible en PATH. Comprueba la instalación."
erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell || echo "Erlang no disponible en PATH."

echo "=== Preparación del servidor completada ==="

