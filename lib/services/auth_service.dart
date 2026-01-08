import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

// Servicio para gestionar el token de autenticación y recuperación de contraseña
class AuthService {
  static String? _token;
  static String? _userEmail;

  // Guardar el token y email del usuario
  static Future<void> saveToken(String token, String email) async {
    _token = token;
    _userEmail = email;

    // Guardar también en SharedPreferences para persistencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    await prefs.setString('userEmail', email);

    print('Token guardado para: $email');
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
    print('Sesión cerrada');
  }

  // ==================== RECUPERACIÓN DE CONTRASEÑA ====================

  // Solicitar recuperación de contraseña
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.forgotPasswordUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      print('Respuesta forgot-password: $data');
      return data;
    } catch (e) {
      print('Error en forgotPassword: $e');
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }

  // Verificar token
  static Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      final data = jsonDecode(response.body);
      print('Respuesta verify-token: $data');
      return data;
    } catch (e) {
      print('Error en verifyToken: $e');
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'newPassword': newPassword}),
      );

      final data = jsonDecode(response.body);
      print('Respuesta reset-password: $data');
      return data;
    } catch (e) {
      print('Error en resetPassword: $e');
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }
}
