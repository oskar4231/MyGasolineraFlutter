import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class AuthService {
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      AppLogger.info('Sesión cerrada - Token eliminado', tag: 'AuthService');
    } catch (e) {
      AppLogger.error('Error al cerrar sesión', tag: 'AuthService', error: e);
    }
  }

  // Método opcional para verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }
}
