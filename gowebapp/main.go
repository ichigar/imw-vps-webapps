package main

import (
    "fmt"
    "log"
    "net"
    "net/http"
    "strings"
    "time"
)

// Obtiene la IP del cliente considerando proxies
func getClientIP(r *http.Request) string {
    if x := r.Header.Get("X-Forwarded-For"); x != "" {
        parts := strings.Split(x, ",")
        if ip := strings.TrimSpace(parts[0]); ip != "" {
            return ip
        }
    }
    if ip := r.Header.Get("X-Real-IP"); ip != "" {
        return ip
    }
    if ip := r.Header.Get("CF-Connecting-IP"); ip != "" {
        return ip
    }
    host, _, err := net.SplitHostPort(r.RemoteAddr)
    if err != nil {
        return r.RemoteAddr
    }
    return host
}

// Muestra la página HTML con fecha e IP
func homeHandler(w http.ResponseWriter, r *http.Request) {
    now := time.Now()
    dateFriendly := now.Format("2006-01-02 15:04:05 Monday")
    dateISO := now.Format(time.RFC3339)
    clientIP := getClientIP(r)

    html := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
  <title>Info Cliente - Go Server</title>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; max-width: 600px; margin: 40px auto; }
    .box { background: #f0f8ff; padding: 20px; margin-bottom: 20px; border-left: 4px solid #007acc; }
    a { color: #007acc; text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>🕒 Fecha e IP del Cliente</h1>
  <div class="box">
    <h2>Fecha del Servidor</h2>
    <p><strong>Legible:</strong> %s</p>
    <p><strong>ISO 8601:</strong> %s</p>
    <p><strong>Unix:</strong> %d</p>
  </div>
  <div class="box">
    <h2>Datos del Cliente</h2>
    <p><strong>IP:</strong> %s</p>
    <p><strong>User-Agent:</strong> %s</p>
    <p><strong>Método:</strong> %s</p>
    <p><strong>URL:</strong> %s</p>
  </div>
  <div class="box">
    <h2>Otras páginas</h2>
    <p><a href="/contact">Ir a la página de contacto</a></p>
    <p><a href="/api">Ver datos en formato JSON</a></p>
  </div>
</body>
</html>
`, dateFriendly, dateISO, now.Unix(),
        clientIP, r.Header.Get("User-Agent"), r.Method, r.URL.Path)

    w.Header().Set("Content-Type", "text/html; charset=utf-8")
    fmt.Fprint(w, html)
    log.Printf("IP %s - %s", clientIP, r.URL.Path)
}

// Página de contacto con un formulario básico (solo se muestra, no se procesa)
func contactHandler(w http.ResponseWriter, r *http.Request) {
    // Ignoramos el método (GET, POST, etc.) de forma explícita:
    // solo mostramos el formulario, no procesamos los datos.
    html := `
<!DOCTYPE html>
<html>
<head>
  <title>Contacto - Go Server</title>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; max-width: 600px; margin: 40px auto; }
    .box { background: #f9f9f9; padding: 20px; margin-bottom: 20px; border-left: 4px solid #28a745; }
    label { display: block; margin-top: 10px; }
    input[type="text"], input[type="email"], textarea {
      width: 100%%;
      padding: 8px;
      box-sizing: border-box;
      margin-top: 4px;
    }
    button {
      margin-top: 15px;
      padding: 10px 15px;
      border: none;
      background: #28a745;
      color: white;
      cursor: pointer;
    }
    button:hover {
      opacity: 0.9;
    }
    a { color: #007acc; text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>📨 Página de contacto</h1>
  <div class="box">
    <p>Este es un formulario de contacto de ejemplo. Los datos NO se procesan en el servidor, solo se muestran los campos para practicar HTML.</p>
    <form method="post" action="/contact">
      <label for="name">Nombre</label>
      <input type="text" id="name" name="name" placeholder="Tu nombre">

      <label for="email">Correo electrónico</label>
      <input type="email" id="email" name="email" placeholder="tu@ejemplo.com">

      <label for="message">Mensaje</label>
      <textarea id="message" name="message" rows="5" placeholder="Escribe tu mensaje aquí..."></textarea>

      <button type="submit">Enviar (no hace nada)</button>
    </form>
  </div>
  <p><a href="/">Volver a la página principal</a></p>
</body>
</html>
`

    w.Header().Set("Content-Type", "text/html; charset=utf-8")
    fmt.Fprint(w, html)
    log.Printf("Página de contacto visitada - %s", r.RemoteAddr)
}

// API JSON con datos
func apiHandler(w http.ResponseWriter, r *http.Request) {
    now := time.Now()
    clientIP := getClientIP(r)
    json := fmt.Sprintf(`{
  "timestamp": "%s",
  "unix": %d,
  "ip": "%s"
}`, now.Format(time.RFC3339), now.Unix(), clientIP)

    w.Header().Set("Content-Type", "application/json")
    fmt.Fprint(w, json)
}

func main() {
    http.HandleFunc("/", homeHandler)        // Página principal
    http.HandleFunc("/contact", contactHandler) // Página de contacto
    http.HandleFunc("/api", apiHandler)      // API JSON

    addr := "0.0.0.0:8080"
    log.Printf("Servidor iniciado en %s", addr)
    log.Fatal(http.ListenAndServe(addr, nil))
}
