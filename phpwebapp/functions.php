<?php
function htmlContainer($content, $title) {
    $styles = '
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
    ';
    
    return "<!DOCTYPE html>
<html lang=\"es\">
<head>
  <meta charset=\"UTF-8\">
  <title>$title</title>
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
  <style>
$styles
  </style>
</head>
<body>
  <div class=\"container\">
    $content
  </div>
</body>
</html>";
}

function getClientIp() {
    if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ips = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
        return trim($ips[0]);
    }
    if (!empty($_SERVER['HTTP_X_REAL_IP'])) {
        return $_SERVER['HTTP_X_REAL_IP'];
    }
    return $_SERVER['REMOTE_ADDR'] ?? 'Desconocido';
}
?>

