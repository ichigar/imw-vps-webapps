#!/usr/bin/env bash
# Script: 01_preparar_servidor.sh
# Objetivo: Instalar Java y Maven
# Este script solo necesita ejecutarse una vez o cuando se actualiza el servidor

set -e

echo "=== 01 - Preparar servidor para aplicación Spring Boot ==="

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse con privilegios de administrador (usando sudo)."
  exit 1
fi

echo "[1/3] Actualizando lista de paquetes..."
apt-get update -y

echo "[2/3] Instalando Java (OpenJDK 17) y Maven..."
apt-get install -y openjdk-17-jdk maven

echo "[3/3] Verificando instalación..."
if command -v java >/dev/null 2>&1; then
  echo "✓ Java instalado: $(java -version 2>&1 | head -n 1)"
else
  echo "✗ ERROR: Java no se ha instalado correctamente."
  exit 1
fi

if command -v mvn >/dev/null 2>&1; then
  echo "✓ Maven instalado: $(mvn --version | head -n 1)"
else
  echo "✗ ERROR: Maven no se ha instalado correctamente."
  exit 1
fi

echo ""
echo "=== Servidor preparado correctamente. ==="

