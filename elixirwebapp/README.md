# Tutorial: Desplegar la app Elixir usando los scripts

Este guía asume que **el código ya está clonado en el servidor** y que estás situado en la carpeta del proyecto (`elixirwebapp`), por ejemplo:

```bash
cd /home/<usuario>/vps_ubuntu_web_apps/elixirwebapp
chmod +x scripts/*.sh
```

Requisitos:
- Ubuntu 24.04 con acceso a internet.
- Usuario con sudo (solo se pedirá en los pasos que lo requieren).
- Puerto 8080 libre (puedes cambiarlo en el código si lo necesitas).

## 1) Preparar el servidor (paquetes de sistema)
Ejecuta una sola vez por servidor:
```bash
./scripts/01_preparar_servidor.sh
```
Esto instala Erlang/Elixir y herramientas básicas vía `apt`.

## 2) Preparar el entorno de la aplicación
En la raíz del proyecto:
```bash
./scripts/02_preparar_entorno_aplicacion.sh
```
Este script instala Hex y Rebar, descarga dependencias (`mix deps.get`) y compila el proyecto.

## 3) Probar la app en primer plano
Desde la raíz del proyecto:
```bash
mix run --no-halt
```
Comprueba en el navegador o con `curl`:
```
http://<IP_DEL_SERVIDOR>:8080
http://<IP_DEL_SERVIDOR>:8080/contact
```
Detén con `CTRL + C` (pulsa `a` cuando lo pida).

## 4) Crear el servicio systemd
Genera y habilita `elixirwebapp.service`:
```bash
./scripts/03_crear_servicio_systemd.sh
sudo systemctl start elixirwebapp.service
sudo systemctl status elixirwebapp.service
```
Logs recientes:
```bash
sudo journalctl -u elixirwebapp.service -n 50 --no-pager
```

## 5) Comprobaciones rápidas
- Navegador: `http://<IP_DEL_SERVIDOR>:8080` y `/contact`.
- Puerto en escucha:
  ```bash
  ss -lptn | grep 8080
  ```

## 6) Operaciones habituales
- Reiniciar tras cambios de código (recompilar antes):
  ```bash
  mix compile
  sudo systemctl restart elixirwebapp.service
  ```
- Detener:
  ```bash
  sudo systemctl stop elixirwebapp.service
  ```

## Mantenimiento de la app
El código de la aplicación está en `lib/`:
```
└── lib
    ├── webapp
    │   ├── application.ex
    │   ├── contact.ex
    │   ├── page.ex
    │   └── router.ex
    └── webapp.ex
```

## Documentación
- [Tutorial para desplegar la aplicación manualmente](docs/tutorial_elixir_webapp.md)
- [Prompt utilizado para el script crear_webapp_files](docs/prompt_script_crear_webapp_files.txt)
- [Promtpt utilizado para el script crear_systemd_webapp.sh](docs/prompt_script_crear_systemd.sh)

