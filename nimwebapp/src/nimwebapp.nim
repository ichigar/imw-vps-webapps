import jester
import os
import strutils
import strformat

const htmlStyles = """
    body { font-family: sans-serif; margin: 2rem; background: #f5f5f5; }
    .container {
      max-width: 720px;
      margin: 0 auto;
      padding: 1.5rem 2rem;
      background: #ffffff;
      border-radius: 8px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.1);
    }
    a { color: #007bff; text-decoration: none; }
    a:hover { text-decoration: underline; }
    dt { font-weight: bold; margin-top: 1rem; }
    dd { margin: 0 0 0.5rem 0; }
    label { display: block; margin-top: 1rem; font-weight: bold; }
    input, textarea {
      width: 100%;
      padding: 0.5rem;
      margin-top: 0.25rem;
      border-radius: 4px;
      border: 1px solid #ccc;
      box-sizing: border-box;
    }
    button {
      margin-top: 1.5rem;
      padding: 0.6rem 1.2rem;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      background-color: #007bff;
      color: white;
      font-size: 1rem;
    }
    button:hover { background-color: #0056b3; }
    p.note { color: #555; font-size: 0.9rem; }
    .success { color: #28a745; padding: 1rem; background: #d4edda; border-radius: 4px; margin: 1rem 0; }
"""

proc htmlContainer(content: string, title: string): string =
  result = fmt"""<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>{title}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
{htmlStyles}
  </style>
</head>
<body>
  <div class="container">
    {content}
  </div>
</body>
</html>"""

proc getClientIp(request: Request): string =
  # Intentar obtener IP de headers de proxy
  if request.headers.hasKey("x-forwarded-for"):
    let forwarded = request.headers["x-forwarded-for"]
    if forwarded.len > 0:
      return forwarded.split(',')[0].strip()
  if request.headers.hasKey("x-real-ip"):
    return request.headers["x-real-ip"]
  # IP de la conexión directa
  if request.ip.len > 0:
    return request.ip
  return "Desconocido"

routes:
  get "/":
    let clientIp = getClientIp(request)
    let userAgent = request.headers.getOrDefault("user-agent", "Desconocido")
    
    let content = fmt"""<h1>Información del cliente</h1>
    <p>Los datos de IP y navegador vienen del servidor. El resto los detecta tu navegador con JavaScript.</p>
    
    <dl>
      <dt>IP del cliente (vista por el servidor):</dt>
      <dd>{clientIp}</dd>
      
      <dt>Navegador (User-Agent):</dt>
      <dd>{userAgent}</dd>
      
      <dt>Resolución de pantalla:</dt>
      <dd id="screen-resolution">Detectando...</dd>
      
      <dt>Fecha y hora (según tu dispositivo):</dt>
      <dd id="client-datetime">Detectando...</dd>
      
      <dt>Zona horaria (según tu dispositivo):</dt>
      <dd id="client-timezone">Detectando...</dd>
    </dl>
    
    <p><a href="/contact">Ir al formulario de contacto</a></p>
    
    <script>
      const width = window.screen.width;
      const height = window.screen.height;
      document.getElementById("screen-resolution").textContent = `${width} x ${height} píxeles`;
      
      const now = new Date();
      document.getElementById("client-datetime").textContent = now.toLocaleString();
      
      const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
      document.getElementById("client-timezone").textContent = timezone;
    </script>"""
    
    resp htmlContainer(content, "Nim Web App")

  get "/contact":
    let content = """<h1>Formulario de contacto</h1>
    <p class="note">
      Este formulario es solo de ejemplo didáctico.
      Los datos NO se guardan ni se envían a ningún sitio.
    </p>
    
    <form method="post" action="/contact">
      <label for="name">Nombre</label>
      <input type="text" id="name" name="name" required>
      
      <label for="email">Correo electrónico</label>
      <input type="email" id="email" name="email" required>
      
      <label for="message">Mensaje</label>
      <textarea id="message" name="message" rows="5" required></textarea>
      
      <button type="submit">Enviar</button>
    </form>
    
    <p><a href="/">Ver información del cliente</a></p>"""
    
    resp htmlContainer(content, "Contacto - Nim Web App")

  post "/contact":
    let content = """<h1>Formulario de contacto</h1>
    <div class="success">
      <strong>¡Mensaje recibido!</strong> (Este es solo un ejemplo, los datos no se guardan)
    </div>
    <p><a href="/">Volver al inicio</a> | <a href="/contact">Enviar otro mensaje</a></p>"""
    
    resp htmlContainer(content, "Contacto - Nim Web App")

  error Http404:
    let content = """<h1>404 - Página no encontrada</h1>
    <p><a href="/">Volver al inicio</a></p>"""
    
    resp Http404, htmlContainer(content, "404 - Nim Web App")

let port = parseInt(getEnv("PORT", "3000"))
echo fmt"Servidor ejecutándose en http://localhost:{port}"
serve(settings(port = Port(port)))

