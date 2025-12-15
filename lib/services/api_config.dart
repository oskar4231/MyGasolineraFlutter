/// Configuración centralizada de la URL del backend
///
/// Este archivo contiene la URL base del servidor backend.
/// Cambia solo la URL aquí cuando uses cloudflared o cambies de servidor.
///
/// Ejemplos de URLs:
/// - Desarrollo local: 'http://localhost:3000'
/// - Android Emulator: 'http://10.0.2.2:3000'
/// - Cloudflared: 'https://tu-url-cloudflared.trycloudflare.com'
/// - Producción: 'https://tu-dominio.com'
class ApiConfig {
  /// URL base del backend
  ///
  /// ⚠️ IMPORTANTE: Cambia esta URL cuando uses cloudflared o cambies de servidor
  /// No incluyas la barra final (/)
  static const String baseUrl =
      'https://unsubscribe-doom-onion-submitting.trycloudflare.com';

  /// Obtiene la URL completa para un endpoint
  ///
  /// Ejemplo:
  /// ```dart
  /// ApiConfig.getUrl('/usuarios') // 'https://tu-url.com/usuarios'
  /// ```
  static String getUrl(String endpoint) {
    // Asegurar que el endpoint comience con /
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }
    return '$baseUrl$endpoint';
  }

  /// URL para el endpoint de login
  static String get loginUrl => getUrl('/login');

  /// URL para el endpoint de registro
  static String get registerUrl => getUrl('/register');

  /// URL para el endpoint de recuperación de contraseña
  static String get forgotPasswordUrl => getUrl('/forgot-password');

  /// URL para el endpoint de verificación de token
  static String get verifyTokenUrl => getUrl('/verify-token');

  /// URL para el endpoint de reseteo de contraseña
  static String get resetPasswordUrl => getUrl('/reset-password');

  /// URL para el endpoint de facturas
  static String get facturasUrl => getUrl('/facturas');

  /// URL para el endpoint de coches
  static String get cochesUrl => getUrl('/coches');

  /// URL para el endpoint de usuarios
  static String get usuariosUrl => getUrl('/usuarios');

  /// URL para el endpoint de estadísticas
  static String get estadisticasUrl => getUrl('/estadisticas');

  /// URL para el endpoint de perfil
  static String get perfilUrl => getUrl('/api/perfil');
}
