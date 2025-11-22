# Despliegue de aplicación web básica en Python que muestra formulario de contacto

## 1. Estructura de archivos y directorios del repositorio

Estructura de archivos y directorios de la aplicación:

```text
pythonwebapp/                   # raíz del repositorio
├─ app.py                       # aplicación Flask
├─ requirements.txt             # dependencias de Python
├─ templates/
│  └─ contact.html              # plantilla HTML con el formulario
├─ scripts/                     # scripts de despliegue y administración
│  ├─ 01_preparar_servidor.sh
│  ├─ 02_entorno_virtual_y_dependencias.sh
│  ├─ 03_configurar_servicio_gunicorn.sh
└─ README.md                    # instrucciones para el despliegue
```

## 2. Pasos para despliegue inicial

Flujo típico tras clonar:

1. `sudo ./scripts/01_preparar_servidor.sh`
2. `./scripts/02_entorno_virtual_y_dependencias.sh`
3. `sudo ./scripts/03_configurar_servicio_gunicorn.sh`

## 3. Pasos en caso de cambio del código fuente

Después de modificar código o hacer `git pull`:

* Si han cambiado dependencias → `./scripts/02_entorno_virtual_y_dependencias.sh`
* Tras cambios de código → `sudo ./scripts/03_configurar_servicio_gunicorn.sh` (lo diseñamos para que sea idempotente y reinicie el servicio si ya existe).

## Documentación

- [Pasos para desplegar la aplicación apoyándonos en LLMs]


