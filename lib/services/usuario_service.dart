import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/services/auth_service.dart';

class UsuarioService {
  static const String baseUrl =
      'http://localhost:3000'; // Cambia por tu URL real

  /// Elimina la cuenta del usuario marcándola como inactiva
  Future<bool> eliminarCuenta(String email) async {
    try {
      // DEBUG: Imprimir el email recibido
      print(
        '🔍 DEBUG - UsuarioService.eliminarCuenta() recibió email: "$email"',
      );
      print('🔍 DEBUG - Longitud del email recibido: ${email.length}');

      // Validar y formatear el email si no contiene @
      String emailFormateado = email;
      if (!email.contains('@')) {
        emailFormateado = '$email@$email.com';
        print('🔍 DEBUG - Email sin @, formateado a: "$emailFormateado"');
      }

      // Obtener el token si lo necesitas para autorización
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      final url = '$baseUrl/usuarios/$emailFormateado';
      print('🔍 DEBUG - URL construida: $url');

      final response = await http
          .delete(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'email': emailFormateado}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception('Timeout al conectar con el servidor'),
          );
      // DEBUG: Imprimir la respuesta del servidor
      print('🔍 DEBUG - Status code: ${response.statusCode}');
      print('🔍 DEBUG - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else if (response.statusCode == 400) {
        throw Exception('Email requerido');
      } else {
        throw Exception('Error al eliminar cuenta: ${response.statusCode}');
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
    print('🔍 DEBUG - obtenerEmailGuardado() - Email de AuthService: "$email"');

    if (email != null && email.isNotEmpty) {
      print(
        '🔍 DEBUG - obtenerEmailGuardado() - Retornando email de AuthService: "$email"',
      );
      return email;
    }

    // Fallback a SharedPreferences si no está en AuthService
    final prefs = await SharedPreferences.getInstance();
    final emailFromPrefs = prefs.getString('userEmail') ?? '';
    print(
      '🔍 DEBUG - obtenerEmailGuardado() - Email de SharedPreferences: "$emailFromPrefs"',
    );
    print(
      '🔍 DEBUG - obtenerEmailGuardado() - Retornando email de SharedPreferences: "$emailFromPrefs"',
    );
    return emailFromPrefs;
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

  /// Obtiene la foto de perfil del usuario desde el backend
  Future<String?> cargarImagenPerfil(String email) async {
    try {
      // Obtener el token de autenticación
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      if (token.isEmpty) {
        throw Exception('No hay sesión activa');
      }

      final url = '$baseUrl/cargarImagen/$email';
      print('🔍 DEBUG - Cargando imagen de perfil desde: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception('Timeout al conectar con el servidor'),
          );

      print('🔍 DEBUG - Status code: ${response.statusCode}');
      print('🔍 DEBUG - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String? fotoPerfil;

        // El backend puede retornar un array o un objeto directo
        if (data is List && data.isNotEmpty) {
          fotoPerfil = data[0]['foto_perfil'];
        } else if (data is Map) {
          fotoPerfil = data['foto_perfil'];
        }

        if (fotoPerfil == null) {
          print('🔍 DEBUG - Usuario no tiene foto de perfil');
          return null;
        }

        print('🔍 DEBUG - Foto de perfil obtenida: $fotoPerfil');

        // Verificar si es una ruta de archivo o base64
        if (fotoPerfil.toString().startsWith('data:image') ||
            fotoPerfil.toString().contains('base64')) {
          // Es base64, retornar directamente
          return fotoPerfil;
        } else if (fotoPerfil.toString().startsWith('uploads/') ||
            fotoPerfil.toString().startsWith('http')) {
          // Es una ruta de archivo, retornar la URL completa
          final imageUrl = fotoPerfil.toString().startsWith('http')
              ? fotoPerfil
              : '$baseUrl/$fotoPerfil';
          print('🔍 DEBUG - URL de imagen: $imageUrl');
          return imageUrl;
        } else {
          // Asumir que es base64 sin prefijo
          return fotoPerfil;
        }
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        throw Exception('Error al cargar imagen: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print('❌ Error cargando imagen de perfil: $e');
      rethrow;
    }
  }
}
