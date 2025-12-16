# MyGasolinera 🚗⛽

<p align="center">
  <img src="banner.png" alt="MyGasolinera" width="1000">
</p>

<p align="center">
  <strong>Aplicación móvil multiplataforma para la gestión y localización de gasolineras</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue" alt="Platform">
  <img src="https://img.shields.io/badge/License-Private-red" alt="License">
</p>

---

## 📋 Descripción

**MyGasolinera** es una aplicación móvil desarrollada en Flutter que permite a los usuarios localizar gasolineras cercanas, gestionar sus vehículos, registrar repostajes, administrar facturas de combustible y personalizar la accesibilidad de la app.

## ✨ Características Principales

- 🔐 **Sistema de Autenticación**
  - Registro, inicio de sesión y recuperación de contraseña.

- 🗺️ **Localización y Mapas**
  - Mapa interactivo con marcadores personalizados.
  - Geolocalización en tiempo real.
  - Filtrado de gasolineras por tipo de combustible y precio.
  - Indicadores visuales de gasolineras favoritas.

- ♿ **Accesibilidad Avanzada**
  - Ajuste de tamaño de fuente (incluyendo slider personalizado).
  - Modo de alto contraste.
  - Soporte para lectores de pantalla.
  - Persistencia de configuración en backend.

- 🚙 **Gestión de Vehículos**
  - Registro de coches y control de historial de repostajes.

- 🧾 **Facturación**
  - Generación y consulta de facturas de combustible.

## 🛠️ Herramientas y Scripts

El proyecto incluye scripts para facilitar el mantenimiento:

- `limpiar_proyecto.bat`: **Script de limpieza**. Ejecútalo para eliminar archivos temporales (`build`, `.dart_tool`, `android/.gradle`) y solucionar problemas de caché.

## 🚀 Instalación y Despliegue

### Requisitos
- Flutter SDK (versión estable reciente)
- Android Studio / VS Code

### Ejecución en Desarrollo
```bash
# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run
```

### 📦 Generar APK (Android)
Para generar el archivo de instalación `.apk` para dispositivos Android:

```bash
flutter build apk --release
```

El archivo generado estará en: `build/app/outputs/flutter-apk/app-release.apk`

### Compilación Web
```bash
flutter build web
```

## 🔧 Backend
La aplicación se conecta a un backend externo (Node.js/Express + MariaDB).
Asegúrate de configurar correctamente los endpoints en `lib/services/api_config.dart` (o similar) para apuntar a tu servidor de despliegue (actualmente usando túneles Cloudflare o servidor local).

## 📄 Licencia
Este proyecto es privado.
