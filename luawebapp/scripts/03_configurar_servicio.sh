#!/usr/bin/env bash
# Script: 03_configurar_servicio.sh
# Objetivo: Configurar host virtual de OpenResty para la aplicación Lua
# Este script solo necesita ejecutarse una vez o cuando cambia la configuración

set -e

echo "=== 03 - Configurar host virtual de OpenResty ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_PORT=${APP_PORT:-8000}
NGINX_SITE="luawebapp"
OPENRESTY_PREFIX="/usr/local/openresty"
NGINX_CONFIG="${OPENRESTY_PREFIX}/nginx/conf/sites-available/${NGINX_SITE}"
NGINX_ENABLED="${OPENRESTY_PREFIX}/nginx/conf/sites-enabled/${NGINX_SITE}"

TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo 'ubuntu')}"

if [[ ! -d "${PROJECT_DIR}" ]]; then
  echo "ERROR: No se ha encontrado la carpeta del proyecto: ${PROJECT_DIR}"
  exit 1
fi

if [[ ! -f "${PROJECT_DIR}/app.lua" ]]; then
  echo "ERROR: No se ha encontrado app.lua en: ${PROJECT_DIR}"
  exit 1
fi

# Crear directorios si no existen
mkdir -p "${OPENRESTY_PREFIX}/nginx/conf/sites-available"
mkdir -p "${OPENRESTY_PREFIX}/nginx/conf/sites-enabled"

echo "Configurando host virtual para usuario: ${TARGET_USER}"
echo "Puerto: ${APP_PORT}"
echo "Directorio: ${PROJECT_DIR}"

# Crear configuración de OpenResty/Nginx
cat > "${NGINX_CONFIG}" << EOF
server {
    listen ${APP_PORT};
    listen [::]:${APP_PORT};
    server_name _;
    
    # Configuración de Lua
    location / {
        default_type text/html;
        content_by_lua_file ${PROJECT_DIR}/app.lua;
    }
    
    # Manejo de errores
    error_page 404 /404;
    location = /404 {
        default_type text/html;
        content_by_lua_block {
            local content = [[
    <h1>404 - Página no encontrada</h1>
    <p><a href="/">Volver al inicio</a></p>]]
            local styles = [[
    body { font-family: sans-serif; margin: 2rem; background: #f5f5f5; }
    .container {
      max-width: 720px;
      margin: 0 auto;
      padding: 1.5rem 2rem;
      background: #ffffff;
      border-radius: 8px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.1);
    }
    a { color: #007bff; text-decoration: none; }
    a:hover { text-decoration: underline; }]]
            ngx.status = 404
            ngx.header.content_type = "text/html; charset=utf-8"
            ngx.say("<!DOCTYPE html><html lang=\"es\"><head><meta charset=\"UTF-8\"><title>404 - Lua Web App</title><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><style>" .. styles .. "</style></head><body><div class=\"container\">" .. content .. "</div></body></html>")
        }
    }
}
EOF

# Habilitar el sitio
if [[ -L "${NGINX_ENABLED}" ]]; then
  rm "${NGINX_ENABLED}"
fi
ln -s "${NGINX_CONFIG}" "${NGINX_ENABLED}"

# Asegurar que la configuración principal incluya sites-enabled
MAIN_CONFIG="${OPENRESTY_PREFIX}/nginx/conf/nginx.conf"
if [[ -f "${MAIN_CONFIG}" ]] && ! grep -q "sites-enabled" "${MAIN_CONFIG}" 2>/dev/null; then
  # Agregar include si no existe (después de la línea http {)
  if grep -q "http {" "${MAIN_CONFIG}"; then
    # Buscar la línea después de http { y agregar el include
    sed -i '/^[[:space:]]*http[[:space:]]*{/a\    include sites-enabled/*;' "${MAIN_CONFIG}"
  fi
fi

echo ""
echo "[1/3] Verificando configuración de OpenResty..."
if "${OPENRESTY_PREFIX}/nginx/sbin/nginx" -t >/dev/null 2>&1; then
  echo "✓ Configuración de OpenResty válida"
else
  echo "✗ ERROR: La configuración de OpenResty tiene errores:"
  "${OPENRESTY_PREFIX}/nginx/sbin/nginx" -t
  exit 1
fi

echo "[2/3] Iniciando o recargando OpenResty..."
# Intentar iniciar o recargar OpenResty
if systemctl is-active --quiet openresty 2>/dev/null; then
  systemctl reload openresty || "${OPENRESTY_PREFIX}/nginx/sbin/nginx" -s reload
  echo "OpenResty recargado."
else
  # Iniciar OpenResty manualmente si no hay servicio systemd
  if ! pgrep -f "nginx.*master" >/dev/null; then
    "${OPENRESTY_PREFIX}/nginx/sbin/nginx"
    echo "OpenResty iniciado."
  else
    "${OPENRESTY_PREFIX}/nginx/sbin/nginx" -s reload
    echo "OpenResty recargado."
  fi
fi

echo "[3/3] Verificando servicios..."
if pgrep -f "nginx.*master" >/dev/null; then
  echo "✓ OpenResty/Nginx está en ejecución"
else
  echo "⚠ Advertencia: OpenResty/Nginx puede no estar en ejecución."
fi

echo ""
echo "=== Host virtual configurado y en ejecución (puerto ${APP_PORT}) ==="
echo ""
echo "Para verificar el estado:"
echo "  ps aux | grep nginx"
