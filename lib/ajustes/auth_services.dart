import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      print('✅ Sesión cerrada - Token eliminado');
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }
  
  // Método opcional para verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }
}