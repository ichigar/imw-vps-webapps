# VPS Ubuntu Web Apps

Este repositorio incluye aplicaciones web escritas en diferentes lenguajes de programación, junto con los scripts necesarios para desplegarlas en un servidor VPS con Ubuntu.

Antes de configurar las aplicaciones, es necesario preparar el servidor.

## Pasos

### 1. Acceso inicial al servido

En el momento de crear la VPS se añade la clave pública para poder acceder al al usurio root del servidor por ssh. Accedemois mediante:

```sh
ssh root@<server-ip>
```

### 2. Permitiendo acceso a compañeros

Si queremos que más usuarios puedan acceder al servidor, debemos añadir las llaves públicas de los usuarios al fichero `/root/.ssh/authorized_keys`. Editamos dicho fichero y añadimos al final del mismo las claver públicas de los compañeros que queremos permitir acceder al servidor.

### 3. Creando usuarios para las aplicaciones

Para cada aplicación que queramos desplegar, creamos un usuario. Por ejemplo `gouser` para la aplicación **gowebapp**, `pythonuser` para la aplicación **pythonwebapp** y así sucesivamente.

Creamos el usuario con el comando:

```sh
sudo adduser <username>
```

Donde `<username>` es el nombre del usuario que queremos crear.

Le damos permisos de administrador al usuario añadiéndolo al grupo de administradores del sistema:

```sh
sudo usermod -aG sudo <username>
```

Y si queremos poder acceder por ssh a este usuario con clave pública, copiamos el fichero `authorized_keys` del usuario root a la carpeta de claves de nuestro usuario y le cambiamos el propietario a nuestro usuario:

```sh
sudo cp /root/.ssh/authorized_keys /home/<username>/.ssh
sudo chown <username>:<username> /home/<username>/.ssh/authorized_keys
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
git clone git@github.com:ichigar/imw-vps-webapps.git
```

Seguimos la documentación de la aplicación para desplegarla. En este caso, la aplicación es **gowebapp** y la documentación se encuentra en [gowebapp/README.md](gowebapp/README.md)


### Pasos para desplegar aplicaciones

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

## Proxy inverso con caddy

Seguimos el tutorial [configuración de proxy inverso con caddy](docs/tutorial_caddy.md)

## Mejorando la seguridad del servidor

En el repositorio se incluye el script `production_setup.sh` que al ejecutarlo aplica las siguientes configuraciones:

- Instalación de paquetes necesarios para un entorno de producción y algunas herramientas útiles
- Configuración de la firewall con ufw
- Mejora la seguridad de SSH
- Configuración de fail2ban para bloquear intentos de acceso no autorizados

Una medida que no se aplica con este script pero que se recomienda es cambiar el puerto de SSH a uno distinto del 22. También es acosejable deshabilitar el acceso al root por ssh.





