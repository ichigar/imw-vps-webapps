#!/usr/bin/env bash
# Script: 02_preparar_entorno.sh
# Objetivo: Compilar y empaquetar la aplicación Spring Boot
# Este script debe ejecutarse cada vez que cambia el código fuente o las dependencias

set -e

echo "=== 02 - Preparar entorno de la aplicación ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Carpeta del proyecto: ${PROJECT_DIR}"

if [[ ! -f "${PROJECT_DIR}/pom.xml" ]]; then
  echo "ERROR: No se ha encontrado pom.xml en ${PROJECT_DIR}"
  exit 1
fi

cd "${PROJECT_DIR}"

echo "[1/2] Compilando y empaquetando aplicación Spring Boot (esto puede tardar varios minutos)..."
mvn clean package -DskipTests

echo "[2/2] Verificando compilación..."
JAR_FILE="${PROJECT_DIR}/target/springbootwebapp-1.0.0.jar"
if [[ -f "${JAR_FILE}" ]]; then
  echo "✓ Aplicación compilada correctamente"
else
  echo "✗ ERROR: No se ha generado el JAR en ${JAR_FILE}"
  exit 1
fi

echo ""
echo "=== Entorno preparado correctamente. ==="

# Intentar reiniciar servicio si existe (puede requerir sudo)
if systemctl is-enabled springbootwebapp.service >/dev/null 2>&1; then
  echo ""
  if systemctl restart springbootwebapp.service 2>/dev/null; then
    echo "✓ Servicio reiniciado automáticamente."
  else
    echo "⚠ Para aplicar los cambios, reinicia el servicio manualmente:"
    echo "  sudo systemctl restart springbootwebapp"
  fi
fi

echo ""
echo "Para ejecutar la aplicación manualmente:"
echo "  cd ${PROJECT_DIR} && PORT=3000 java -jar target/springbootwebapp-1.0.0.jar"

