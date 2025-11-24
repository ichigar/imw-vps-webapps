#!/usr/bin/env bash
# Script: 01_preparar_servidor.sh
# Objetivo: Instalar .NET SDK
# Este script solo necesita ejecutarse una vez o cuando se actualiza el servidor

set -e

echo "=== 01 - Preparar servidor para aplicación ASP.NET ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

echo "[1/3] Actualizando lista de paquetes..."
apt-get update -y

echo "[2/3] Instalando dependencias básicas..."
apt-get install -y wget

echo "[3/3] Instalando .NET SDK..."
# Instalar .NET 8 SDK desde Microsoft
wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh
/tmp/dotnet-install.sh --channel 8.0 --install-dir /usr/share/dotnet
rm /tmp/dotnet-install.sh

# Crear enlaces simbólicos
ln -sf /usr/share/dotnet/dotnet /usr/bin/dotnet

# Configurar PATH para todos los usuarios
if ! grep -q "/usr/share/dotnet" /etc/environment; then
  echo 'PATH="/usr/share/dotnet:$PATH"' >> /etc/environment
fi

echo ""
echo "Verificando instalación..."
if command -v dotnet >/dev/null 2>&1; then
  echo "✓ .NET instalado: $(dotnet --version)"
else
  echo "✗ ERROR: .NET no se ha instalado correctamente."
  exit 1
fi

echo ""
echo "=== Servidor preparado correctamente. ==="

