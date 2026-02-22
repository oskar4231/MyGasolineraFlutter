# MyGasolinera

## ¿Qué es MyGasolinera?
MyGasolinera es una aplicación multiplataforma (Web y APK Nativo) diseñada para que los conductores puedan llevar el control de sus gastos, localizar gasolineras, analizar los precios del combustible y revisar la eficiencia de su vehículo con completos gráficos mensuales y semanales.

## Novedades del Último Sprint (Febrero 2026)
En el último flujo de trabajo el equipo se ha centrado en mejorar el rendimiento, la experiencia del usuario local y la configuración del entorno para hacerla más agnóstica a la máquina.

### Configuración con variables de Entorno (.env)
La aplicación hace uso de un archivo `.env` para gestionar los modos de plataforma y los enlaces al backend. (Asegúrate de tener un archivo `.env` en la raíz basado en tu configuración).

```env
API_URL_LOCAL=http://localhost:3000
API_URL_EMULADOR=http://10.0.2.2:3000
API_URL_NGROK=https://xxxx-xxx.ngrok-free.dev

# 0 Local, 1 Ngrok
SWITCH_BACKEND=1

# testing o production
FLUTTER_ENV=development
```

### Características
- **Multiplataforma inteligente:** Detecta automáticamente usando primitivos de Flutter si se está compilando en un dispositivo nativo o aplicación web, usando en la respectiva SQLite (`drift`) o `IndexedDB` para el caché de imágenes y almacenamiento de marcadores.
- **Sincronización Local Constante:** Soporte persistente trans-instalaciones para la caché de imágenes.
- **Búsqueda Dinámica:** Visualiza y filtra gasolina, tipos de surtidores, radios de apertura y precios con una interfaz limpia.
- **Registros y Logs:** Logging modular que registra toda la actividad al vuelo en el terminal si la app no se compila bajo el flag de `production`.

## Instrucciones y Compilación
### Dependencias
```bash
flutter pub get
```

### Ejecutar Localmente
```bash
flutter run
```

### Generar APKs (Android)
Para generar un instalador Android optimizado dividiendo dependencias y binarios por arquitectura:
```bash
flutter build apk --split-per-abi
```
Las APK resultantes (como el paquete `arm64-v8a`) ocuparán un tamaño drásticamente inferior que unas *Fat APKs* normales.

## Registro de Cambios (Changelog)

### Último Sprint (Febrero 2026)

#### Añadido
- **Soporte de Entornos Variables:** Implementado el uso de variables de entorno mediante un archivo `.env` para gestionar fácilmente las URLs de APIs (`API_URL_LOCAL`, `API_URL_EMULADOR`, `API_URL_NGROK`, `SWITCH_BACKEND`).
- **Autenticación Mejorada:** El formulario de inicio de sesión ahora permite introducir el nombre de usuario además del correo electrónico.
- **Sincronización Silenciosa:** Se añadió una sincronización en segundo plano de la foto de perfil al realizar el inicio de sesión exitoso. Ahora, las imágenes se descargan del backend y se guardan en el sistema de base de datos cifrada y caché de disco del teléfono, mitigando el problema de la desaparición de la foto tras la desinstalación.
- **Construcción Inteligente de APKs:** Configuración de compilaciones separadas (`split-per-abi`) para proveer compilaciones optimizadas en tamaño para procesadores `arm64-v8a`.

#### Cambiado
- **Registros (Logs) Condicionales:** El sistema `AppLogger` se ha rediseñado para ocultar la salida de la consola en los entornos de producción (`FLUTTER_ENV=production`), pero manteniendo la persistencia de `.log` en el dispositivo local.
- **Lógica Mock (Testing):** Habilitada carga simulada (JSON) de gasolineras cuando `FLUTTER_ENV=testing` en `api_gasolinera.dart` para evitar sobrecargar servidores en pruebas estáticas.
- **Configuración de Plataforma:** Transición de las variables locales redundantes `esAPK`/`esWeb` a los primitivos oficiales de Flutter `kIsWeb` y `defaultTargetPlatform`.

#### Eliminado
- Eliminados los scripts en `lib/core/config/importante/` como `switch_web_apk.dart` y `switch_backend.dart`. Quedan declarados obsoletos en favor de la configuración central del archivo `.env`.
