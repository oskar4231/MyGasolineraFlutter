import 'dart:convert';
import 'package:http/http.dart' as http;

// Servicio para gestionar el token de autenticación y recuperación de contraseña
class AuthService {
  static String? _token;
  static String? _userEmail;

  // IMPORTANTE: Cambia esta URL por la IP de tu servidor backend
  // Si usas emulador Android: 10.0.2.2
  // Si usas dispositivo físico: 10.2.1.158 (Tu IP actual)
  static const String baseUrl = 'http://localhost:3000';

  // Guardar el token y email del usuario
  static void saveToken(String token, String email) {
    _token = token;
    _userEmail = email;
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
        Uri.parse('$baseUrl/forgot-password'),
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
        Uri.parse('$baseUrl/verify-token'),
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
        Uri.parse('$baseUrl/reset-password'),
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
