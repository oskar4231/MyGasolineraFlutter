# Changelog

Todas las versiones y cambios notables de la aplicación MyGasolinera serán documentados en este archivo.

## [Pendiente de Versión] - Último Sprint (Febrero 2026)

### Added (Añadido)
- **Soporte de Entornos Variables:** Implementado el uso de variables de entorno mediante un archivo `.env` para gestionar fácilmente las URLs de APIs (`API_URL_LOCAL`, `API_URL_EMULADOR`, `API_URL_NGROK`, `SWITCH_BACKEND`).
- **Autenticación Mejorada:** El formulario de inicio de sesión ahora permite introducir el nombre de usuario además del correo electrónico.
- **Sincronización Silenciosa:** Se añadió una sincronización en segundo plano de la foto de perfil al realizar el inicio de sesión exitoso. Ahora, las imágenes se descargan del backend y se guardan en el sistema de base de datos cifrada y caché de disco del teléfono, mitigando el problema de la desaparición de la foto tras la desinstalación.
- **Construcción Inteligente de APKs:** Configuración de compilaciones separadas (`split-per-abi`) para proveer compilaciones optimizadas en tamaño para procesadores `arm64-v8a`.

### Changed (Cambiado)
- **Registros (Logs) Condicionales:** El sistema `AppLogger` se ha rediseñado para ocultar la salida de la consola en los entornos de producción (`FLUTTER_ENV=production`), pero manteniendo la persistencia de `.log` en el dispositivo local.
- **Lógica Mock (Testing):** Habilitada carga simulada (JSON) de gasolineras cuando `FLUTTER_ENV=testing` en `api_gasolinera.dart` para evitar sobrecargar servidores en pruebas estáticas.
- **Configuración de Plataforma:** Transición de las variables locales redundantes `esAPK`/`esWeb` a los primitivos oficiales de Flutter `kIsWeb` y `defaultTargetPlatform`.

### Removed (Eliminado)
- Eliminados los scripts en `lib/core/config/importante/` como `switch_web_apk.dart` y `switch_backend.dart`. Quedan declarados obsoletos en favor de la configuración central del archivo `.env`.
