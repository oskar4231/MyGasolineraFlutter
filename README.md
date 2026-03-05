# MyGasolinera 🚗⛽

<p align="center">
  <img src="banner.png" alt="MyGasolinera" width="1000">
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

## 📋 Changelog (Sprint Marzo 2026)

El sprint de marzo ha supuesto una gran refactorización de la arquitectura de datos local, con una migración completa a Isar y la incorporación de nuevos módulos de seguridad, sincronización y robustez.

### ➕ Añadido
- **Migración a Isar Database:** La base de datos local ha migrado de `drift` (SQLite) a **Isar**, una soledad NoSQL de alto rendimiento. Nuevos modelos: `car_local`, `gasolinera_local`, `invoice_local`, `user_local`.
- **Sync Manager:** Módulo de sincronización entre servidor y base de datos local, con implementaciones separadas para nativo y web.
- **Auth Storage Seguro:** `lib/core/security/auth_storage.dart` para almacenamiento seguro y cifrado de tokens y credenciales.
- **Crash Handler:** `lib/core/utils/crash_handler.dart` para captura y gestión centralizada de errores fatales.
- **Cache Service por Plataforma:** El servicio de caché de gasolineras se split en `_native` y `_web` para mayor eficiencia en cada plataforma.

### 🔄 Cambiado
- **Optimizaciones CPU y RAM:** Mejoras de rendimiento en múltiples módulos. (`OutOfMemoryError` mitigado, refresco inteligente).
- **Fix bug detalles de gasolinera:** Corregido un error al visualizar el detalle de una gasolinera específica.
- **Dependencias actualizadas:** `pubspec.yaml` modernizado con Isar y nuevas librerías de soporte.

### ❌ Eliminado
- Eliminada la capa `bbdd_intermedia/` basada en `drift`, incluyendo todos sus modelos de tabla y archivos generados. Sustituida por la arquitectura Isar.

> *Registro completo de versiones anteriores en [CHANGELOG.md](CHANGELOG.md).*


## ✨ Características Principales

- 🔐 **Sistema de Autenticación**
  - Registro e Inicio de sesión (Email/Usuario).
- 🗺️ **Localización y Búsqueda Dinámica**
  - Visualización y filtrado de gasolineras en **modo mapa** y **modo lista**.
  - Surtidores y radios de apertura interactivo en Google Maps.
  - Geolocalización en tiempo real.
- 🚙 **Gestión de Vehículos**
  - Administración de coches, eficiencia y consumos.
- 🯧 **Sincronización Local Constante**
  - Base de datos local de alto rendimiento mediante **Isar** (reemplaza a Drift/SQLite).
  - Soporte trans-instalaciones con `SyncManager` nativo y web.
- 🛡️ **Seguridad y Robustez**
  - Almacenamiento seguro de credenciales con `AuthStorage`.
  - Captura centralizada de errores con `CrashHandler`.

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter & Dart** - Framework multiplataforma
- **Google Maps Flutter** - Integración interactiva cartográfica
- **Isar** - Base de datos local de alto rendimiento (nativa y web)
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
