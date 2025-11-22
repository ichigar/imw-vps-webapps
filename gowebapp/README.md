# Tutorial: Desplegar la app Go usando los scripts

Este tutorial parte de que **ya clonaste el repositorio en el servidor** y estás en la carpeta `gowebapp`:

```bash
cd /home/<usuario>/vps_ubuntu_web_apps/gowebapp
chmod +x scripts/*.sh
```

Requisitos:
- Ubuntu 24.04 con acceso a internet.
- Usuario con sudo (solo se pide donde hace falta).
- Puerto 8080 libre (cámbialo en el código o al lanzar el binario con `PORT`).

## 1) Preparar el servidor (paquetes de sistema)
Ejecuta una sola vez por servidor:
```bash
./scripts/01_preparar_servidor.sh
```
Instala Go y herramientas básicas.

## 2) Preparar el entorno de la aplicación
En la raíz del proyecto:
```bash
./scripts/02_preparar_entorno_aplicacion.sh
```
Resuelve dependencias (`go mod tidy`) y genera el binario `webapp`.

## 3) Probar la app en primer plano
```bash
./webapp
```
Comprueba en el navegador o con `curl`:
```
http://<IP_DEL_SERVIDOR>:8080
http://<IP_DEL_SERVIDOR>:8080/contact
http://<IP_DEL_SERVIDOR>:8080/api
```
Detén con `CTRL + C`.

## 4) Crear el servicio systemd
Genera y habilita `gowebapp.service`:
```bash
./scripts/03_crear_servicio_systemd.sh
sudo systemctl start gowebapp.service
sudo systemctl status gowebapp.service
```
Logs recientes:
```bash
sudo journalctl -u gowebapp.service -n 50 --no-pager
```

## 5) Comprobaciones rápidas
- Navegador: rutas `/`, `/contact`, `/api` en el puerto 8080.
- Puerto en escucha:
  ```bash
  ss -lptn | grep 8080
  ```

## 6) Operaciones habituales
- Tras cambios en `main.go`, recompila y reinicia:
  ```bash
  ./scripts/02_preparar_entorno_aplicacion.sh
  sudo systemctl restart gowebapp.service
  ```
- Detener:
  ```bash
  sudo systemctl stop gowebapp.service
  ```

## Código de la app
El entrypoint está en `main.go` (rutas `/`, `/contact`, `/api`). El binario se llama `webapp` y toma el puerto de la variable `PORT` (8080 por defecto).

## Documentación
- [Tutorial para desplegar la aplicación manualmente](docs/go_webapp_tutorial.md)
- [Prompt utilizado para el script crear_webapp_files](docs/prompt_create_gowebapp_files.txt)
- [Prompt utilizado para el script crear_systemd_webapp.sh](docs/prompt_setup_gowebapp.txt)

