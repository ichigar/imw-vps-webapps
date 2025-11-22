# Aplicación Web Ruby Simple

Aplicación web minimalista en Ruby usando Rack y Puma.

## Estructura

```
rubywebapp/
├── app.rb          # Aplicación Rack principal
├── config.ru       # Configuración Rack
├── Gemfile         # Dependencias (solo rack y puma)
├── scripts/
│   ├── 01_preparar_servidor.sh    # Instalar Ruby y dependencias del sistema
│   ├── 02_preparar_entorno.sh     # Instalar gems (ejecutar tras cambios de código)
│   └── 03_configurar_servicio.sh  # Configurar servicio systemd
└── README.md
```

## Instalación y despliegue

### Despliegue inicial (solo la primera vez)

```bash
# 1. Instalar Ruby y dependencias del sistema
sudo ./scripts/01_preparar_servidor.sh

# 2. Instalar dependencias de la aplicación
./scripts/02_preparar_entorno.sh

# 3. Configurar servicio systemd
sudo APP_PORT=3000 ./scripts/03_configurar_servicio.sh
```

### Despliegue tras cambios de código

Cada vez que cambies el código fuente o las dependencias (Gemfile), ejecuta:

```bash
./scripts/02_preparar_entorno.sh
```

Este script:
- Instala/actualiza las dependencias Ruby
- Reinicia automáticamente el servicio si está configurado

### Ejecución manual (sin servicio systemd)

```bash
# Instalar dependencias
./scripts/02_preparar_entorno.sh

# Ejecutar aplicación
cd rubywebapp
bundle exec puma -p 3000
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

Al ejecutar la aplicación manualmente, especifica el puerto con la opción `-p`:

```bash
bundle exec puma -p 8080
```

O usando la variable de entorno `PORT`:

```bash
PORT=8080 bundle exec puma
```

**Nota**: El puerto por defecto es 3000 si no se especifica ninguno.

## Scripts de despliegue

### 01_preparar_servidor.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando se actualiza el servidor
- **Requiere**: sudo
- **Qué hace**: Instala Ruby, Bundler y compiladores necesarios

### 02_preparar_entorno.sh
- **Cuándo ejecutar**: Cada vez que cambia el código fuente o el Gemfile
- **Requiere**: Ninguno (pero reinicia el servicio si existe)
- **Qué hace**: Instala/actualiza las dependencias Ruby (gems)

### 03_configurar_servicio.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando cambia la configuración del servicio
- **Requiere**: sudo
- **Qué hace**: Crea/configura el servicio systemd para ejecutar la app automáticamente

## Gestión del servicio

```bash
# Ver estado
sudo systemctl status rubywebapp

# Ver logs
sudo journalctl -u rubywebapp -f

# Reiniciar
sudo systemctl restart rubywebapp

# Detener
sudo systemctl stop rubywebapp

# Iniciar
sudo systemctl start rubywebapp
```
