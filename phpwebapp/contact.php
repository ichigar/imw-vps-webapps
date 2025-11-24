<?php
require_once 'functions.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $content = "<h1>Formulario de contacto</h1>
    <div class=\"success\">
      <strong>¡Mensaje recibido!</strong> (Este es solo un ejemplo, los datos no se guardan)
    </div>
    <p><a href=\"/\">Volver al inicio</a> | <a href=\"/contact\">Enviar otro mensaje</a></p>";
    
    echo htmlContainer($content, "Contacto - PHP Web App");
} else {
    $content = "<h1>Formulario de contacto</h1>
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
    
    <p><a href=\"/\">Ver información del cliente</a></p>";
    
    echo htmlContainer($content, "Contacto - PHP Web App");
}
?>

