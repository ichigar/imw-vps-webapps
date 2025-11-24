(ns clojurewebapp.core
  (:require [compojure.core :refer [defroutes GET POST]]
            [compojure.route :as route]
            [ring.adapter.jetty :as jetty]
            [ring.middleware.params :refer [wrap-params]]
            [ring.middleware.keyword-params :refer [wrap-keyword-params]]
            [ring.util.response :as response]))

(defn html-container [content title]
  (str "<!DOCTYPE html>
<html lang=\"es\">
<head>
  <meta charset=\"UTF-8\">
  <title>" title "</title>
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
  <style>
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
  </style>
</head>
<body>
  <div class=\"container\">
    " content "
  </div>
</body>
</html>"))

(defn get-client-ip [request]
  (or (get-in request [:headers "x-forwarded-for"])
      (get-in request [:headers "x-real-ip"])
      (:remote-addr request)
      "Desconocido"))

(defn client-info-handler [request]
  (let [client-ip (get-client-ip request)
        user-agent (get-in request [:headers "user-agent"] "Desconocido")
        content (str "<h1>Información del cliente</h1>
    <p>Los datos de IP y navegador vienen del servidor. El resto los detecta tu navegador con JavaScript.</p>
    
    <dl>
      <dt>IP del cliente (vista por el servidor):</dt>
      <dd>" client-ip "</dd>
      
      <dt>Navegador (User-Agent):</dt>
      <dd>" user-agent "</dd>
      
      <dt>Resolución de pantalla:</dt>
      <dd id=\"screen-resolution\">Detectando...</dd>
      
      <dt>Fecha y hora (según tu dispositivo):</dt>
      <dd id=\"client-datetime\">Detectando...</dd>
      
      <dt>Zona horaria (según tu dispositivo):</dt>
      <dd id=\"client-timezone\">Detectando...</dd>
    </dl>
    
    <p><a href=\"/contact\">Ir al formulario de contacto</a></p>
    
    <script>
      const width = window.screen.width;
      const height = window.screen.height;
      document.getElementById(\"screen-resolution\").textContent = `${width} x ${height} píxeles`;
      
      const now = new Date();
      document.getElementById(\"client-datetime\").textContent = now.toLocaleString();
      
      const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
      document.getElementById(\"client-timezone\").textContent = timezone;
    </script>")]
    (-> (response/response (html-container content "Clojure Web App"))
        (response/content-type "text/html; charset=utf-8"))))

(defn contact-get-handler [request]
  (let [content "<h1>Formulario de contacto</h1>
    <p class=\"note\">
      Este formulario es solo de ejemplo didáctico.
      Los datos NO se guardan ni se envían a ningún sitio.
    </p>
    
    <form method=\"post\" action=\"/contact\">
      <label for=\"name\">Nombre</label>
      <input type=\"text\" id=\"name\" name=\"name\" required>
      
      <label for=\"email\">Correo electrónico</label>
      <input type=\"email\" id=\"email\" name=\"email\" required>
      
      <label for=\"message\">Mensaje</label>
      <textarea id=\"message\" name=\"message\" rows=\"5\" required></textarea>
      
      <button type=\"submit\">Enviar</button>
    </form>
    
    <p><a href=\"/\">Ver información del cliente</a></p>"]
    (-> (response/response (html-container content "Contacto - Clojure Web App"))
        (response/content-type "text/html; charset=utf-8"))))

(defn contact-post-handler [request]
  (let [content "<h1>Formulario de contacto</h1>
    <div class=\"success\">
      <strong>¡Mensaje recibido!</strong> (Este es solo un ejemplo, los datos no se guardan)
    </div>
    <p><a href=\"/\">Volver al inicio</a> | <a href=\"/contact\">Enviar otro mensaje</a></p>"]
    (-> (response/response (html-container content "Contacto - Clojure Web App"))
        (response/content-type "text/html; charset=utf-8"))))

(defn not-found-handler [request]
  (let [content "<h1>404 - Página no encontrada</h1>
    <p><a href=\"/\">Volver al inicio</a></p>"]
    (-> (response/response (html-container content "404 - Clojure Web App"))
        (response/content-type "text/html; charset=utf-8")
        (response/status 404))))

(defroutes app-routes
  (GET "/" request (client-info-handler request))
  (GET "/contact" request (contact-get-handler request))
  (POST "/contact" request (contact-post-handler request))
  (route/not-found (not-found-handler nil)))

(def app
  (-> app-routes
      wrap-keyword-params
      wrap-params))

(defn -main [& args]
  (let [port (Integer/parseInt (or (System/getenv "PORT") "3000"))]
    (println (str "Servidor ejecutándose en http://localhost:" port))
    (jetty/run-jetty app {:port port :join? true})))

