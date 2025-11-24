#!/usr/bin/env bash
# Script: 01_preparar_servidor.sh
# Objetivo: Instalar PHP, PHP-FPM y Nginx
# Este script solo necesita ejecutarse una vez o cuando se actualiza el servidor

set -e

echo "=== 01 - Preparar servidor para aplicación PHP ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

echo "[1/3] Actualizando lista de paquetes..."
apt-get update -y

echo "[2/3] Instalando PHP, PHP-FPM y Nginx..."
apt-get install -y php-fpm php-cli nginx

echo "[3/3] Verificando instalación..."
if command -v php >/dev/null 2>&1; then
  echo "✓ PHP instalado: $(php --version | head -n 1)"
else
  echo "✗ ERROR: PHP no se ha instalado correctamente."
  exit 1
fi

if systemctl is-active --quiet php*-fpm.service 2>/dev/null; then
  echo "✓ PHP-FPM está en ejecución"
else
  echo "⚠ Advertencia: PHP-FPM puede no estar en ejecución."
fi

if command -v nginx >/dev/null 2>&1; then
  echo "✓ Nginx instalado: $(nginx -v 2>&1)"
else
  echo "✗ ERROR: Nginx no se ha instalado correctamente."
  exit 1
fi

echo ""
echo "=== Servidor preparado correctamente. ==="

