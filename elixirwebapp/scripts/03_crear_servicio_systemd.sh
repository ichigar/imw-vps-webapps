#!/usr/bin/env bash

# ==========================================================
# Crea el servicio systemd elixirwebapp.service
# Versión simple y con salida por pantalla
# Se ejecuta SIN sudo. Solo pide sudo en las acciones necesarias.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SERVICE_NAME="elixirwebapp.service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"
RUN_USER="$(whoami)"

echo "=============================================="
echo " Creando servicio systemd: ${SERVICE_NAME}"
echo " Usuario:      ${RUN_USER}"
echo " Proyecto en:  ${PROJECT_DIR}"
echo "=============================================="
echo

# Comprobaciones mínimas
if [ ! -f "${PROJECT_DIR}/mix.exs" ]; then
  echo "ERROR: No se encontró mix.exs en: ${PROJECT_DIR}"
  exit 1
fi

MIX_BIN="$(command -v mix)"
if [ -z "${MIX_BIN}" ]; then
  echo "ERROR: No se encontró el binario 'mix' en el PATH."
  exit 1
fi

echo "Generando archivo del servicio..."

read -r -d '' SERVICE_CONTENT <<EOF
[Unit]
Description=Elixir Web Application (Plug + Cowboy)
After=network.target

[Service]
User=${RUN_USER}
WorkingDirectory=${PROJECT_DIR}
Environment=MIX_ENV=prod
ExecStart=${MIX_BIN} run --no-halt
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "Escribiendo servicio en ${SERVICE_FILE}..."
echo "${SERVICE_CONTENT}" | sudo tee "${SERVICE_FILE}" >/dev/null

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
