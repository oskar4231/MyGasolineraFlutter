import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:my_gasolinera/core/config/importante/switchBackend.dart';

///
/// Este archivo contiene la URL base del servidor backend.
/// Cambia solo la URL aquí cuando uses cloudflared o cambies de servidor.
///
/// Ejemplos de URLs:
/// - Desarrollo local: 'http://localhost:3000'
/// - Android Emulator: 'http://10.0.2.2:3000'
/// - Ngrok: 'https://rectricial-dewayne-collusive.ngrok-free.dev'
/// - Producción: 'https://tu-dominio.com'
class ApiConfig {
  /// URL base del backend
  ///
  /// Esta URL se actualiza dinámicamente al iniciar la app usando ConfigService
  /// No incluyas la barra final (/)
  static const String _localUrl = 'http://localhost:3000';
  static const String _androidEmulatorUrl = 'http://10.0.2.2:3000';
  static const String _ngrokUrl =
      'https://rectricial-dewayne-collusive.ngrok-free.dev';

  // Variable de respaldo por si se actualiza dinámicamente
  static String? _dynamicUrl;

  /// URL base del backend
  ///
  /// Esta URL se determina por el switch en lib/important/switchBackend.dart
  static String get baseUrl {
    // Si se ha establecido una URL dinámica (ej. al inicio), usarla
    if (_dynamicUrl != null) return _dynamicUrl!;

    if (switchBackend == 1) {
      return _ngrokUrl;
    }
    // Si es localhost (0)
    if (!kIsWeb && Platform.isAndroid) {
      return _androidEmulatorUrl;
    }
    return _localUrl;
  }

  /// Actualiza la URL base dinámicamente
  static void setBaseUrl(String newUrl) {
    if (newUrl.endsWith('/')) {
      _dynamicUrl = newUrl.substring(0, newUrl.length - 1);
    } else {
      _dynamicUrl = newUrl;
    }
    // ignore: avoid_print
    print('API Config: URL Base actualizada a: $_dynamicUrl');
  }

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
  static String get perfilUrl => getUrl('/perfil');

  /// URL para el endpoint de accesibilidad
  static String get accesibilidadUrl => getUrl('/accesibilidad');

  /// Headers base para todas las peticiones
  ///
  /// Incluye el header para saltar el aviso de ngrok
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };
}
