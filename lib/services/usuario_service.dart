import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/services/auth_service.dart';

class UsuarioService {
  static const String baseUrl = 'http://localhost:3000'; // Cambia por tu URL real

  /// Elimina la cuenta del usuario marcándola como inactiva
  Future<bool> eliminarCuenta(String email) async {
    try {
      // Obtener el token si lo necesitas para autorización
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      final response = await http.delete(
        Uri.parse('$baseUrl/usuarios/$email'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar con el servidor'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else if (response.statusCode == 400) {
        throw Exception('Email requerido');
      } else {
        throw Exception(
          'Error al eliminar cuenta: ${response.statusCode}',
        );
      }
    } on Exception catch (e) {
      // ignore: avoid_print
      print('Error eliminando cuenta: $e');
      rethrow;
    }
  }

  /// Obtiene el email guardado del usuario logueado
  Future<String> obtenerEmailGuardado() async {
  // Intentar obtener del AuthService primero (está en memoria tras login)
  final email = AuthService.getUserEmail();
  if (email != null && email.isNotEmpty) {
    return email;
  }
  // Fallback a SharedPreferences si no está en AuthService
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userEmail') ?? '';
}

  /// Limpia todos los datos locales del usuario
  Future<void> limpiarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('authToken');
    await prefs.remove('userName');
    await prefs.remove('userPhone');
    await prefs.remove('userId');
  }
}
