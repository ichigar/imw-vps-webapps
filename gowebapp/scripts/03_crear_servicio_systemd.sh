#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# 03_crear_servicio_systemd.sh
# Crea y habilita el servicio systemd para la webapp en Go
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_NAME="${APP_NAME:-webapp}"
SERVICE_NAME="gowebapp.service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"
RUN_USER="$(whoami)"
PORT="${PORT:-8080}"
EXEC_PATH="${PROJECT_DIR}/${APP_NAME}"

echo "=============================================="
echo " Creando servicio systemd: ${SERVICE_NAME}"
echo " Usuario:      ${RUN_USER}"
echo " Proyecto en:  ${PROJECT_DIR}"
echo " Binario:      ${EXEC_PATH}"
echo " Puerto:       ${PORT}"
echo "=============================================="
echo

if [ ! -x "${EXEC_PATH}" ]; then
  echo "ERROR: No se encontró el binario ${EXEC_PATH}"
  echo "Ejecuta scripts/02_preparar_entorno_aplicacion.sh antes."
  exit 1
fi

cat <<EOF
Contenido del servicio:
[Unit]
Description=Go Web Application (gowebapp)
After=network.target

[Service]
User=${RUN_USER}
WorkingDirectory=${PROJECT_DIR}
Environment=PORT=${PORT}
ExecStart=${EXEC_PATH}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo
echo "Escribiendo servicio en ${SERVICE_FILE}..."
sudo tee "${SERVICE_FILE}" >/dev/null <<EOF
[Unit]
Description=Go Web Application (gowebapp)
After=network.target

[Service]
User=${RUN_USER}
WorkingDirectory=${PROJECT_DIR}
Environment=PORT=${PORT}
ExecStart=${EXEC_PATH}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "Recargando systemd..."
sudo systemctl daemon-reload

echo "Habilitando servicio para arranque automático..."
sudo systemctl enable "${SERVICE_NAME}"

echo
echo "=============================================="
echo " Servicio creado correctamente."
echo " Para iniciarlo:"
echo "   sudo systemctl start ${SERVICE_NAME}"
echo
echo " Para ver su estado:"
echo "   sudo systemctl status ${SERVICE_NAME}"
echo
echo " Para ver logs:"
echo "   sudo journalctl -u ${SERVICE_NAME} -n 50 --no-pager"
echo "=============================================="
