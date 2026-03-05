# Changelog

Todas las versiones y cambios notables de la aplicación MyGasolinera serán documentados en este archivo.

## [Pendiente de Versión] - Sprint Marzo 2026

### Added (Añadido)
- **Migración a Isar Database:** Sustitución completa del sistema de base de datos local de `drift` (SQLite) por **Isar**, una base de datos NoSQL de alto rendimiento para Flutter. Nuevos modelos: `car_local`, `gasolinera_local`, `invoice_local`, `user_local`.
- **Sync Manager:** Nuevo módulo `sync_manager` (con implementaciones nativas y web separadas) para gestionar la sincronización de datos entre servidor y base de datos local.
- **Auth Storage Seguro:** Nuevo módulo `auth_storage.dart` en `lib/core/security/` para el almacenamiento seguro y encriptado de credenciales de autenticación.
- **Crash Handler:** Nuevo módulo `crash_handler.dart` para capturar, manejar y registrar errores fatales de la aplicación de forma centralizada.
- **Cache Service por Plataforma:** El servicio de caché de gasolineras se ha dividido en implementaciones separadas (`gasolinera_cache_service_native.dart` y `gasolinera_cache_service_web.dart`) para mayor rendimiento.

### Changed (Cambiado)
- **Optimizaciones CPU y RAM:** Múltiples mejoras de rendimiento en el consumo de memoria y procesador a lo largo de varios módulos de la aplicación.
- **Fix bug detalles de gasolinera:** Corregido un error en la vista de detalles de gasolinera.
- **CleanCode:** Refactorizaciones y mejoras de calidad de código en pruebas, dependencias y módulos de la aplicación.
- **Dependencias actualizadas:** `pubspec.yaml` y `pubspec.lock` actualizados para soportar Isar y los nuevos módulos.

### Removed (Eliminado)
- Eliminada la capa de base de datos `bbdd_intermedia/` basada en `drift`, incluyendo `base_datos_apk.dart`, `base_datos_web.dart` y todas sus tablas asociadas. Reemplazada por la nueva arquitectura Isar.

---

## [Pendiente de Versión] - Sprint Febrero 2026

### Added (Añadido)
- **Visualización en Lista:** Añadida la visualización del modo lista de las gasolineras, permitiendo una rápida consulta y navegación.
- **Traducciones y Detalles:** Ampliación del soporte de internacionalización con nuevas palabras y mayores detalles para la gestión de coches.
- **Soporte de Entornos Variables:** Implementado el uso de variables de entorno mediante un archivo `.env` para gestionar fácilmente las URLs de APIs.
- **Autenticación Mejorada:** El formulario de inicio de sesión ahora permite introducir el nombre de usuario además del correo electrónico.
- **Sincronización Silenciosa:** Sincronización en segundo plano de la foto de perfil al iniciar sesión, guardando en local para evitar pérdida tras desinstalación.
- **Construcción Inteligente de APKs:** Configuración de compilaciones separadas (`split-per-abi`) para proveer APKs optimizadas (`arm64-v8a`).

### Changed (Cambiado)
- **Mejoras UI y Diseño:** Se actualizaron los iconos de la barra superior, se aplicó un estilo oscuro al bloque de filtros y otras mejoras visuales en la app.
- **Registros (Logs) Condicionales:** El sistema `AppLogger` se rediseñó para ocultar la salida de consola en produccion (`FLUTTER_ENV=production`).
- **Lógica Mock (Testing):** Habilitada carga simulada (JSON) de gasolineras al usar `FLUTTER_ENV=testing` para evitar recargar servidores.
- **Configuración de Plataforma:** Transición de variables locales obsoletas a los primitivos oficiales de Flutter `kIsWeb` y `defaultTargetPlatform`.

### Removed (Eliminado)
- Eliminados los scripts en `lib/core/config/importante/` como `switch_web_apk.dart` y `switch_backend.dart`. Quedan declarados obsoletos en favor de la configuración central del archivo `.env`.
