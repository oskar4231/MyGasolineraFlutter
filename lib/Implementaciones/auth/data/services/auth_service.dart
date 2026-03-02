import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/core/config/api_config.dart';
import 'package:my_gasolinera/core/utils/http_helper.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

// Servicio para gestionar el token de autenticación y recuperación de contraseña
class AuthService {
  static String? _token;
  static String? _userEmail;

  // Inicializar el servicio recuperando datos de SharedPreferences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('authToken');
    _userEmail = prefs.getString('userEmail');
    if (_token != null) {
      AppLogger.info('Sesión restaurada para: $_userEmail', tag: 'AuthService');
    }
  }

  // Guardar el token y email del usuario
  static Future<void> saveToken(String token, String email) async {
    _token = token;
    _userEmail = email;

    // Guardar también en SharedPreferences para persistencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    await prefs.setString('userEmail', email);

    AppLogger.debug('Token guardado para: $email', tag: 'AuthService');
  }

  // Obtener el token
  static String? getToken() {
    return _token;
  }

  // Obtener el email del usuario
  static String? getUserEmail() {
    return _userEmail;
  }

  // Verificar si hay una sesión activa
  static bool isLoggedIn() {
    return _token != null && _token!.isNotEmpty;
  }

  // Cerrar sesión
  static Future<void> logout() async {
    _token = null;
    _userEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userEmail');
    AppLogger.info('Sesión cerrada', tag: 'AuthService');
  }

  // Validar si el token guardado sigue siendo válido contra el backend
  // Devuelve true si la sesión es válida, false si ha expirado o hay error
  static Future<bool> validateSession() async {
    if (_token == null || _token!.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.perfilUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al validar sesión'),
      );

      if (response.statusCode == 200) {
        AppLogger.info('Sesión válida para: $_userEmail', tag: 'AuthService');
        return true;
      } else {
        // Token expirado o inválido (401, 403, etc.)
        AppLogger.warning(
          'Sesión inválida (${response.statusCode}), limpiando token',
          tag: 'AuthService',
        );
        await logout();
        return false;
      }
    } catch (e) {
      // Error de red: asumir sesión válida para no bloquear al usuario offline
      AppLogger.warning(
        'No se pudo validar la sesión (sin conexión), asumiendo válida',
        tag: 'AuthService',
      );
      return _token != null && _token!.isNotEmpty;
    }
  }

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

  // ==================== RECUPERACIÓN DE CONTRASEÑA ====================

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

  // Solicitar recuperación de contraseña
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

  // Verificar token
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

  // Resetear contraseña
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
