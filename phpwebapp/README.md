# Aplicación Web PHP Simple

Aplicación web minimalista en PHP usando Nginx como servidor web y PHP-FPM.

## Estructura

```
phpwebapp/
├── index.php           # Página principal
├── contact.php         # Formulario de contacto
├── 404.php            # Página de error 404
├── functions.php      # Funciones auxiliares
├── scripts/
│   ├── 01_preparar_servidor.sh    # Instalar PHP, PHP-FPM y Nginx
│   ├── 02_preparar_entorno.sh     # Verificar archivos PHP (ejecutar tras cambios de código)
│   └── 03_configurar_servicio.sh  # Configurar host virtual de Nginx
└── README.md
```

## Instalación y despliegue

### Despliegue inicial (solo la primera vez)

```bash
# 1. Instalar PHP, PHP-FPM y Nginx
sudo ./scripts/01_preparar_servidor.sh

# 2. Verificar archivos PHP
./scripts/02_preparar_entorno.sh

# 3. Configurar host virtual de Nginx
sudo APP_PORT=3000 ./scripts/03_configurar_servicio.sh
```

### Despliegue tras cambios de código

Cada vez que cambies el código fuente PHP, ejecuta:

```bash
./scripts/02_preparar_entorno.sh
```

Este script:
- Verifica la sintaxis de los archivos PHP
- Recarga automáticamente Nginx si está configurado

### Ejecución manual (sin Nginx)

```bash
# Ejecutar con servidor PHP integrado
cd phpwebapp
php -S localhost:3000
```

La aplicación estará disponible en `http://localhost:3000`

## Características

- **Página principal** (`/`): Muestra información del cliente (IP, User-Agent, resolución, fecha/hora)
- **Formulario de contacto** (`/contact`): Formulario simple de ejemplo

## Configuración del puerto

Por defecto, la aplicación se ejecuta en el puerto **3000**. Puedes cambiarlo de las siguientes formas:

### Cambiar puerto al configurar el host virtual (primera vez)

Al ejecutar el script de configuración, especifica el puerto con la variable de entorno `APP_PORT`:

```bash
sudo APP_PORT=8080 ./scripts/03_configurar_servicio.sh
```

### Cambiar puerto de un host virtual ya configurado

Si el host virtual ya está configurado y quieres cambiar el puerto:

```bash
# 1. Reconfigurar el host virtual con el nuevo puerto
sudo APP_PORT=8080 ./scripts/03_configurar_servicio.sh

# 2. Nginx se recargará automáticamente con el nuevo puerto
```

### Cambiar puerto en ejecución manual

Al ejecutar la aplicación manualmente con el servidor PHP integrado:

```bash
php -S localhost:8080
```

**Nota**: El puerto por defecto es 3000 si no se especifica ninguno.

## Scripts de despliegue

### 01_preparar_servidor.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando se actualiza el servidor
- **Requiere**: sudo
- **Qué hace**: Instala PHP, PHP-FPM y Nginx

### 02_preparar_entorno.sh
- **Cuándo ejecutar**: Cada vez que cambia el código fuente PHP
- **Requiere**: Ninguno (pero recarga Nginx si está configurado)
- **Qué hace**: Verifica la sintaxis de los archivos PHP y recarga Nginx

### 03_configurar_servicio.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando cambia la configuración del host virtual
- **Requiere**: sudo
- **Qué hace**: Crea/configura el host virtual de Nginx para la aplicación

## Gestión de servicios

```bash
# Ver estado de Nginx
sudo systemctl status nginx

# Ver logs de Nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# Recargar configuración de Nginx
sudo systemctl reload nginx

# Reiniciar Nginx
sudo systemctl restart nginx

# Ver estado de PHP-FPM
sudo systemctl status php*-fpm

# Reiniciar PHP-FPM
sudo systemctl restart php*-fpm
```

## Configuración de Nginx

El script `03_configurar_servicio.sh` crea un archivo de configuración en `/etc/nginx/sites-available/phpwebapp` y lo habilita en `/etc/nginx/sites-enabled/`.

La configuración incluye:
- Escucha en el puerto especificado (por defecto 3000)
- Root apuntando al directorio del proyecto
- Procesamiento de archivos PHP a través de PHP-FPM
- Manejo de errores 404
- Protección de archivos .htaccess

## Notas

- PHP-FPM se ejecuta como servicio systemd separado
- Nginx actúa como servidor web y proxy inverso para PHP-FPM
- Los archivos PHP se procesan dinámicamente en cada solicitud
- No se requiere compilación, los cambios en el código PHP se reflejan inmediatamente

