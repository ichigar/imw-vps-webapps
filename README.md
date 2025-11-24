# VPS Ubuntu Web Apps

Este repositorio incluye aplicaciones web escritas en diferentes lenguajes de programación, junto con los scripts necesarios para desplegarlas en un servidor VPS con Ubuntu.


## `production_setup.sh`

Antes de configurar las aplicaciones, es necesario preparar el servidor.

### Pasos

1. Conéctate al servidor por SSH:

```sh
ssh root@<server-ip>
```

2. Clona el repositorio:

```sh
git clone git@github.com:ichigar/imw-vps-webapps.git
```

3. Asigna permisos de ejecución y ejecuta el script:

```sh
chmod +x production_setup.sh
./production_setup.sh
```

### Instrucciones posteriores a la instalación

1. Las llaves SSH se han configurado para el usuario `user` usando las llaves autorizadas del usuario `root`. Verifica que puedes acceder al servidor como `user`:

```sh
ssh user@<server-ip>
```

2. El usuario `root` aún puede iniciar sesión mediante autenticación por llave pública (útil para mantenimiento), pero se recomienda usar el usuario `user` para las operaciones diarias.

3. Si encuentras errores al conectarte al servidor:

   * Revisa la configuración de SSH:

     ```sh
     cat /etc/ssh/sshd_config
     ```

   * Verifica las reglas del firewall:

     ```sh
     sudo ufw status
     ```

   * Comprueba el estado del servicio SSH:

     ```sh
     sudo systemctl status ssh
     ```

4. Recuerda que la autenticación por contraseña está deshabilitada por razones de seguridad.
   Solo podrás iniciar sesión mediante llaves SSH.


### Pasos para desplegar aplicaciones

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



