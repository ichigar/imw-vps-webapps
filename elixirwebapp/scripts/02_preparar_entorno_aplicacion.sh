#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# 02_preparar_entorno_app.sh
# Prepara el entorno del proyecto Elixir (Plug + Cowboy)
# Asume que el proyecto está en la carpeta padre de este script.
#
# NO instala paquetes de sistema (eso lo hace 01_preparar_servidor.sh)
# =====================================================

# Carpeta del script (scripts/) y carpeta del proyecto (..)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Preparando entorno de la aplicación Elixir (Plug + Cowboy) ==="
echo "Directorio del proyecto: ${PROJECT_DIR}"

# Comprobamos que exista mix.exs en la carpeta del proyecto
if [ ! -f "${PROJECT_DIR}/mix.exs" ]; then
  echo "ERROR: No se ha encontrado 'mix.exs' en ${PROJECT_DIR}." >&2
  echo "Asegúrate de que el código de la aplicación está en la carpeta padre de scripts/." >&2
  exit 1
fi

cd "${PROJECT_DIR}"

echo "-> Instalando Hex (gestor de paquetes de Elixir) si es necesario..."
mix local.hex --force

echo "-> Instalando Rebar (herramienta para dependencias Erlang) si es necesario..."
mix local.rebar --force

echo "-> Descargando dependencias del proyecto (mix deps.get)..."
mix deps.get

echo "-> Compilando dependencias (mix deps.compile)..."
mix deps.compile

echo "-> Compilando proyecto (mix compile)..."
mix compile

# Intentamos localizar un fichero llamado application.ex
APP_FILE_PATH="$(find "${PROJECT_DIR}" -maxdepth 5 -type f -name "application.ex" 2>/dev/null | head -n 1 || true)"

echo
echo "=== Entorno del proyecto preparado correctamente ==="
echo
echo "Para ejecutar manualmente la aplicación (desde la carpeta del proyecto):"
echo
echo "  cd \"${PROJECT_DIR}\""
echo "  mix deps.get        # por si has añadido nuevas dependencias"
echo "  mix compile         # recompilar si has cambiado código"
echo "  mix run --no-halt   # arranca Plug + Cowboy y se queda en primer plano"
echo
echo "Para cambiar el puerto HTTP en el que Plug + Cowboy se pone a la escucha:"
echo
echo "1. Abre el fichero de aplicación detectado: lib/tu_app/application.ex"
echo "2. Busca options: [ip: {0, 0, 0, 0}, port: 8080] y cambia el puerto"echo
echo "3. Guarda el fichero y vuelve a compilar y ejecutar la aplicación:"
echo
echo "     mix compile"
echo "     mix run --no-halt"
echo
echo "Con eso la aplicación quedará escuchando en el nuevo puerto configurado."
