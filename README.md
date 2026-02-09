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

**MyGasolinera** es una aplicación móvil desarrollada en Flutter que permite a los usuarios localizar gasolineras cercanas, gestionar sus vehículos, registrar repostajes y administrar facturas de combustible. La aplicación integra mapas interactivos, geolocalización y un sistema completo de autenticación de usuarios.

## 📜 Changelog (v1.7.0 - Feb 2026)

Cambios realizados desde la versión anterior (1.6.0):

### 🎨 Frontend & UI
- **Refactorización de Arquitectura**: Reorganización integral de la estructura de carpetas (`lib/Implementaciones`, `lib/core`) para mejorar la mantenibilidad y seguir principios Clean.
- **Mejoras en el Mapa**: Implementación de la lógica para obtener provincias directamente desde la API oficial de gasolineras.
- **Gestión de Favoritos**: Nueva funcionalidad de persistencia local para guardar y gestionar gasolineras favoritas.
- **Optimización Visual**: Resolución masiva de advertencias de lint y limpieza de código en múltiples pantallas y componentes.

### ⚙️ Core & Sistema
- **Actualización de Dependencias**: Paquetes principales (`google_maps_flutter`, `drift`, `geolocator`, `http`) actualizados a sus versiones más recientes (Diciembre 2024).
- **Control de Entorno**: Implementación de `switch_web_apk.dart` y `switch_backend.dart` para facilitar la transición entre desarrollo local, web y móvil.
- **Base de Datos Intermedia**: Capa de persistencia mejorada para manejar IndexedDB (Web) y SQLite (Android/Windows) de forma transparente para el desarrollador.
- **Pruebas y Calidad**: Añadidos nuevos tests unitarios y de integración (ej. `favoritos_test.dart`) para asegurar la estabilidad del proyecto.

## ✨ Características Principales

- 🔐 **Sistema de Autenticación**
  - Registro de nuevos usuarios
  - Inicio de sesión seguro
  - Recuperación de contraseña
  
- 🗺️ **Localización de Gasolineras**
  - Visualización en mapa interactivo (Google Maps)
  - Búsqueda de gasolineras cercanas mediante geolocalización
  - Vista de lista con información detallada
  
- 🚙 **Gestión de Vehículos**
  - Registro y administración de coches personales
  - Historial de repostajes por vehículo
  
- 🧾 **Gestión de Facturas**
  - Creación de facturas de combustible
  - Visualización de detalles de facturas
  - Historial completo de gastos

- ⚙️ **Configuración Personalizada**
  - Ajustes de cuenta de usuario
  - Preferencias de la aplicación

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter** 3.9.2 - Framework multiplataforma
- **Dart** 3.9.2 - Lenguaje de programación
- **Google Maps Flutter** - Integración de mapas
- **Geolocator** - Servicios de geolocalización
- **Image Picker** - Selección de imágenes
- **Shared Preferences** - Almacenamiento local
- **HTTP** - Comunicación con el backend

### Backend (Repositorio Separado)
- **Node.js** - Servidor backend
- **Express.js** - Framework web
- **MariaDB** - Base de datos relacional
- Puerto: `http://localhost:5001`
- Repositorio: Separado del frontend

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
├── Inicio/
│   ├── inicio.dart                    # Pantalla inicial
│   ├── login/
│   │   ├── login.dart                 # Pantalla de inicio de sesión
│   │   ├── recuperar.dart             # Recuperación de contraseña
│   │   └── nueva_password.dart        # Establecer nueva contraseña
│   ├── crear_cuenta/
│   │   └── crear.dart                 # Registro de nuevos usuarios
│   └── facturas/
│       ├── FacturasScreen.dart        # Lista de facturas
│       ├── CrearFacturaScreen.dart    # Crear nueva factura
│       └── DetalleFacturaScreen.dart  # Detalle de factura
├── principal/
│   ├── layouthome.dart                # Layout principal con navegación
│   ├── homepage.dart                  # Página de inicio
│   ├── mapa.dart                      # Vista de mapa
│   ├── lista.dart                     # Vista de lista de gasolineras
│   └── gasolineras/
│       ├── gasolinera.dart            # Modelo de gasolinera
│       └── api_gasolinera.dart        # Servicio API de gasolineras
├── coches/
│   └── coches.dart                    # Gestión de vehículos
├── ajustes/
│   └── ajustes.dart                   # Configuración de la app
└── services/
    └── auth_service.dart              # Servicio de autenticación
