#!/usr/bin/env bash
# Script: 04_configurar_servicio_gunicorn.sh
# Objetivo: Crear o actualizar un servicio systemd que ejecute la app con Gunicorn.
# - Detecta la ruta del repositorio y del entorno virtual
# - Crea/actualiza el servicio systemd contact_app.service
# - Configura el servicio para usar el usuario que invoca sudo
# - Recarga systemd y reinicia el servicio (útil para redeploy)

set -e

echo "=== 04 - Configurar servicio de Gunicorn para contact_app ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (por ejemplo, usando sudo)."
  exit 1
fi

# Usuario "real" que ha lanzado sudo (el que será dueño del servicio y del repo)
TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo 'ubuntu')}"
USER_HOME_DIR="$(eval echo ~${TARGET_USER})"

# Localizar raíz del proyecto a partir de la ubicación del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENV_DIR="${PROJECT_DIR}/venv"
GUNICORN_BIN="${VENV_DIR}/bin/gunicorn"
SERVICE_PORT=8000

echo "Usuario objetivo: ${TARGET_USER}"
echo "Carpeta del proyecto: ${PROJECT_DIR}"
echo "Entorno virtual: ${VENV_DIR}"
echo "Ejecutable de Gunicorn: ${GUNICORN_BIN}"

if [[ ! -d "${PROJECT_DIR}" ]]; then
  echo "ERROR: No se ha encontrado la carpeta del proyecto: ${PROJECT_DIR}"
  exit 1
fi

if [[ ! -d "${VENV_DIR}" ]]; then
  echo "ERROR: No se ha encontrado el entorno virtual en: ${VENV_DIR}"
  echo "Ejecuta 03_entorno_virtual_y_dependencias.sh antes de este script."
  exit 1
fi

if [[ ! -x "${GUNICORN_BIN}" ]]; then
  echo "ERROR: No se ha encontrado el ejecutable de Gunicorn en: ${GUNICORN_BIN}"
  exit 1
fi

SERVICE_NAME="pythonwebapp.service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"

echo "Creando/actualizando archivo de servicio systemd: ${SERVICE_FILE}"

cat > "${SERVICE_FILE}" << EOF
[Unit]
Description=Aplicación web de contacto en Python con Gunicorn
After=network.target

[Service]
User=${TARGET_USER}
Group=${TARGET_USER}
WorkingDirectory=${PROJECT_DIR}
Environment="PATH=${VENV_DIR}/bin"
ExecStart=${GUNICORN_BIN} --workers 3 --bind 0.0.0.0:${SERVICE_PORT} app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "Recargando configuración de systemd..."
systemctl daemon-reload

echo "Habilitando servicio para inicio automático..."
systemctl enable "${SERVICE_NAME}"

echo "Iniciando o reiniciando servicio..."
if systemctl is-active --quiet "${SERVICE_NAME}"; then
  systemctl restart "${SERVICE_NAME}"
else
  systemctl start "${SERVICE_NAME}"
fi

echo "Mostrando estado del servicio:"
systemctl status "${SERVICE_NAME}" --no-pager

echo "=== Servicio de Gunicorn configurado y en ejecución (puerto 8000). ==="
echo "Para redeplegar tras cambios de código, vuelve a ejecutar este script."
