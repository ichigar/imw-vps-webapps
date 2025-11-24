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
CLOJURE_CMD=$(which clojure)
SERVICE_NAME="clojurewebapp.service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"
APP_PORT=${APP_PORT:-3000}

TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo 'ubuntu')}"

if [[ ! -d "${PROJECT_DIR}" ]]; then
  echo "ERROR: No se ha encontrado la carpeta del proyecto: ${PROJECT_DIR}"
  exit 1
fi

if [[ ! -f "${PROJECT_DIR}/deps.edn" ]]; then
  echo "ERROR: No se ha encontrado deps.edn en: ${PROJECT_DIR}"
  exit 1
fi

if [[ ! -f "${PROJECT_DIR}/src/clojurewebapp/core.clj" ]]; then
  echo "ERROR: No se ha encontrado src/clojurewebapp/core.clj en: ${PROJECT_DIR}"
  exit 1
fi

if [[ ! -x "${CLOJURE_CMD}" ]]; then
  echo "ERROR: Clojure CLI no está instalado o no es ejecutable."
  echo "Ejecuta primero: sudo ./scripts/01_preparar_servidor.sh"
  exit 1
fi

echo "Configurando servicio para usuario: ${TARGET_USER}"
echo "Puerto: ${APP_PORT}"
echo "Directorio: ${PROJECT_DIR}"
echo "Clojure: ${CLOJURE_CMD}"

cat > "${SERVICE_FILE}" << EOF
[Unit]
Description=Aplicación web Clojure Ring simple
After=network.target

[Service]
User=${TARGET_USER}
Group=${TARGET_USER}
WorkingDirectory=${PROJECT_DIR}
Environment="PORT=${APP_PORT}"
ExecStart=${CLOJURE_CMD} -M -m clojurewebapp.core
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

