#!/usr/bin/env bash
# Script: 01_preparar_servidor.sh
# Objetivo: Instalar OpenResty (Nginx con Lua)
# Este script solo necesita ejecutarse una vez o cuando se actualiza el servidor

set -e

echo "=== 01 - Preparar servidor para aplicación Lua ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

echo "[1/4] Actualizando lista de paquetes..."
apt-get update -y

echo "[2/4] Instalando dependencias básicas..."
apt-get install -y curl wget gnupg2 ca-certificates lsb-release net-tools

echo "[3/4] Instalando OpenResty..."
# Agregar repositorio de OpenResty (clave en keyring y repo firmado)
KEYRING_PATH="/usr/share/keyrings/openresty-archive-keyring.gpg"
KEY_FPR="573BFD6B3D8FBC64107924495D400AF9B1EE6E29"
curl -fsSL https://openresty.org/package/pubkey.gpg | gpg --dearmor -o "$KEYRING_PATH"
echo "deb [signed-by=${KEYRING_PATH}] http://openresty.org/package/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/openresty.list
# Limpiar clave heredada en trusted.gpg para evitar avisos deprecados
if gpg --no-default-keyring --keyring /etc/apt/trusted.gpg --list-keys "$KEY_FPR" >/dev/null 2>&1; then
  gpg --batch --yes --no-default-keyring --keyring /etc/apt/trusted.gpg --delete-keys "$KEY_FPR" || true
fi
if [[ -f /etc/apt/trusted.gpg.d/openresty.gpg ]]; then
  rm -f /etc/apt/trusted.gpg.d/openresty.gpg
fi

# Si el puerto 80 está en uso (por Caddy/Apache/Nginx), bloqueamos arranques automáticos
PORT80_IN_USE=false
if ss -tln 2>/dev/null | awk '$1 == "LISTEN" && $4 ~ /:80$/ {found=1} END {exit found?0:1}'; then
  PORT80_IN_USE=true
  echo "Puerto 80 ocupado; se evitará el arranque automático de servicios durante la instalación."
  cat >/usr/sbin/policy-rc.d <<'EOF'
#!/bin/sh
exit 101
EOF
  chmod +x /usr/sbin/policy-rc.d
fi

apt-get update -y
apt-get install -y openresty

# Si bloqueamos arranques automáticos, los limpiamos ahora
if [[ "$PORT80_IN_USE" == true ]]; then
  rm -f /usr/sbin/policy-rc.d
fi

# Ajustar el puerto por defecto si 80 está ocupado
TARGET_PORT=80
if [[ "$PORT80_IN_USE" == true ]]; then
  TARGET_PORT=8080
fi
NGINX_CONF="/usr/local/openresty/nginx/conf/nginx.conf"
if [[ -f "$NGINX_CONF" ]]; then
  sed -i "s/listen[[:space:]]\\+80;/listen       ${TARGET_PORT};/g" "$NGINX_CONF"
fi

echo "[4/4] Verificando instalación..."
if command -v openresty >/dev/null 2>&1; then
  echo "✓ OpenResty instalado: $(openresty -v 2>&1 | head -n 1)"
else
  echo "✗ ERROR: OpenResty no se ha instalado correctamente."
  exit 1
fi

# Crear enlace simbólico para nginx si no existe
if [[ ! -f /usr/bin/nginx ]]; then
  ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/bin/nginx
fi

# Iniciar o reiniciar el servicio si es posible
if systemctl list-unit-files | grep -q '^openresty.service'; then
  systemctl restart openresty || true
fi

echo ""
echo "=== Servidor preparado correctamente. ==="
