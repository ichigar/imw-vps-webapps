# Tutorial: Despliegue de una aplicación web en Python utilizando Ubuntu Server y Gunicorn

## Objetivo

Aprender a:

1. Desplegar una aplicación web escrita en Python en Ubuntu Server.
2. Utilizar un LLM como asistente para generar scripts de automatización.
3. Ejecutar los scripts en el orden correcto para dejar la aplicación disponible desde el servidor.

Al finalizar, la aplicación estará funcionando como un servicio del sistema.


## Requisitos previos

Antes de comenzar asegúrate de tener:

* Ubuntu Server instalado y accesible (por SSH o consola).
* Un usuario con permisos para usar `sudo`.
* Git instalado.
* El repositorio de la aplicación clonado en tu carpeta personal:

```bash
cd ~
git clone https://codeberg.org/ichigar/vps_ubuntu_web_apps.git
cd vps_ubuntu_web_apps/pythonwebapp
```

Estructura esperada del repositorio:

```text
pythonwebapp/
├─ app.py
├─ requirements.txt
├─ static/
├─ README.md
└─ templates
    ├── client_info.html
    └── contact.html

```

## Paso 1: Crear la carpeta de scripts

Situados en la raíz del repositorio:

```bash
mkdir scripts
```

## Paso 2: Generar los scripts con ayuda de un LLM

Los siguientes prompts son instrucciones **en lenguaje natural**, que el LLM transformará en un script Bash completo.

Cada script debe guardarse dentro de la carpeta `scripts/` con permisos de ejecución.

### Script 1: Preparar el servidor

**Prompt para LLM**
(paste y obtén el script)

```
Necesito que generes un script llamado `01_preparar_servidor.sh`.

El script debe actualizar los paquetes del sistema Ubuntu e instalar todo el software necesario para ejecutar y desplegar una aplicación web flask con python.

Debe comprobar que los comandos se han instalado correctamente.

El script se ejecutará con sudo. Incluye comentarios para que un estudiante entienda qué hace cada bloque.

Devuélveme solo el código del script.
```
Cuando el LLM devuelva el script editamos `scripts/01_preparar_servidor.sh` y pegamos el resultado obtenido en el LLM y damos permisos de ejecución al script:

```bash
chmod +x scripts/01_preparar_servidor.sh
```

### Script 2: Crear entorno virtual e instalar dependencias

**Prompt para LLM**

```
Necesito un script llamado `02_entorno_virtual_y_dependencias.sh`.
El script debe:

* Ubicar la raíz del proyecto como la carpeta padre del script.
* Dar los pasos necesarios para que la aplicación quede preparada para ejecutarse
```

Guardar y hacer ejecutable.


### Script 3: Configurar servicio Gunicorn (despliegue)

**Prompt para LLM**

```
Necesito un script llamado `03_configurar_servicio_gunicorn.sh`.
El script configurará un servicio systemd `pythonwebapp.service` que ejecute la aplicación usando Gunicorn desde el la carpeta del proyecto.
Debe:

* El script comprobar que se esta ejecutando con sudo
* Incluir variable para especificar el puerto de la aplicación que por defecto será el 8000.
* La aplicación se pondrá a la escucha por http
* La aplicación deberá ejecutarse con el usuario del proyecto y desde la carpeta del proyecto
* Habilitar y reiniciar el servicio.
* Mostrar el estado del servicio.

Añade comentarios mostrando los pasos realizados.
```

Guardar y hacer ejecutable.

## Paso 3: Ejecutar los scripts en orden

Desde la raíz del proyecto:

### 1. Preparar servidor

```bash
sudo ./scripts/01_preparar_servidor.sh
```

### 2. Crear entorno virtual e instalar dependencias

```bash
./scripts/02_entorno_virtual_y_dependencias.sh
```

### 3. Desplegar aplicación como servicio

```bash
sudo ./scripts/03_configurar_servicio_gunicorn.sh
```

## Paso 4: Probar la aplicación

La aplicación queda funcionando en el puerto **8000**.
Desde un navegador:

```
http://IP_DEL_SERVIDOR:8000/
http://IP_DEL_SERVIDOR:8000/contact
```

Si funciona deberías ver la información del cliente que abre la página y el formulario de contacto.

Comando útil para ver el estado del servicio:

```bash
systemctl status contact_app.service
```

---

## Paso 5: Cómo volver a desplegar tras cambios del código fuente

Después de modificar la aplicación (o hacer `git pull`):

1. Si cambian dependencias:

```bash
./scripts/03_entorno_virtual_y_dependencias.sh
```

2. Siempre que modifiques `app.py` o plantillas HTML:

```bash
sudo ./scripts/04_configurar_servicio_gunicorn.sh
```

Así se recarga la app en producción sin reinstalar todo de nuevo.

---

## Resultado final

* Despliegue real de aplicaciones Python usando entornos virtuales.
* Automatización mediante scripts Bash.
* Uso de servicios systemd para producción.
* Buenas prácticas de seguridad básicas.
* Uso de LLMs como herramienta de asistencia técnica documentada.


