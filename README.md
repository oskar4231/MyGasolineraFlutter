# Backend MyGasolinera

Este es el backend de la aplicación MyGasolinera, desarrollado en Java con servidor HTTP y conexión a MariaDB.

## ⚙️ Configuración del Proyecto (IMPORTANTE)

### Para VS Code

1. **Instala la extensión de Java**: [Extension Pack for Java](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack)

2. **Abre el proyecto**: El archivo `.vscode/settings.json` ya está configurado con las librerías necesarias.

3. **Recarga la ventana**: Presiona `Ctrl+Shift+P` y ejecuta `Java: Clean Java Language Server Workspace` si sigues viendo errores.

### Para Eclipse/IntelliJ

Los archivos `.classpath` y `.project` ya están configurados. Simplemente importa el proyecto como "Existing Project".

### Librerías incluidas

Las siguientes librerías ya están en la carpeta `basededatosjava/`:
- ✅ `mariadb-java-client-3.5.6.jar` - Driver de MariaDB
- ✅ `json-20250517.jar` - Librería JSON de org.json

**No necesitas descargar nada adicional.** Todo está incluido en el repositorio.

### ⚠️ ¿Problemas con las importaciones?

Si ves el error "The import org.json cannot be resolved", consulta [TROUBLESHOOTING.md](TROUBLESHOOTING.md) para soluciones detalladas.

## 📁 Estructura

```
BackendBBDD/
└── basededatosjava/
    ├── BBDD.java                           # Servidor HTTP principal
    ├── BBDD.class                          # Clase compilada
    ├── mariadb-java-client-3.5.6.jar      # Driver MariaDB
    └── json-20250517.jar                   # Librería JSON
```

## 🚀 Inicio Rápido

### Primera vez (Configuración inicial)

1. **Clona el repositorio**
   ```bash
   git clone <URL_DEL_REPO>
   cd BackendBBDD
   ```

2. **(Opcional) Verifica tu entorno** (Windows)
   ```bash
   check-setup.bat
   ```

   Esto verificará que tengas Java instalado y todas las librerías necesarias.

3. **Ejecuta el script de configuración**

   **Windows:**
   ```bash
   setup.bat
   ```

   **Linux/Mac:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   Esto compilará el proyecto automáticamente.

4. **Inicia el servidor**

   **Windows:**
   ```bash
   start-server.bat
   ```

   **Linux/Mac:**
   ```bash
   cd basededatosjava
   java -cp ".:mariadb-java-client-3.5.6.jar:json-20250517.jar" BBDD
   ```

### Ejecución normal

Simplemente ejecuta:
```bash
start-server.bat
```

El servidor se iniciará en: `http://localhost:5001`

### Compilación manual (opcional)

Si prefieres compilar manualmente:

```bash
cd basededatosjava
javac -cp ".;mariadb-java-client-3.5.6.jar;json-20250517.jar" BBDD.java
java -cp ".;mariadb-java-client-3.5.6.jar;json-20250517.jar" BBDD
```

## 📡 Endpoints disponibles

### POST /register
Registra un nuevo usuario en la base de datos.

**Request:**
```json
{
  "email": "usuario@example.com",
  "password": "contraseña123"
}
```

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Usuario creado correctamente"
}
```

**Response (409 Conflict):**
```json
{
  "status": "error",
  "message": "El email ya está registrado"
}
```

### POST /login
Inicia sesión con email y contraseña.

**Request:**
```json
{
  "email": "usuario@example.com",
  "password": "contraseña123"
}
```

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Login exitoso",
  "email": "usuario@example.com"
}
```

**Response (401 Unauthorized):**
```json
{
  "status": "error",
  "message": "Email o contraseña incorrectos"
}
```

## 🗄️ Configuración de Base de Datos

### Requisitos
- MariaDB instalado y corriendo en `localhost:3306`
- Base de datos: `mygasolinera`
- Usuario: `root`
- Contraseña: (vacía)

### Estructura de la tabla `usuarios`

```sql
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🔧 Configuración

Para cambiar la configuración de la base de datos, edita las siguientes líneas en `BBDD.java`:

```java
miConexion = DriverManager.getConnection(
    "jdbc:mariadb://127.0.0.1:3306/mygasolinera",
    "root",  // Usuario
    ""       // Contraseña
);
```

## 🌐 CORS

El servidor tiene CORS habilitado para permitir peticiones desde cualquier origen (`Access-Control-Allow-Origin: *`).

## 📝 Notas

- Las contraseñas se guardan en **texto plano** por ahora (⚠️ NO recomendado para producción)
- El servidor escucha en todas las interfaces (`0.0.0.0:5001`)
- Los logs se muestran en la consola

## 🔗 Conexión con Flutter

El frontend Flutter se conecta a este backend en:
- **Registro**: `http://localhost:5001/register`
- **Login**: `http://localhost:5001/login`

Asegúrate de que el servidor esté corriendo antes de usar la aplicación Flutter.

