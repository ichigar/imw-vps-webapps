package com.example.springbootwebapp;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpServletRequest;

@RestController
public class ErrorController implements org.springframework.boot.web.servlet.error.ErrorController {

    private static final String HTML_STYLES = """
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
    """;

    private String htmlContainer(String content, String title) {
        return String.format("""
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
            </html>""", title, HTML_STYLES, content);
    }

    @RequestMapping("/error")
    public ResponseEntity<String> handleError(HttpServletRequest request) {
        String content = """
            <h1>404 - Página no encontrada</h1>
            <p><a href="/">Volver al inicio</a></p>""";

        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .contentType(MediaType.TEXT_HTML)
                .body(htmlContainer(content, "404 - Spring Boot Web App"));
    }
}

