# Aplicación Web Lua Simple

Aplicación web minimalista en Lua usando OpenResty (Nginx con Lua).

## Estructura

```
luawebapp/
├── app.lua            # Aplicación Lua principal
├── scripts/
│   ├── 01_preparar_servidor.sh    # Instalar OpenResty
│   ├── 02_preparar_entorno.sh     # Verificar archivos Lua (ejecutar tras cambios de código)
│   └── 03_configurar_servicio.sh  # Configurar host virtual de OpenResty
└── README.md
```

## Instalación y despliegue

### Despliegue inicial (solo la primera vez)

```bash
# 1. Instalar OpenResty
sudo ./scripts/01_preparar_servidor.sh

# 2. Verificar archivos Lua
./scripts/02_preparar_entorno.sh

# 3. Configurar host virtual de OpenResty
#    Si no defines APP_PORT, usará 80 si está libre o 8080 en caso contrario
sudo ./scripts/03_configurar_servicio.sh
```

### Despliegue tras cambios de código

Cada vez que cambies el código fuente Lua, ejecuta:

```bash
./scripts/02_preparar_entorno.sh
```

Este script:
- Verifica la sintaxis de los archivos Lua (si luac está disponible)
- Recarga automáticamente OpenResty si está configurado

### Ejecución manual

OpenResty se ejecuta como servidor web, por lo que no hay un modo "manual" simple como en otras aplicaciones. Una vez configurado, la aplicación estará disponible en el puerto especificado.

## Características

- **Página principal** (`/`): Muestra información del cliente (IP, User-Agent, resolución, fecha/hora)
- **Formulario de contacto** (`/contact`): Formulario simple de ejemplo

## Configuración del puerto

Por defecto, el servicio escucha en el puerto **8000**. Para usar otro puerto, define `APP_PORT` al ejecutar el script de configuración:

```bash
sudo APP_PORT=8080 ./scripts/03_configurar_servicio.sh
```

Si ya estaba configurado y quieres cambiar el puerto, vuelve a ejecutar el mismo comando con el nuevo valor; el servicio se recargará automáticamente.

## Scripts de despliegue

### 01_preparar_servidor.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando se actualiza el servidor
- **Requiere**: sudo
- **Qué hace**: Instala OpenResty (Nginx con módulos Lua)

### 02_preparar_entorno.sh
- **Cuándo ejecutar**: Cada vez que cambia el código fuente Lua
- **Requiere**: Ninguno (pero recarga OpenResty si está configurado)
- **Qué hace**: Verifica la sintaxis de los archivos Lua y recarga OpenResty

### 03_configurar_servicio.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando cambia la configuración del host virtual
- **Requiere**: sudo
- **Qué hace**: Crea/configura el host virtual de OpenResty para la aplicación

## Gestión de servicios

```bash
# Verificar si OpenResty está en ejecución
ps aux | grep nginx

# Recargar configuración de OpenResty
sudo /usr/local/openresty/nginx/sbin/nginx -s reload

# Reiniciar OpenResty
sudo /usr/local/openresty/nginx/sbin/nginx -s stop
sudo /usr/local/openresty/nginx/sbin/nginx

# Ver logs de OpenResty
sudo tail -f /usr/local/openresty/nginx/logs/error.log
sudo tail -f /usr/local/openresty/nginx/logs/access.log
```

## Configuración de OpenResty

El script `03_configurar_servicio.sh` crea un archivo de configuración en `/usr/local/openresty/nginx/conf/sites-available/luawebapp` y lo habilita en `/usr/local/openresty/nginx/conf/sites-enabled/`.

La configuración incluye:
- Escucha en el puerto especificado (por defecto 8000)
- Ejecución de código Lua mediante `content_by_lua_file`
- Manejo de errores 404
- Procesamiento de todas las rutas a través de Lua

## Notas

- OpenResty es una distribución de Nginx que incluye módulos Lua integrados
- El código Lua se ejecuta directamente dentro de Nginx, proporcionando alto rendimiento
- No se requiere compilación, los cambios en el código Lua se reflejan después de recargar OpenResty
- OpenResty puede ejecutarse como servicio systemd o manualmente

## Ventajas de OpenResty

- **Alto rendimiento**: El código Lua se ejecuta dentro de Nginx, sin overhead de procesos separados
- **Bajo consumo de memoria**: No requiere procesos adicionales como PHP-FPM
- **Escalabilidad**: Nginx maneja eficientemente muchas conexiones concurrentes
- **Flexibilidad**: Permite lógica compleja directamente en el servidor web
