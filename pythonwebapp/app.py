"""
Aplicación web básica de contacto con un formulario HTML.

Tecnologías clave:
- Flask: microframework de Python para crear aplicaciones web.
- Plantillas: archivos HTML que se renderizan desde Python.

IMPORTANTE:
En este ejemplo, los datos del formulario NO se procesan ni almacenan.
El objetivo es practicar el despliegue, no la lógica de backend.
"""

from flask import Flask, render_template, request

app = Flask(__name__)


@app.route("/")
def client_info():
    """
    Página que muestra información básica del cliente:
    - IP (vista desde el servidor)
    - Navegador (cadena 'User-Agent')
    El resto de datos (resolución, hora y zona horaria) los obtendrá JavaScript en el navegador.
    """

    # IP del cliente vista desde el servidor
    client_ip = request.remote_addr

    # Cadena User-Agent: información del navegador y sistema operativo
    user_agent = request.headers.get("User-Agent", "Desconocido")

    return render_template(
        "client_info.html",
        client_ip=client_ip,
        user_agent=user_agent,
    )

@app.route("/contact", methods=["GET", "POST"])
def contact():
    """
    Ruta principal de la aplicación.
    - GET: muestra el formulario vacío.
    - POST: simplemente vuelve a mostrar el formulario sin procesar datos.
    """
    if request.method == "POST":
        # Aquí iría la lógica de una aplicación real (validaciones, guardado, etc.)
        # En este ejercicio didáctico NO se hace nada con los datos.
        pass
    return render_template("contact.html")


if __name__ == "__main__":
    # Servidor de desarrollo. Útil para pruebas locales, pero NO para producción.
    # En producción usaremos Gunicorn, que ejecutará 'app:app'.
    app.run(host="0.0.0.0", port=5000, debug=True)