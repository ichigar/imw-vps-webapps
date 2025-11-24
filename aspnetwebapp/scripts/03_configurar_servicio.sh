#!/usr/bin/env bash
# Script: 03_configurar_servicio.sh
# Objetivo: Crear o actualizar el servicio systemd para la aplicación
# Este script solo necesita ejecutarse una vez o cuando cambia la configuración del servicio

set -e

echo "=== 03 - Configurar servicio systemd ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BINARY_PATH="${PROJECT_DIR}/publish/aspnetwebapp"
SERVICE_NAME="aspnetwebapp.service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"
APP_PORT=${APP_PORT:-3000}

TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo 'ubuntu')}"

if [[ ! -d "${PROJECT_DIR}" ]]; then
  echo "ERROR: No se ha encontrado la carpeta del proyecto: ${PROJECT_DIR}"
  exit 1
fi

if [[ ! -f "${PROJECT_DIR}/aspnetwebapp.csproj" ]]; then
  echo "ERROR: No se ha encontrado aspnetwebapp.csproj en: ${PROJECT_DIR}"
  exit 1
fi

if [[ ! -f "${BINARY_PATH}" ]]; then
  echo "ERROR: No se ha encontrado el binario en ${BINARY_PATH}"
  echo "Ejecuta primero: ./scripts/02_preparar_entorno.sh"
  exit 1
fi

# Asegurar que el binario sea ejecutable
chmod +x "${BINARY_PATH}"

echo "Configurando servicio para usuario: ${TARGET_USER}"
echo "Puerto: ${APP_PORT}"
echo "Directorio: ${PROJECT_DIR}"
echo "Binario: ${BINARY_PATH}"

cat > "${SERVICE_FILE}" << EOF
[Unit]
Description=Aplicación web ASP.NET Core simple
After=network.target

[Service]
User=${TARGET_USER}
Group=${TARGET_USER}
WorkingDirectory=${PROJECT_DIR}/publish
Environment="PORT=${APP_PORT}"
Environment="ASPNETCORE_URLS=http://0.0.0.0:${APP_PORT}"
ExecStart=${BINARY_PATH}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "[1/3] Recargando configuración de systemd..."
systemctl daemon-reload

echo "[2/3] Habilitando servicio para inicio automático..."
systemctl enable "${SERVICE_NAME}"

echo "[3/3] Iniciando o reiniciando servicio..."
if systemctl is-active --quiet "${SERVICE_NAME}"; then
  systemctl restart "${SERVICE_NAME}"
  echo "Servicio reiniciado."
else
  systemctl start "${SERVICE_NAME}"
  echo "Servicio iniciado."
fi

echo ""
echo "=== Servicio configurado y en ejecución (puerto ${APP_PORT}) ==="
echo ""
echo "Estado del servicio:"
systemctl status "${SERVICE_NAME}" --no-pager || true

