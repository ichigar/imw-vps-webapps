# Aplicación Web Rust Simple

Aplicación web minimalista en Rust usando Actix-web.

## Estructura

```
rustwebapp/
├── src/
│   └── main.rs          # Aplicación Actix-web principal
├── Cargo.toml           # Dependencias (actix-web)
├── scripts/
│   ├── 01_preparar_servidor.sh    # Instalar Rust y Cargo
│   ├── 02_preparar_entorno.sh     # Compilar aplicación (ejecutar tras cambios de código)
│   └── 03_configurar_servicio.sh  # Configurar servicio systemd
└── README.md
```

## Instalación y despliegue

### Despliegue inicial (solo la primera vez)

```bash
# 1. Instalar Rust y Cargo
sudo ./scripts/01_preparar_servidor.sh

# 2. Compilar la aplicación
./scripts/02_preparar_entorno.sh

# 3. Configurar servicio systemd
sudo APP_PORT=3000 ./scripts/03_configurar_servicio.sh
```

**Nota**: Después de instalar Rust, es posible que necesites ejecutar `source ~/.cargo/env` o reiniciar la sesión para que Cargo esté disponible en el PATH.

### Despliegue tras cambios de código

Cada vez que cambies el código fuente o las dependencias (Cargo.toml), ejecuta:

```bash
./scripts/02_preparar_entorno.sh
```

Este script:
- Compila la aplicación en modo release
- Reinicia automáticamente el servicio si está configurado

### Ejecución manual (sin servicio systemd)

```bash
# Compilar aplicación
./scripts/02_preparar_entorno.sh

# Ejecutar aplicación
cd rustwebapp
PORT=3000 ./target/release/rustwebapp
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
PORT=8080 ./target/release/rustwebapp
```

**Nota**: El puerto por defecto es 3000 si no se especifica ninguno.

## Scripts de despliegue

### 01_preparar_servidor.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando se actualiza el servidor
- **Requiere**: sudo
- **Qué hace**: Instala Rust y Cargo usando rustup

### 02_preparar_entorno.sh
- **Cuándo ejecutar**: Cada vez que cambia el código fuente o el Cargo.toml
- **Requiere**: Ninguno (pero reinicia el servicio si existe)
- **Qué hace**: Compila la aplicación en modo release (optimizado)

### 03_configurar_servicio.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando cambia la configuración del servicio
- **Requiere**: sudo
- **Qué hace**: Crea/configura el servicio systemd para ejecutar el binario compilado

## Gestión del servicio

```bash
# Ver estado
sudo systemctl status rustwebapp

# Ver logs
sudo journalctl -u rustwebapp -f

# Reiniciar
sudo systemctl restart rustwebapp

# Detener
sudo systemctl stop rustwebapp

# Iniciar
sudo systemctl start rustwebapp
```

## Notas sobre compilación

- La primera compilación puede tardar varios minutos ya que Rust compila todas las dependencias
- Las compilaciones posteriores serán más rápidas gracias al sistema de caché de Cargo
- El binario compilado se encuentra en `target/release/rustwebapp`
- El binario es autocontenido y no requiere dependencias adicionales en tiempo de ejecución

