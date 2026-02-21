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
  static void logout() {
    _token = null;
    _userEmail = null;
    AppLogger.info('Sesión cerrada', tag: 'AuthService');
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
