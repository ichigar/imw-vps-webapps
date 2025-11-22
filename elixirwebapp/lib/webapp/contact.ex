defmodule Webapp.Contact do
  def render do
    """
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <title>Contacto</title>
    </head>
    <body>
      <h1>Formulario de Contacto</h1>

      <form>
        <label>Nombre:</label><br>
        <input type="text"><br><br>

        <label>Email:</label><br>
        <input type="email"><br><br>

        <label>Mensaje:</label><br>
        <textarea></textarea><br><br>

        <button>Enviar</button>
      </form>

      <p><a href="/">Volver al inicio</a></p>
    </body>
    </html>
    """
  end
end
