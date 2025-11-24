#!/usr/bin/env bash
# Script: 01_preparar_servidor.sh
# Objetivo: Instalar Clojure CLI (tools.deps) y dependencias del sistema
# Este script solo necesita ejecutarse una vez o cuando se actualiza el servidor

set -e

echo "=== 01 - Preparar servidor para aplicación Clojure ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

echo "[1/3] Actualizando lista de paquetes..."
apt-get update -y

echo "[2/3] Instalando Java (OpenJDK) y curl..."
apt-get install -y openjdk-17-jdk curl

echo "[3/3] Instalando Clojure CLI (tools.deps)..."
# Instalar Clojure CLI desde el script oficial
INSTALL_SCRIPT="/tmp/clojure-install.sh"
curl -o "${INSTALL_SCRIPT}" https://download.clojure.org/install/linux-install-1.11.1.1347.sh
chmod +x "${INSTALL_SCRIPT}"
"${INSTALL_SCRIPT}"
rm -f "${INSTALL_SCRIPT}"

# Asegurar que el PATH esté actualizado para el usuario actual
if [[ -f /etc/profile.d/clojure.sh ]]; then
  source /etc/profile.d/clojure.sh
fi

echo ""
echo "Verificando instalación..."
if command -v java >/dev/null 2>&1; then
  echo "✓ Java instalado: $(java -version 2>&1 | head -n 1)"
else
  echo "✗ ERROR: Java no se ha instalado correctamente."
  exit 1
fi

if command -v clojure >/dev/null 2>&1; then
  echo "✓ Clojure CLI instalado: $(clojure --version | head -n 1)"
else
  echo "✗ ERROR: Clojure CLI no se ha instalado correctamente."
  exit 1
fi

echo ""
echo "=== Servidor preparado correctamente. ==="

