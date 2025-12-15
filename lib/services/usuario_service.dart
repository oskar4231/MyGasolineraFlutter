import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/services/auth_service.dart';
import 'api_config.dart';

class UsuarioService {
  /// Obtiene el nombre del usuario desde el backend
  Future<String> obtenerNombreUsuario() async {
    try {
      // Obtener email del usuario
      final email = AuthService.getUserEmail();
      if (email == null || email.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener token si existe
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      final url = ApiConfig.getUrl('/usuarios/perfil/$email');
      print('🔍 DEBUG - Obteniendo nombre de usuario desde: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
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

        // El backend puede retornar el nombre de diferentes formas
        String nombre = 'Usuario';

        if (data is Map) {
          // Intentar obtener el nombre de diferentes campos posibles
          nombre =
              data['nombre'] ??
              data['name'] ??
              data['usuario']?['nombre'] ??
              data['usuario']?['name'] ??
              email.split('@')[0];
        }

        print('🔍 DEBUG - Nombre obtenido: $nombre');

        // Guardar el nombre localmente
        await prefs.setString('userName', nombre);

        return nombre;
      } else if (response.statusCode == 404) {
        print('⚠️ Usuario no encontrado, usando email como nombre');
        return email.split('@')[0];
      } else {
        throw Exception('Error al obtener nombre: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print('❌ Error obteniendo nombre de usuario: $e');

      // Fallback: intentar obtener nombre guardado localmente
      try {
        final prefs = await SharedPreferences.getInstance();
        final nombreLocal = prefs.getString('userName');
        if (nombreLocal != null && nombreLocal.isNotEmpty) {
          return nombreLocal;
        }
      } catch (_) {}

      // Último fallback: usar parte del email
      final email = AuthService.getUserEmail();
      return email?.split('@')[0] ?? 'Usuario';
    }
  }

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

      final url = ApiConfig.getUrl('/usuarios/$emailFormateado');
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

      final url = ApiConfig.getUrl('/cargarImagen/$email');
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
              : '${ApiConfig.baseUrl}/$fotoPerfil';
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