```

## 🚀 Instalación y Configuración

### Requisitos Previos

- Flutter SDK 3.9.2 o superior
- Dart SDK 3.9.2 o superior
- Android Studio / VS Code con extensiones de Flutter
- Node.js y npm (para el backend - repositorio separado)
- MariaDB instalado y configurado

### Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/oskar4231/MyGasolineraFlutter.git
   cd MyGasolineraFlutter
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar el backend**
   
   El backend es un proyecto Node.js separado. Consulta el archivo [INSTRUCCIONES_DESARROLLO.md](INSTRUCCIONES_DESARROLLO.md) para más información sobre cómo configurar y ejecutar el servidor backend.

4. **Ejecutar la aplicación**
   
   Desde VS Code:
   - Presiona `F5` para iniciar el debugger
   
   Desde la terminal:
   ```bash
   flutter run -d chrome --web-port=5000
   ```

## 🔧 Configuración de Puertos

| Servicio       | Puerto | URL                      |
|----------------|--------|--------------------------|
| Flutter Web    | 5000   | http://localhost:5000    |
| Backend Java   | 5001   | http://localhost:5001    |
| MariaDB        | 3306   | localhost:3306           |

## 📡 API Endpoints

El backend Node.js (repositorio separado) proporciona los siguientes endpoints:

- `POST /register` - Registro de nuevos usuarios
- `POST /login` - Autenticación de usuarios
- `GET /gasolineras` - Obtener lista de gasolineras
- `POST /facturas` - Crear nueva factura
- `GET /facturas/:userId` - Obtener facturas del usuario

> **Nota:** El backend se encuentra en un repositorio separado. Asegúrate de tenerlo ejecutándose en `http://localhost:5001` antes de usar la aplicación.

## 🎯 Uso de la Aplicación

1. **Registro/Inicio de Sesión**
   - Crea una cuenta nueva o inicia sesión con credenciales existentes

2. **Explorar Gasolineras**
   - Visualiza gasolineras en el mapa interactivo
   - Cambia a vista de lista para más detalles
   - Usa la geolocalización para encontrar las más cercanas

3. **Gestionar Vehículos**
   - Añade tus vehículos desde la sección de coches
   - Registra repostajes y consumo

4. **Administrar Facturas**
   - Crea facturas de tus repostajes
   - Consulta el historial completo
   - Visualiza detalles de cada factura

## 👥 Desarrollo

### Flujo de Trabajo

Para información detallada sobre el flujo de desarrollo, separación frontend/backend y solución de problemas, consulta [INSTRUCCIONES_DESARROLLO.md](INSTRUCCIONES_DESARROLLO.md).

### Ejecutar en Modo Debug

```bash
flutter run -d chrome --web-port=5000 --debug
```

### Compilar para Producción

```bash
flutter build web
flutter build apk
flutter build ios
```

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📄 Licencia

Este proyecto es privado y no está publicado en pub.dev.

## 🤝 Contribuciones

Este es un proyecto privado. Para contribuir, contacta con el equipo de desarrollo.

## 📞 Soporte

Para problemas o preguntas, consulta la sección de **Solución de problemas** en [INSTRUCCIONES_DESARROLLO.md](INSTRUCCIONES_DESARROLLO.md).

---

<p align="center">
  Desarrollado con ❤️ usando Flutter
</p>
