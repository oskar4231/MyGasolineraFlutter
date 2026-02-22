# MyGasolinera 🚗⛽

<p align="center">
  <img src="Documentacion/banner.png" alt="MyGasolinera" width="1000">
</p>

<p align="center">
  <strong>Aplicación móvil multiplataforma para la gestión y localización de gasolineras</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/License-Private-red" alt="License">
</p>

---

## 📋 Descripción

**MyGasolinera** es una aplicación multiplataforma (Web y APK Nativo) diseñada para que los conductores puedan llevar el control de sus gastos, localizar gasolineras, analizar los precios del combustible y revisar la eficiencia de su vehículo con completos gráficos mensuales y semanales.

## 📜 Changelog (Último Sprint - Febrero 2026)

En el último flujo de trabajo el equipo se ha centrado en mejorar el rendimiento, la experiencia del usuario local y la configuración del entorno para hacerla más agnóstica a la máquina.

### ➕ Añadido
- **Soporte de Entornos Variables:** Implementado el uso de variables de entorno mediante un archivo `.env` para gestionar fácilmente las URLs de APIs (`API_URL_LOCAL`, `API_URL_EMULADOR`, `API_URL_NGROK`, `SWITCH_BACKEND`).
- **Autenticación Mejorada:** El formulario de inicio de sesión ahora permite introducir el nombre de usuario además del correo electrónico.
- **Sincronización Silenciosa:** Se añadió una sincronización en segundo plano de la foto de perfil al realizar el inicio de sesión exitoso. Ahora, las imágenes se descargan del backend y se guardan en el sistema de base de datos cifrada y caché de disco del teléfono, mitigando el problema de la desaparición de la foto tras la desinstalación.
- **Construcción Inteligente de APKs:** Configuración de compilaciones separadas (`split-per-abi`) para proveer compilaciones optimizadas en tamaño para procesadores `arm64-v8a`.

### 🔄 Cambiado
- **Registros (Logs) Condicionales:** El sistema `AppLogger` se ha rediseñado para ocultar la salida de la consola en los entornos de producción (`FLUTTER_ENV=production`), pero manteniendo la persistencia de `.log` en el dispositivo local.
- **Lógica Mock (Testing):** Habilitada carga simulada (JSON) de gasolineras cuando `FLUTTER_ENV=testing` en `api_gasolinera.dart` para evitar sobrecargar servidores en pruebas estáticas.
- **Configuración de Plataforma:** Transición de las variables locales redundantes `esAPK`/`esWeb` a los primitivos oficiales de Flutter `kIsWeb` y `defaultTargetPlatform`.

### ❌ Eliminado
- Eliminados los scripts en `lib/core/config/importante/` como `switch_web_apk.dart` y `switch_backend.dart`. Quedan declarados obsoletos en favor de la configuración central del archivo `.env`.

> *Puedes consultar todas las adiciones en el archivo [CHANGELOG.md](CHANGELOG.md).*

## ✨ Características Principales

- 🔐 **Sistema de Autenticación**
  - Registro e Inicio de sesión (Email/Usuario).
- 🗺️ **Localización y Búsqueda Dinámica**
  - Visualización y filtrado de gasolineras, surtidores y radios de apertura interactivo en Google Maps.
  - Geolocalización en tiempo real.
- 🚙 **Gestión de Vehículos**
  - Administración de coches, eficiencia y consumos.
- 🧾 **Sincronización Local Constante**
  - Soporte trans-instalaciones para datos vitales apoyado mediante SQLite (`drift`) de forma local.

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter & Dart** - Framework multiplataforma
- **Google Maps Flutter** - Integración interactiva cartográfica
- **Drift (SQLite) & IndexedDB** - Bases de Datos del cliente
- **Geolocator** - Servicios de localización
- **HTTP & dotenv** - Conexiones API y variables de entorno.

### Backend (Repositorio Separado)
- **Node.js & Express.js**
- **MariaDB**
- Puerto: `http://localhost:5001` (Por Defecto)

## 🚀 Instalación y Compilación

### Dependencias
```bash
flutter pub get
```

### Ejecutar Localmente
Asegúrate de contar con el archivo `.env` creado en la raíz.
```bash
flutter run
```

### Generar APKs (Android)
Para generar un instalador optimizado dividiendo dependencias y binarios por arquitectura:
```bash
flutter build apk --split-per-abi
```
Las APK resultantes para el dispositivo específico (como `arm64-v8a`) ocuparán un tamaño drásticamente inferior que unas *Fat APKs* normales.

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web

---

<p align="center">
  📓 <i>Para documentación técnica completa revisa el directorio <a href="Documentacion/">/Documentacion</a></i><br>
  Desarrollado con ❤️ usando Flutter
</p>
