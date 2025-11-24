# Aplicación Web Spring Boot Simple

Aplicación web minimalista en Java usando Spring Boot.

## Estructura

```
springbootwebapp/
├── src/
│   └── main/
│       ├── java/com/example/springbootwebapp/
│       │   ├── SpringbootwebappApplication.java  # Clase principal
│       │   ├── PageController.java                # Controlador de páginas
│       │   └── ErrorController.java               # Controlador de errores 404
│       └── resources/
│           └── application.properties           # Configuración
├── pom.xml                                        # Dependencias Maven
├── scripts/
│   ├── 01_preparar_servidor.sh    # Instalar Java y Maven
│   ├── 02_preparar_entorno.sh     # Compilar y empaquetar (ejecutar tras cambios de código)
│   └── 03_configurar_servicio.sh  # Configurar servicio systemd
└── README.md
```

## Instalación y despliegue

### Despliegue inicial (solo la primera vez)

```bash
# 1. Instalar Java y Maven
sudo ./scripts/01_preparar_servidor.sh

# 2. Compilar y empaquetar la aplicación
./scripts/02_preparar_entorno.sh

# 3. Configurar servicio systemd
sudo APP_PORT=3000 ./scripts/03_configurar_servicio.sh
```

### Despliegue tras cambios de código

Cada vez que cambies el código fuente o las dependencias (pom.xml), ejecuta:

```bash
./scripts/02_preparar_entorno.sh
```

Este script:
- Compila la aplicación con Maven
- Genera el JAR ejecutable
- Reinicia automáticamente el servicio si está configurado

### Ejecución manual (sin servicio systemd)

```bash
# Compilar y empaquetar
./scripts/02_preparar_entorno.sh

# Ejecutar aplicación
cd springbootwebapp
PORT=3000 java -jar target/springbootwebapp-1.0.0.jar
```

La aplicación estará disponible en `http://localhost:3000`

## Características

- **Página principal** (`/`): Muestra información del cliente (IP, User-Agent, resolución, fecha/hora)
- **Formulario de contacto** (`/contact`): Formulario simple de ejemplo

## Configuración del puerto

Por defecto, la aplicación se ejecuta en el puerto **3000**. Puedes cambiarlo de las siguientes formas:

### Cambiar puerto al configurar el servicio (primera vez)

Al ejecutar el script de configuración del servicio, especifica el puerto con la variable de entorno `APP_PORT`:

```bash
sudo APP_PORT=8080 ./scripts/03_configurar_servicio.sh
```

### Cambiar puerto de un servicio ya configurado

Si el servicio ya está configurado y quieres cambiar el puerto:

```bash
# 1. Reconfigurar el servicio con el nuevo puerto
sudo APP_PORT=8080 ./scripts/03_configurar_servicio.sh

# 2. El servicio se reiniciará automáticamente con el nuevo puerto
```

### Cambiar puerto en ejecución manual

Al ejecutar la aplicación manualmente, especifica el puerto con la variable de entorno `PORT`:

```bash
PORT=8080 java -jar target/springbootwebapp-1.0.0.jar
```

**Nota**: El puerto por defecto es 3000 si no se especifica ninguno.

## Scripts de despliegue

### 01_preparar_servidor.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando se actualiza el servidor
- **Requiere**: sudo
- **Qué hace**: Instala Java (OpenJDK 17) y Maven

### 02_preparar_entorno.sh
- **Cuándo ejecutar**: Cada vez que cambia el código fuente o el pom.xml
- **Requiere**: Ninguno (pero reinicia el servicio si existe)
- **Qué hace**: Compila y empaqueta la aplicación en un JAR ejecutable

### 03_configurar_servicio.sh
- **Cuándo ejecutar**: Solo la primera vez o cuando cambia la configuración del servicio
- **Requiere**: sudo
- **Qué hace**: Crea/configura el servicio systemd para ejecutar el JAR

## Gestión del servicio

```bash
# Ver estado
sudo systemctl status springbootwebapp

# Ver logs
sudo journalctl -u springbootwebapp -f

# Reiniciar
sudo systemctl restart springbootwebapp

# Detener
sudo systemctl stop springbootwebapp

# Iniciar
sudo systemctl start springbootwebapp
```

## Notas sobre compilación

- La primera compilación puede tardar varios minutos ya que Maven descarga todas las dependencias de Spring Boot
- Las compilaciones posteriores serán más rápidas gracias al sistema de caché de Maven
- El JAR compilado se encuentra en `target/springbootwebapp-1.0.0.jar`
- El JAR es autocontenido (fat JAR) e incluye todas las dependencias necesarias

