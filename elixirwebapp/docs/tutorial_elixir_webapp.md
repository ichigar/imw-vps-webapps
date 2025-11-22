# Tutorial: Despliegue de una Aplicación Web Básica en Elixir con Plug y Cowboy

## 1. Introducción

Este tutorial describe cómo crear, desplegar y mantener una aplicación web básica escrita en Elixir, utilizando las Plug y Cowboy. 
- Plug es un módulo de Elixir que gestiona las conexiones y facilita la construcción de aplicaciones web, ofreciendo funciones como manejo de rutas, cabeceras y respuestas. 
- Cowboy funciona como el servidor HTTP subyacente, procesando las peticiones entrantes y entregándolas a Plug para su tratamiento. 

La aplicación mostrará información dinámica del cliente y dispondrá de una página de contacto con un formulario simple.

### Características del lenguaje Elixir

* Tipo: Lenguaje funcional concurrente ejecutado sobre la máquina virtual BEAM (de Erlang).
* Interpretado/Compilado: El código se compila a bytecode que ejecuta la BEAM.
* Uso en la web: Se utiliza habitualmente con el framework Phoenix, aunque también permite servir aplicaciones web directamente usando Plug y Cowboy.
* Ventajas: Alta concurrencia, escalabilidad, tolerancia a fallos y rendimiento estable.

## 2. Entorno de trabajo

* Sistema operativo: Ubuntu Server 24.04
* Elixir: 1.14+
* Erlang/OTP: 25+
* Editor sugerido: Visual Studio Code / VSCodium.
* Objetivo del despliegue: Aplicación escuchando en `http://0.0.0.0:8080` y ejecutada como servicio.

## 3. Instalación de dependencias

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y erlang elixir git curl
```

## 4. Creación del proyecto

Al ejecutar `mix new` en una carpeta, se creará la estructura básica de carpetas y directorios de un proyecto en Elixir.

```bash
mix new webapp
cd webapp
```

La estructura que se creará será:

```
webapp/
├── mix.exs
├── README.md
├── .gitignore
├── lib/
│   ├── webapp.ex
│   └── webapp/
│       └── application.ex
├── test/
│   └── webapp_test.exs
└── test/test_helper.exs
```

* **mix.exs**: Archivo principal de configuración del proyecto. Define dependencias, versión de Elixir, nombre de la aplicación y tareas disponibles.
* **README.md**: Documento informativo inicial del proyecto.
* **.gitignore**: Indica qué archivos deben ignorarse si se usa Git.
* **lib/**: Carpeta que contiene el código fuente de la aplicación.

  * **lib/webapp.ex**: Módulo principal creado por defecto. En esta aplicación no se usa directamente, pero forma parte de la estructura estándar.
  * **lib/webapp/application.ex**: Módulo que define la aplicación OTP y los procesos supervisados (como Cowboy). Aquí se configura el servidor HTTP.
* **test/**: Carpeta para pruebas automatizadas. No se utiliza en este tutorial.

Además de los archivos que se crean inicialmente, algunos de los cuales editaremos y modificaremos, en pasos siguientes añadiremos los siguientes archivos al proyecto:

* **lib/webapp/router.ex**: Define las rutas HTTP de la aplicación (`/` y `/contacto`).
* **lib/webapp/page.ex**: Genera el contenido HTML de la página principal.
* **lib/webapp/contact.ex**: Contiene el formulario de contacto.


## 5. Editando archivos del proyecto

### `mix.exs`

El fichero `mix.exs` permite definir las librerías necesarias de nuestro proyecto. Para nuestra aplicación incluiremos `plug` y `cowboy`.

Editamos `mix.exs` de forma que su contenido sea:

```elixir
defp deps do
  [
    {:plug_cowboy, "~> 2.7"},
    {:plug, "~> 1.14"}
  ]
end
```

A continuación ejecutamos lo siguiente para que se descarguen e integren en el proyecto los paquetes declarados previamente:

```bash
mix deps.get
```

### `router.ex`

Este archivo define cómo responde la aplicación a las peticiones del navegador. Cada ruta enlaza directamente con un módulo encargado de generar la respuesta, permitiendo separar la lógica de navegación del contenido.
Archivo: `lib/webapp/router.ex`

```elixir
defmodule Webapp.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, Webapp.Page.render(conn))
  end

  get "/contacto" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, Webapp.Contact.render())
  end

  match _ do
    send_resp(conn, 404, "Página no encontrada")
  end
