<?php
require_once 'functions.php';

http_response_code(404);
$content = "<h1>404 - Página no encontrada</h1>
    <p><a href=\"/\">Volver al inicio</a></p>";

echo htmlContainer($content, "404 - PHP Web App");
?>

