#!/usr/bin/env bash
# Script: 03_entorno_virtual_y_dependencias.sh
# Objetivo: Crear (o reutilizar) un entorno virtual e instalar dependencias.
# - Detecta la raíz del repositorio (carpeta padre de scripts/)
# - Crea un entorno virtual en ./venv si no existe
# - Instala dependencias desde requirements.txt
# - Genera un fichero requirements_lock.txt con las versiones instaladas
# - Comprueba que la aplicación se importa correctamente

set -e

echo "=== 03 - Crear entorno virtual e instalar dependencias ==="

# Localizar raíz del proyecto a partir de la ubicación del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENV_DIR="${PROJECT_DIR}/venv"

echo "Carpeta del proyecto: ${PROJECT_DIR}"
echo "Carpeta del entorno virtual: ${VENV_DIR}"

if [[ ! -f "${PROJECT_DIR}/requirements.txt" ]]; then
  echo "ERROR: No se ha encontrado requirements.txt en ${PROJECT_DIR}"
  echo "Ejecuta 02_verificar_estructura.sh para comprobar el repositorio."
  exit 1
fi

########################################
# Crear entorno virtual
########################################
if [[ -d "${VENV_DIR}" ]]; then
  echo "El entorno virtual ya existe. Se reutilizará."
else
  echo "Creando entorno virtual de Python..."
  python3 -m venv "${VENV_DIR}"
fi

echo "Activando entorno virtual..."
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"

########################################
# Instalar dependencias desde requirements.txt
########################################
echo "Actualizando pip..."
pip install --upgrade pip

echo "Instalando dependencias desde requirements.txt..."
pip install -r "${PROJECT_DIR}/requirements.txt"

########################################
# Generar requirements_lock.txt (foto exacta de versiones)
########################################
LOCK_FILE="${PROJECT_DIR}/requirements_lock.txt"
echo "Generando archivo de bloqueo de dependencias: ${LOCK_FILE}"
pip freeze > "${LOCK_FILE}"

########################################
# Comprobación básica de la aplicación
########################################
echo "Realizando comprobación básica de la aplicación..."

python - << 'EOF'
try:
    from app import app  # Importamos el objeto 'app' desde app.py
    print("OK: La aplicación se ha importado correctamente.")
except Exception as e:
    print("ERROR: No se ha podido importar la aplicación.")
    print(e)
    raise SystemExit(1)
EOF

echo "Desactivando entorno virtual..."
deactivate

echo "=== Entorno virtual listo y dependencias instaladas correctamente. ==="