end
```
Se generan dos rutas, `/` y `/contacto` que mostrarán la información del cliente y el formulario de contacto respectivamente.

### `page.ex`

Este archivo genera el contenido HTML mostrado al acceder a la ruta principal (`/`). A partir de la información recibida en la conexión, se generan dinámicamente datos del cliente y del servidor antes de enviarse como respuesta.

Archivo a crear: `lib/webapp/page.ex`

```elixir
defmodule Webapp.Page do
  def render(conn) do
    ip = Tuple.to_list(conn.remote_ip) |> Enum.join(".")
    ua = get_req_header(conn, "user-agent") |> List.first()
    now = DateTime.utc_now() |> DateTime.to_string()
    screen_info = "<script>document.write(screen.width + ' x ' + screen.height)</script>"

    """
    <!DOCTYPE html>
    <html lang=\"es\">
    <head>
      <meta charset=\"UTF-8\">
      <title>Información del Cliente</title>
    </head>
    <body>
      <h1>Aplicación Web en Elixir</h1>

      <p><a href=\"/contacto\">Ir a contacto</a></p>

      <h2>Datos del Servidor</h2>
      <p>Fecha y hora: #{now}</p>
      <p>Versión de Elixir: #{System.version()}</p>

      <h2>Datos del Cliente</h2>
      <p>IP: #{ip}</p>
      <p>Navegador: #{ua}</p>
      <p>Resolución de pantalla: #{screen_info}</p>

      <p>Lenguaje utilizado: Elixir</p>
    </body>
    </html>
    """
  end
end
```

### `contact.ex`

Este archivo genera el HTML del formulario de contacto mostrado al acceder a la ruta (`/contact`).

Archivo a crear: `lib/webapp/contact.ex`

```elixir
defmodule Webapp.Contact do
  def render do
    """
    <!DOCTYPE html>
    <html lang=\"es\">
    <head>
      <meta charset=\"UTF-8\">
      <title>Contacto</title>
    </head>
    <body>
      <h1>Formulario de Contacto</h1>

      <form>
        <label>Nombre:</label><br>
        <input type=\"text\"><br><br>

        <label>Email:</label><br>
        <input type=\"email\"><br><br>

        <label>Mensaje:</label><br>
        <textarea></textarea><br><br>

        <button>Enviar</button>
      </form>

      <p><a href=\"/\">Volver al inicio</a></p>
    </body>
    </html>
    """
  end
end
```

### `application.ex`

Archivo para configurar el servidor HTTP. Indica cómo se inicia la aplicación dentro del entorno de ejecución: se definen los parámetros del servidor Cowboy, incluyendo el puerto y la interfaz en la que escuchará.

Editamos el archivo `lib/webapp/application.ex` para que su contenido sea:

```elixir
defmodule Webapp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {
        Plug.Cowboy,
        scheme: :http,
        plug: Webapp.Router,
        options: [ip: {0, 0, 0, 0}, port: 8080]
      }
    ]

    opts = [strategy: :one_for_one, name: Webapp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

## 6. Ejecutar el servidor

La siguiente orden inicia todos los procesos definidos en la aplicación y mantiene al servidor escuchando de forma continua, permitiendo que las rutas respondan a las solicitudes entrantes.

```bash
mix run --no-halt
```
### Comprobación

Si accedemos a la IP del servidor por el puerto 8080 a las dos rutas definidas para la aplicación deberíamos ver el contenido de la misma:

```
http://<IP_DEL_SERVIDOR>:8080
http://<IP_DEL_SERVIDOR>:8080/contact
```

También podemos comprobar que hay un proceso a la escucha por el puerto 8080 ejecutando:

```bash
ss -lptn
```
Debería mostrar algo como:

```bash
State       Recv-Q      Send-Q           Local Address:Port            Peer Address:Port     Process                                     
LISTEN      0           1024                   0.0.0.0:8080                 0.0.0.0:*         users:(("beam.smp",pid=37589,fd=25)) 
```

## 7. Arranque automático con systemd

El archivo de servicio permite que la aplicación se inicie automáticamente tras un reinicio del sistema. 

Al configurarse como servicio, el servidor web queda gestionado por systemd, que controla su puesta en marcha y su supervisión básica. Ten en cuenta que deberás cambiar el nombre del usuario de `ubuntu` por el que vayas a usar en el servidor.

Archivo a editar: `/etc/systemd/system/webapp.service`

```ini
[Unit]
Description=Webapp Elixir Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/webapp
ExecStart=/usr/bin/mix run --no-halt
Restart=always

[Install]
WantedBy=multi-user.target
```

Activación:

```bash
sudo systemctl daemon-reload
sudo systemctl enable webapp
sudo systemctl start webapp
```

## 8 Cambiar el puerto de escucha

Modificar el puerto dentro del archivo de configuración permite adaptar la aplicación a distintos escenarios de despliegue. Al reiniciar, el servidor se levantará escuchando en la nueva ubicación definida.

Para ello editamos `lib/webapp/application.ex` modificando la línea:

```
options: [ip: {0,0,0,0}, port: 8080]
```

poniendo el nuevo puerto:

```
options: [ip: {0,0,0,0}, port: 9090]
```

Para que el cambio se aplique reiniciamos la aplicación se la estamos ejecutando manualmente:

```bash
mix run --no-halt
```
Si pide instalar alguna dependencia aplicar las opciones por defecto:


O, si se ha configurado como servicio de systemd reiniciamos con:

```bash
sudo systemctl restart webapp
```

Comprobamos el cambio de puerto accedeniendo a la app por el nuevo puerto:

```
http://<IP_DEL_SERVIDOR>:9090
```
