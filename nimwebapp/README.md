# Aplicación Web Nim Simple

Aplicación web minimalista en Nim usando Jester.

## Estructura

```
nimwebapp/
├── src/
│   └── nimwebapp.nim    # Aplicación Jester principal
├── nimwebapp.nimble     # Dependencias (Jester)
├── scripts/
│   ├── 01_preparar_servidor.sh    # Instalar Nim y Nimble
│   ├── 02_preparar_entorno.sh     # Instalar dependencias y compilar (ejecutar tras cambios de código)
│   └── 03_configurar_servicio.sh  # Configurar servicio systemd
└── README.md
```

## Instalación y despliegue

### Despliegue inicial (solo la primera vez)

```bash
# 1. Instalar Nim y Nimble
sudo ./scripts/01_preparar_servidor.sh

# 2. Instalar dependencias y compilar la aplicación
./scripts/02_preparar_entorno.sh

# 3. Configurar servicio systemd
sudo APP_PORT=3000 ./scripts/03_configurar_servicio.sh
```

**Nota**: Después de instalar Nim, es posible que necesites ejecutar `source ~/.bashrc` o reiniciar la sesión para que Nim y Nimble estén disponibles en el PATH.

### Despliegue tras cambios de código

Cada vez que cambies el código fuente o las dependencias (nimwebapp.nimble), ejecuta:

```bash
./scripts/02_preparar_entorno.sh
```

Este script:
- Instala/actualiza las dependencias Nim
- Compila la aplicación en modo release
- Reinicia automáticamente el servicio si está configurado

### Ejecución manual (sin servicio systemd)

```bash
# Instalar dependencias y compilar
./scripts/02_preparar_entorno.sh

# Ejecutar aplicación
cd nimwebapp
PORT=3000 ./nimwebapp
```

La aplicación estará disponible en `http://localhost:3000`

## Características

- **Página principal** (`/`): Muestra información del cliente (IP, User-Agent, resolución, fecha/hora)
- **Formulario de contacto** (`/contact`): Formulario simple de ejemplo

## Configuración del puerto

Por defecto, la aplicación se ejecuta en el puerto **3000**. Puedes cambiarlo de las siguientes formas:

### Cambiar puerto al configurar el servicio (primera vez)

Al ejecutar el script de configuración del servicio, especifica el puerto con la variable de entorno `APP_PORT`:

```bash
sudo APP_PORT=8080 ./scripts/03_configurar_servicio.sh
```

### Cambiar puerto de un servicio ya configurado

Si el servicio ya está configurado y quieres cambiar el puerto:

```bash
# 1. Reconfigurar el servicio con el nuevo puerto
sudo APP_PORT=8080 ./scripts/03_configurar_servicio.sh

# 2. El servicio se reiniciará automáticamente con el nuevo puerto
```

### Cambiar puerto en ejecución manual

Al ejecutar la aplicación manualmente, especifica el puerto con la variable de entorno `PORT`:

```bash
PORT=8080 ./nimwebapp
```

**Nota**: El puerto por defecto es 3000 si no se especifica ninguno.

## Scripts de despliegue

### 01_preparar_servidor.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando se actualiza el servidor
- **Requiere**: sudo
- **Qué hace**: Instala Nim y Nimble usando choosenim

### 02_preparar_entorno.sh
- **Cuándo ejecutar**: Cada vez que cambia el código fuente o el nimwebapp.nimble
- **Requiere**: Ninguno (pero reinicia el servicio si existe)
- **Qué hace**: Instala dependencias y compila la aplicación en modo release

### 03_configurar_servicio.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando cambia la configuración del servicio
- **Requiere**: sudo
- **Qué hace**: Crea/configura el servicio systemd para ejecutar el binario compilado

## Gestión del servicio

```bash
# Ver estado
sudo systemctl status nimwebapp

# Ver logs
sudo journalctl -u nimwebapp -f

# Reiniciar
sudo systemctl restart nimwebapp

# Detener
sudo systemctl stop nimwebapp

# Iniciar
sudo systemctl start nimwebapp
```

## Notas sobre compilación

- La primera compilación puede tardar unos minutos ya que Nim compila todas las dependencias
- Las compilaciones posteriores serán más rápidas gracias al sistema de caché de Nim
- El binario compilado se encuentra en `nimwebapp` (en la raíz del proyecto)
- El binario es autocontenido y no requiere dependencias adicionales en tiempo de ejecución

