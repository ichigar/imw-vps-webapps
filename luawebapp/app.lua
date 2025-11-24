local html_styles = [[
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
]]

local function html_container(content, title)
    return string.format([[
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>%s</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
%s
  </style>
</head>
<body>
  <div class="container">
    %s
  </div>
</body>
</html>]], title, html_styles, content)
end

local function get_client_ip()
    local headers = ngx.req.get_headers()
    local ip = headers["X-Forwarded-For"]
    if ip and ip ~= "" then
        return string.match(ip, "([^,]+)") or ip
    end
    ip = headers["X-Real-IP"]
    if ip and ip ~= "" then
        return ip
    end
    return ngx.var.remote_addr or "Desconocido"
end

local function index()
    local client_ip = get_client_ip()
    local user_agent = ngx.var.http_user_agent or "Desconocido"
    
    local content = string.format([[
    <h1>Información del cliente</h1>
    <p>Los datos de IP y navegador vienen del servidor. El resto los detecta tu navegador con JavaScript.</p>
    
    <dl>
      <dt>IP del cliente (vista por el servidor):</dt>
      <dd>%s</dd>
      
      <dt>Navegador (User-Agent):</dt>
      <dd>%s</dd>
      
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
    </script>]], ngx.escape_html(client_ip), ngx.escape_html(user_agent))
    
    ngx.header.content_type = "text/html; charset=utf-8"
    ngx.say(html_container(content, "Lua Web App"))
end

local function contact_get()
    local content = [[
    <h1>Formulario de contacto</h1>
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
    
    <p><a href="/">Ver información del cliente</a></p>]]
    
    ngx.header.content_type = "text/html; charset=utf-8"
    ngx.say(html_container(content, "Contacto - Lua Web App"))
end

local function contact_post()
    local content = [[
    <h1>Formulario de contacto</h1>
    <div class="success">
      <strong>¡Mensaje recibido!</strong> (Este es solo un ejemplo, los datos no se guardan)
    </div>
    <p><a href="/">Volver al inicio</a> | <a href="/contact">Enviar otro mensaje</a></p>]]
    
    ngx.header.content_type = "text/html; charset=utf-8"
    ngx.say(html_container(content, "Contacto - Lua Web App"))
end

local function not_found()
    local content = [[
    <h1>404 - Página no encontrada</h1>
    <p><a href="/">Volver al inicio</a></p>]]
    
    ngx.status = 404
    ngx.header.content_type = "text/html; charset=utf-8"
    ngx.say(html_container(content, "404 - Lua Web App"))
end

-- Router principal
local uri = ngx.var.uri
local method = ngx.req.get_method()

if uri == "/" and method == "GET" then
    index()
elseif uri == "/contact" and method == "GET" then
    contact_get()
elseif uri == "/contact" and method == "POST" then
    contact_post()
else
    not_found()
end

