# VPS Ubuntu Web Apps

Repositorio con ejemplos para enseñar a desplegar aplicaciones web en una VPS Ubuntu 24.04. Incluye guías por lenguaje, configuración de proxy inverso con Caddy y script de hardening.

## Índice

- [Requisitos previos](#requisitos-previos)
- [Flujo recomendado](#flujo-recomendado)
- [Pasos](#pasos)
  - [1. Acceso inicial al servidor](#1-acceso-inicial-al-servidor)
  - [2. Permitiendo acceso a compañeros](#2-permitiendo-acceso-a-compañeros)
  - [3. Creando usuarios para las aplicaciones](#3-creando-usuarios-para-las-aplicaciones)
  - [4. Despliegue de aplicaciones](#4-despliegue-de-aplicaciones)
  - [Pasos para desplegar aplicaciones](#pasos-para-desplegar-aplicaciones)
- [Proxy inverso con caddy](#proxy-inverso-con-caddy)
- [Mejorando la seguridad del servidor](#mejorando-la-seguridad-del-servidor)
- [Problemas comunes](#problemas-comunes)

## Requisitos previos
- VPS limpia con Ubuntu 24.04 LTS y acceso `root` por clave pública.
- IP pública; dominio opcional si quieres HTTPS con Caddy.
- Puerto 22 abierto para SSH y 80/443 libres si usarás proxy inverso.
- Cliente SSH con tu clave pública lista para copiar (y las de tus alumnos/compañeros).

## Flujo recomendado
1. Accede como `root` y pasa el checklist de requisitos.
2. Crea un usuario por aplicación y copia su `authorized_keys`.
3. Clona el repo con ese usuario y sigue el README específico de la app.
4. (Opcional) Coloca Caddy como proxy inverso y emite certificados.
5. Ejecuta el hardening del servidor (`production_setup.sh`)

## Pasos

### 1. Acceso inicial al servido

En el momento de crear la VPS se añade las claves públicas ssh de los usuarios que podrán acceder al usurio root del servidor. Accedemos mediante:

```sh
ssh root@<server-ip>
```

### 2. Permitiendo acceso a compañeros

Si queremos que más usuarios puedan acceder al servidor, debemos añadir las llaves públicas de los usuarios al fichero `/root/.ssh/authorized_keys`. Editamos dicho fichero y añadimos al final del mismo las claves públicas de los compañeros que queremos permitir acceder al servidor.

### 3. Creando usuarios para las aplicaciones

Para cada aplicación que queramos desplegar, creamos un usuario. Por ejemplo `gouser` para la aplicación **gowebapp**, `pythonuser` para la aplicación **pythonwebapp** y así sucesivamente.

Creamos un usuario por aplicación ejecutando:

```sh
adduser <appuser>
usermod -aG sudo <appuser>      # damos permisos de sudo
mkdir -p /home/<appuser>/.ssh
cp /root/.ssh/authorized_keys /home/<appuser>/.ssh/   # copiamos las llaves públicas del usuario root
chown -R <appuser>:<appuser> /home/<appuser>/.ssh/authorized_keys     # cambiamos el propietario a nuestro usuario
chmod 700 /home/<appuser>/.ssh
chmod 600 /home/<appuser>/.ssh/authorized_keys
```

Deberíamos poder acceder con clave pública mediante:

```sh
ssh <appuser>@<IP_SERVIDOR>
```

Para cada uno de las aplicaciones que queramos desplegar seguimos los mismos pasos o creamos un script que ejecute los pasos anteriores pasándole como parámetro el nombre del usuario que queremos crear.


### 4. Despliegue de aplicaciones

Una vez creados los usuarios, podemos desplegar las aplicaciones. 

**Ejemplo. Aplicación de gowebapp**

Entramos en el usuario de la aplicación correspondientes

```sh
sudo su - gouser
```

clonamos este repositorio en la carpeta home del usuario:

```sh
git clone https://codeberg.org/ichigar/vps_ubuntu_web_apps.git
```

Seguimos la documentación de la aplicación para desplegarla. En este caso, la aplicación es **gowebapp** y la documentación se encuentra en [gowebapp/README.md](gowebapp/README.md)


#### Pasos para desplegar aplicaciones

Para el resto de aplicaciones tenemos su documentación en:

1. [aspnetwebapp](aspnetwebapp/README.md)
2. [clojurewebapp](clojurewebapp/README.md)
3. [elixirwebapp](elixirwebapp/README.md)
4. [gowebapp](gowebapp/README.md)
5. [jswebapp](jswebapp/README.md)
6. [luawebapp](luawebapp/README.md)
7. [nimwebapp](nimwebapp/README.md)
8. [phpwebapp](phpwebapp/README.md)
9. [pythonwebapp](pythonwebapp/README.md)
10. [rubywebapp](rubywebapp/README.md)
11. [rustwebapp](rustwebapp/README.md)
12. [springbootwebapp](springbootwebapp/README.md)

### 5. Proxy inverso con caddy

Seguimos el tutorial [configuración de proxy inverso con caddy](docs/tutorial_caddy.md)

### 6. Mejorando la seguridad del servidor

En el repositorio se incluye el script `production_setup.sh` que al ejecutarlo aplica las siguientes configuraciones:

- Instalación de paquetes necesarios para un entorno de producción y algunas herramientas útiles
- Configuración de la firewall con ufw
- Mejora la seguridad de SSH
- Configuración de fail2ban para bloquear intentos de acceso no autorizados

Lo ejecutamos con:

```sh
chmod +x production_setup.sh
sudo ./production_setup.sh
```

Una medida que no se aplica con este script pero que se recomienda es cambiar el puerto de SSH a uno distinto del 22. También es acosejable deshabilitar el acceso al root por ssh.

### 7.Problemas comunes
- `Permission denied (publickey)`: revisa permisos `700` en `.ssh` y `600` en `authorized_keys`.
- Servicio no arranca: `sudo systemctl status <servicio>` y `journalctl -u <servicio>`.
- Puerto ocupado: `ss -lptn | grep <puerto>` para ver qué proceso lo usa.
- Caddy no emite certificado: verifica DNS, puertos 80/443 abiertos y que el dominio resuelva a la VPS.
