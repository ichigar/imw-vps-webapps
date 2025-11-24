<?php
require_once 'functions.php';

$clientIp = getClientIp();
$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'Desconocido';

$content = "<h1>Información del cliente</h1>
    <p>Los datos de IP y navegador vienen del servidor. El resto los detecta tu navegador con JavaScript.</p>
    
    <dl>
      <dt>IP del cliente (vista por el servidor):</dt>
      <dd>" . htmlspecialchars($clientIp) . "</dd>
      
      <dt>Navegador (User-Agent):</dt>
      <dd>" . htmlspecialchars($userAgent) . "</dd>
      
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
    </script>";

echo htmlContainer($content, "PHP Web App");
?>

