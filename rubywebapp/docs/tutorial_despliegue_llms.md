# Tutorial: Despliegue de una aplicación web en Ruby on Rails utilizando Ubuntu Server y Puma

## Objetivo

Aprender a:

1. Desplegar una aplicación web escrita en Ruby on Rails en Ubuntu Server.
2. Utilizar un LLM como asistente para generar scripts de automatización.
3. Ejecutar los scripts en el orden correcto para dejar la aplicación disponible desde el servidor.

Al finalizar, la aplicación estará funcionando como un servicio del sistema usando Puma.

## Requisitos previos

Antes de comenzar asegúrate de tener:

* Ubuntu Server instalado y accesible (por SSH o consola).
* Un usuario con permisos para usar `sudo`.
* Git instalado.
* El repositorio de la aplicación clonado en tu carpeta personal:

```bash
cd ~
git clone https://codeberg.org/ichigar/vps_ubuntu_web_apps.git
cd vps_ubuntu_web_apps/rubywebapp
```

Estructura esperada del repositorio:

```text
rubywebapp/
├─ Gemfile
├─ app/
│  ├─ controllers/
│  └─ views/
├─ config/
├─ scripts/
└─ README.md
```

## Paso 1: Crear la carpeta de scripts

Situados en la raíz del repositorio:

```bash
mkdir -p scripts
```

## Paso 2: Generar los scripts con ayuda de un LLM

Los siguientes prompts son instrucciones **en lenguaje natural**, que el LLM transformará en un script Bash completo.
Cada script debe guardarse dentro de la carpeta `scripts/` con permisos de ejecución.

### Script 1: Preparar el servidor

**Prompt para LLM**

```
Necesito que generes un script llamado `01_preparar_servidor.sh`.

El script debe actualizar los paquetes del sistema Ubuntu e instalar todo el software necesario para ejecutar y desplegar una aplicación web en Ruby on Rails (Ruby, Bundler, Puma, dependencias de compilación).

Debe comprobar que los comandos se han instalado correctamente.

El script se ejecutará con sudo. Incluye comentarios para que un estudiante entienda qué hace cada bloque.

Devuélveme solo el código del script.
```

### Script 2: Instalar dependencias con Bundler

**Prompt para LLM**

```
Necesito un script llamado `02_entorno-virtual_y_dependencias.sh`.
El script debe:

* Ubicar la raíz del proyecto como la carpeta padre del script.
* Configurar bundler para instalar en vendor/bundle y excluir los grupos development/test.
* Instalar las dependencias del Gemfile.
* Ejecutar una comprobación básica de carga de la aplicación en producción.
```

### Script 3: Configurar servicio Puma (despliegue)

**Prompt para LLM**

```
Necesito un script llamado `03_configurar_servicio_puma.sh`.
El script configurará un servicio systemd `rubywebapp.service` que ejecute la aplicación usando Puma desde la carpeta del proyecto.
Debe:

* Comprobar que se ejecuta con sudo.
* Incluir variable para especificar el puerto de la aplicación (por defecto 3000).
* Definir SECRET_KEY_BASE (usando una variable de entorno o generando una si falta).
* La aplicación deberá ejecutarse con el usuario del proyecto y desde la carpeta del proyecto.
* Habilitar y reiniciar el servicio.
* Mostrar el estado del servicio.

Añade comentarios mostrando los pasos realizados.
```

## Paso 3: Ejecutar los scripts en orden

Desde la raíz del proyecto:

### 1. Preparar servidor

```bash
sudo ./scripts/01_preparar_servidor.sh
```

### 2. Instalar dependencias

```bash
./scripts/02_entorno-virtual_y_dependencias.sh
```

### 3. Desplegar aplicación como servicio

```bash
sudo APP_PORT=3000 ./scripts/03_configurar_servicio_puma.sh
```

## Paso 4: Probar la aplicación

La aplicación queda funcionando en el puerto **3000**.
Desde un navegador:

```
http://IP_DEL_SERVIDOR:3000/
http://IP_DEL_SERVIDOR:3000/contact
```

Verás la información del cliente y el formulario de contacto. Recuerda que los datos del formulario no se procesan: es un ejemplo didáctico.

Comando útil para ver el estado del servicio:

```bash
systemctl status rubywebapp.service
```

---

## Paso 5: Cómo volver a desplegar tras cambios del código fuente

Después de modificar la aplicación (o hacer `git pull`):

1. Si cambian dependencias:

```bash
./scripts/02_entorno-virtual_y_dependencias.sh
```

2. Siempre que modifiques controladores o vistas:

```bash
sudo APP_PORT=3000 ./scripts/03_configurar_servicio_puma.sh
```

Así se recarga la app en producción sin reinstalar todo de nuevo.

---

## Resultado final

* Despliegue real de aplicaciones Rails usando Bundler y Puma.
* Automatización mediante scripts Bash.
* Uso de servicios systemd para producción.
* Buenas prácticas de seguridad básicas.
* Uso de LLMs como herramienta de asistencia técnica documentada.
