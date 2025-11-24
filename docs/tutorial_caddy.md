## Proxy inverso con caddy

Un proxy inverso (en inglés reverse proxy) es un servidor que actúa como intermediario entre los **clientes** (usuarios) y uno o varios **servidores backend** (donde realmente se encuentran las aplicaciones o los contenidos). 

En nuestro caso el servidor de backend será el mismo en el que se ejecuta el proxy inverso.

```
Usuario → Proxy inverso → 127.0.0.1:8000 (app en go)
                      ↳127.0.0.1:8080 (app en python)
```

Su función principal es recibir las peticiones de los clientes, procesarlas si es necesario (por ejemplo, añadiendo cabeceras o aplicando reglas de seguridad), y reenviarlas a la aplicación adecuada. Luego, devuelve al cliente la respuesta del servidor, como si él mismo fuera el servidor final.

### Pasos para configurar el proxy inverso

Instalamos caddy

```sh
sudo apt install caddy
```

Suponiendo que dos alumnos van a configurar nombres para acceder a dos aplicacionesdistintas:

- Aplicación en go a la escucha en el puerto `8000`
- Aplicación en Python en el puerto `8080`

Queremos acceder a las mismas desde el navegador con las urls:

- <https://go.alumno1.dpdns.org>
- <https://go.alumno2.dpdns.org>
- <https://python.alumno1.dpdns.org>
- <https://python.alumno2.dpdns.org>

Editamos el fichero `/etc/caddy/Caddyfile` para añadir los datos de acceso:

```sh
sudo nano /etc/caddy/Caddyfile
```

Insertamos. lo siguiente, adaptando las urls y puertos a vuestro caso particular y teniendo en cuenta que el email debe ser real:

```sh
# Caddyfile generado automáticamente
{
        # Hay que usar email real, en caso contrario no funcionará cadi correctamente
        email alumno1@gmail.com
        # logging global opcional:
        log {
          output file /var/log/caddy/access.log
          level INFO
        }
}

go.alumno1.dpdns.org, go.alumno2.dpdns.org {
        encode zstd gzip
        header {
                # Seguridad básica
                Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
                X-Content-Type-Options "nosniff"
                X-Frame-Options "DENY"
                Referrer-Policy "strict-origin-when-cross-origin"
        }
        reverse_proxy 127.0.0.1:8080

}

python.alumno1.dpdns.org, python.alumno2.dpdns.org {
        encode zstd gzip
        header {
                # Seguridad básica
                Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
                X-Content-Type-Options "nosniff"
                X-Frame-Options "DENY"
                Referrer-Policy "strict-origin-when-cross-origin"
        }
        reverse_proxy 127.0.0.1:8081
}
```
En caso de que esté activo el cortafuegos debemos permiter el acceso a los puertos 80 y 443:

```sh
sudo ufw allow 80,443/tcp
sudo ufw reload
```

### Aplicar cambios

Validamos el fichero de configuración con:

```sh
sudo caddy validate --config /etc/caddy/Caddyfile   # Valida sintaxis
```
Reiniciamos caddy:

```sh
sudo systemctl reload caddy                         # Recarga sin cortar conexiones
```

### Comprobaciones

Al acceder en el navegador a:

- <https://go.alumno1.dpdns.org>
- <https://go.alumno2.dpdns.org>
- <https://python.alumno1.dpdns.org>
- <https://python.alumno2.dpdns.org>

Se deberían abrir las correspondientes aplicaciones.

### Diagnóstico y resolución de problemas

Ver logs en tiempo real:

```sh
journalctl -u caddy -f
```


