import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_gasolinera/core/config/api_config.dart';
import 'package:my_gasolinera/core/security/auth_storage.dart';
import 'package:my_gasolinera/core/utils/http_helper.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Servicio principal de autenticación.
/// Credenciales sensibles (token, email, userId) se almacenan cifradas
/// usando [AuthStorage] (flutter_secure_storage / Keychain / Keystore).
class AuthService {
  // Caché en memoria para acceso síncrono tras initialize()
  static String? _token;
  static String? _userEmail;

  // ==================== INICIALIZACIÓN ====================

  /// Restaurar la sesión desde el almacenamiento seguro al arrancar la app.
  static Future<void> initialize() async {
    _token = await AuthStorage.getToken();
    _userEmail = await AuthStorage.getEmail();
    if (_token != null) {
      AppLogger.info('Sesión restaurada para: $_userEmail', tag: 'AuthService');
    }
  }

  // ==================== GUARDAR / LIMPIAR ====================

  /// Guarda el token y el email de forma cifrada.
  static Future<void> saveToken(String token, String email,
      {String? userId}) async {
    _token = token;
    _userEmail = email;

    await AuthStorage.saveCredentials(
      token: token,
      email: email,
      userId: userId ?? '',
    );

    AppLogger.debug('Token guardado de forma cifrada para: $email',
        tag: 'AuthService');
  }

  /// Cierra sesión: borra la caché en memoria y el almacenamiento seguro.
  static Future<void> logout() async {
    _token = null;
    _userEmail = null;
    await AuthStorage.clearCredentials();
    AppLogger.info('Sesión cerrada', tag: 'AuthService');
  }

  // ==================== GETTERS ====================

  /// Token en memoria (disponible tras [initialize] o [saveToken]).
  static String? getToken() => _token;

  /// Email en memoria (disponible tras [initialize] o [saveToken]).
  static String? getUserEmail() => _userEmail;

  /// Devuelve true si hay sesión activa en memoria.
  static bool isLoggedIn() => _token != null && _token!.isNotEmpty;

  // ==================== AUTENTICACIÓN ====================

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: HttpHelper.mergeHeaders(ApiConfig.headers),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      AppLogger.debug('Respuesta login: $data', tag: 'AuthService');

      if (response.statusCode == 200) {
        return {'status': 'success', 'data': data};
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Error desconocido'
        };
      }
    } catch (e) {
      AppLogger.error('Error en login', tag: 'AuthService', error: e);
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }

  // ==================== REGISTRO ====================

  static Future<Map<String, dynamic>> register(
      String nombre, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        headers: HttpHelper.mergeHeaders(ApiConfig.headers),
        body: jsonEncode({
          'nombre': nombre,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      AppLogger.debug('Respuesta register: $data', tag: 'AuthService');

      if (response.statusCode == 201) {
        return {'status': 'success', 'message': data['message']};
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Error desconocido'
        };
      }
    } catch (e) {
      AppLogger.error('Error en register', tag: 'AuthService', error: e);
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }

  // ==================== RECUPERACIÓN DE CONTRASEÑA ====================

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.forgotPasswordUrl),
        headers: HttpHelper.mergeHeaders(ApiConfig.headers),
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      AppLogger.debug('Respuesta forgot-password: $data', tag: 'AuthService');
      return data;
    } catch (e) {
      AppLogger.error('Error en forgotPassword', tag: 'AuthService', error: e);
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyTokenUrl),
        headers: HttpHelper.mergeHeaders(ApiConfig.headers),
        body: jsonEncode({'token': token}),
      );

      final data = jsonDecode(response.body);
      AppLogger.debug('Respuesta verify-token: $data', tag: 'AuthService');
      return data;
    } catch (e) {
      AppLogger.error('Error en verifyToken', tag: 'AuthService', error: e);
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.resetPasswordUrl),
        headers: HttpHelper.mergeHeaders(ApiConfig.headers),
        body: jsonEncode({'token': token, 'newPassword': newPassword}),
      );

      final data = jsonDecode(response.body);
      AppLogger.debug('Respuesta reset-password: $data', tag: 'AuthService');
      return data;
    } catch (e) {
      AppLogger.error('Error en resetPassword', tag: 'AuthService', error: e);
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }
}
