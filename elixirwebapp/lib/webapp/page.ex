defmodule Webapp.Page do
  import Plug.Conn

  def render(conn) do
    ip =
      conn.remote_ip
      |> Tuple.to_list()
      |> Enum.join(".")

    ua =
      conn
      |> get_req_header("user-agent")
      |> List.first()

    now =
      DateTime.utc_now()
      |> DateTime.to_string()

    screen_info = "<script>document.write(screen.width + ' x ' + screen.height)</script>"

    """
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <title>Información del Cliente</title>
    </head>
    <body>
      <h1>Aplicación Web en Elixir</h1>

      <p><a href="/contacto">Ir a contacto</a></p>

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
