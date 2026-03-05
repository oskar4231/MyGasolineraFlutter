import 'package:my_gasolinera/core/security/auth_storage.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Servicio auxiliar de auth usado desde Ajustes.
/// Delega en [AuthStorage] (flutter_secure_storage) para garantizar
/// que el logout borra las credenciales cifradas del dispositivo.
class AuthService {
  /// Cierra sesión borrando todas las credenciales del almacenamiento seguro.
  static Future<void> logout() async {
    try {
      await AuthStorage.clearCredentials();
      AppLogger.info('Sesión cerrada - Credenciales eliminadas de forma segura',
          tag: 'AuthService');
    } catch (e) {
      AppLogger.error('Error al cerrar sesión', tag: 'AuthService', error: e);
    }
  }

  /// Verifica si hay sesión activa consultando el almacenamiento seguro.
  static Future<bool> isLoggedIn() async {
    return await AuthStorage.isLoggedIn();
  }
}
