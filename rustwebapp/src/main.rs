use actix_web::{web, App, HttpRequest, HttpResponse, HttpServer, Result};
use std::env;

fn html_container(content: &str, title: &str) -> String {
    format!(
        r#"<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>{}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body {{ font-family: sans-serif; margin: 2rem; background: #f5f5f5; }}
    .container {{
      max-width: 720px;
      margin: 0 auto;
      padding: 1.5rem 2rem;
      background: #ffffff;
      border-radius: 8px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.1);
    }}
    a {{ color: #007bff; text-decoration: none; }}
    a:hover {{ text-decoration: underline; }}
    dt {{ font-weight: bold; margin-top: 1rem; }}
    dd {{ margin: 0 0 0.5rem 0; }}
    label {{ display: block; margin-top: 1rem; font-weight: bold; }}
    input, textarea {{
      width: 100%;
      padding: 0.5rem;
      margin-top: 0.25rem;
      border-radius: 4px;
      border: 1px solid #ccc;
      box-sizing: border-box;
    }}
    button {{
      margin-top: 1.5rem;
      padding: 0.6rem 1.2rem;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      background-color: #007bff;
      color: white;
      font-size: 1rem;
    }}
    button:hover {{ background-color: #0056b3; }}
    p.note {{ color: #555; font-size: 0.9rem; }}
    .success {{ color: #28a745; padding: 1rem; background: #d4edda; border-radius: 4px; margin: 1rem 0; }}
  </style>
</head>
<body>
  <div class="container">
    {}
  </div>
</body>
</html>"#,
        title, content
    )
}

fn get_client_ip(req: &HttpRequest) -> String {
    // Intentar obtener IP de headers de proxy
    if let Some(forwarded_for) = req.headers().get("x-forwarded-for") {
        if let Ok(ip) = forwarded_for.to_str() {
            return ip.split(',').next().unwrap_or("Desconocido").trim().to_string();
        }
    }
    if let Some(real_ip) = req.headers().get("x-real-ip") {
        if let Ok(ip) = real_ip.to_str() {
            return ip.to_string();
        }
    }
    // IP de la conexión directa
    req.peer_addr()
        .map(|addr| addr.ip().to_string())
        .unwrap_or_else(|| "Desconocido".to_string())
}

async fn client_info(req: HttpRequest) -> Result<HttpResponse> {
    let client_ip = get_client_ip(&req);
    let user_agent = req
        .headers()
        .get("user-agent")
        .and_then(|h| h.to_str().ok())
        .unwrap_or("Desconocido");

    let content = format!(
        r#"<h1>Información del cliente</h1>
    <p>Los datos de IP y navegador vienen del servidor. El resto los detecta tu navegador con JavaScript.</p>
    
    <dl>
      <dt>IP del cliente (vista por el servidor):</dt>
      <dd>{}</dd>
      
      <dt>Navegador (User-Agent):</dt>
      <dd>{}</dd>
      
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
      document.getElementById("screen-resolution").textContent = `${{width}} x ${{height}} píxeles`;
      
      const now = new Date();
      document.getElementById("client-datetime").textContent = now.toLocaleString();
      
      const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
      document.getElementById("client-timezone").textContent = timezone;
    </script>"#,
        client_ip, user_agent
    );

    Ok(HttpResponse::Ok()
        .content_type("text/html; charset=utf-8")
        .body(html_container(&content, "Rust Web App")))
}

async fn contact_get() -> Result<HttpResponse> {
    let content = r#"<h1>Formulario de contacto</h1>
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
    
    <p><a href="/">Ver información del cliente</a></p>"#;

    Ok(HttpResponse::Ok()
        .content_type("text/html; charset=utf-8")
        .body(html_container(content, "Contacto - Rust Web App")))
}

async fn contact_post() -> Result<HttpResponse> {
    let content = r#"<h1>Formulario de contacto</h1>
    <div class="success">
      <strong>¡Mensaje recibido!</strong> (Este es solo un ejemplo, los datos no se guardan)
    </div>
    <p><a href="/">Volver al inicio</a> | <a href="/contact">Enviar otro mensaje</a></p>"#;

    Ok(HttpResponse::Ok()
        .content_type("text/html; charset=utf-8")
        .body(html_container(content, "Contacto - Rust Web App")))
}

async fn not_found() -> Result<HttpResponse> {
    let content = r#"<h1>404 - Página no encontrada</h1>
    <p><a href="/">Volver al inicio</a></p>"#;

    Ok(HttpResponse::NotFound()
        .content_type("text/html; charset=utf-8")
        .body(html_container(content, "404 - Rust Web App")))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let port = env::var("PORT")
        .unwrap_or_else(|_| "3000".to_string())
        .parse::<u16>()
        .unwrap_or(3000);

    println!("Servidor ejecutándose en http://localhost:{}", port);

    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(client_info))
            .route("/contact", web::get().to(contact_get))
            .route("/contact", web::post().to(contact_post))
            .default_service(web::route().to(not_found))
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}

