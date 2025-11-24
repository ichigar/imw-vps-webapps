#!/usr/bin/env bash
# Script: 03_configurar_servicio.sh
# Objetivo: Configurar host virtual de Nginx para la aplicación PHP
# Este script solo necesita ejecutarse una vez o cuando cambia la configuración

set -e

echo "=== 03 - Configurar host virtual de Nginx ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_PORT=${APP_PORT:-3000}
NGINX_SITE="phpwebapp"
NGINX_CONFIG="/etc/nginx/sites-available/${NGINX_SITE}"
NGINX_ENABLED="/etc/nginx/sites-enabled/${NGINX_SITE}"

TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo 'ubuntu')}"

if [[ ! -d "${PROJECT_DIR}" ]]; then
  echo "ERROR: No se ha encontrado la carpeta del proyecto: ${PROJECT_DIR}"
  exit 1
fi

if [[ ! -f "${PROJECT_DIR}/index.php" ]]; then
  echo "ERROR: No se ha encontrado index.php en: ${PROJECT_DIR}"
  exit 1
fi

# Detectar versión de PHP-FPM
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')
PHP_FPM_SOCKET="/var/run/php/php${PHP_VERSION}-fpm.sock"

if [[ ! -S "${PHP_FPM_SOCKET}" ]]; then
  echo "ERROR: No se ha encontrado el socket de PHP-FPM en ${PHP_FPM_SOCKET}"
  echo "Asegúrate de que PHP-FPM esté instalado y en ejecución."
  exit 1
fi

echo "Configurando host virtual para usuario: ${TARGET_USER}"
echo "Puerto: ${APP_PORT}"
echo "Directorio: ${PROJECT_DIR}"
echo "PHP-FPM socket: ${PHP_FPM_SOCKET}"

# Crear configuración de Nginx
cat > "${NGINX_CONFIG}" << EOF
server {
    listen ${APP_PORT};
    listen [::]:${APP_PORT};
    server_name _;
    root ${PROJECT_DIR};
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${PHP_FPM_SOCKET};
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    # Manejo de errores 404
    error_page 404 /404.php;
    location = /404.php {
        fastcgi_pass unix:${PHP_FPM_SOCKET};
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

# Habilitar el sitio
if [[ -L "${NGINX_ENABLED}" ]]; then
  rm "${NGINX_ENABLED}"
fi
ln -s "${NGINX_CONFIG}" "${NGINX_ENABLED}"

echo ""
echo "[1/3] Verificando configuración de Nginx..."
if nginx -t >/dev/null 2>&1; then
  echo "✓ Configuración de Nginx válida"
else
  echo "✗ ERROR: La configuración de Nginx tiene errores:"
  nginx -t
  exit 1
fi

echo "[2/3] Recargando Nginx..."
systemctl reload nginx

echo "[3/3] Verificando servicios..."
if systemctl is-active --quiet nginx; then
  echo "✓ Nginx está en ejecución"
else
  echo "⚠ Advertencia: Nginx puede no estar en ejecución."
fi

PHP_FPM_SERVICE=$(systemctl list-units --type=service | grep -o 'php[0-9.]*-fpm.service' | head -n 1 || echo "")
if [[ -n "${PHP_FPM_SERVICE}" ]] && systemctl is-active --quiet "${PHP_FPM_SERVICE}"; then
  echo "✓ PHP-FPM está en ejecución"
else
  echo "⚠ Advertencia: PHP-FPM puede no estar en ejecución."
fi

echo ""
echo "=== Host virtual configurado y en ejecución (puerto ${APP_PORT}) ==="
echo ""
echo "Estado de Nginx:"
systemctl status nginx --no-pager -l || true

