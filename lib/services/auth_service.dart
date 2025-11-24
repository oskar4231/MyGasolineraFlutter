// Servicio para gestionar el token de autenticación
class AuthService {
  static String? _token;
  static String? _userEmail;

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
}
