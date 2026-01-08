import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/services/auth_service.dart';
import 'package:my_gasolinera/services/api_config.dart';

class PerfilService {
  /// Sube una foto de perfil al servidor
  ///
  /// [imageFile] - El archivo de imagen seleccionado (XFile para soporte web)
  /// Retorna true si la subida fue exitosa, false en caso contrario
  Future<bool> subirFotoPerfil(XFile imageFile) async {
    try {
      // Obtener el token de autenticación desde AuthService
      final token = AuthService.getToken();

      if (token == null || token.isEmpty) {
        print('❌ No hay token de autenticación');
        return false;
      }

      // Crear la petición multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.perfilUrl}/upload-photo'),
      );

      // Agregar el token en los headers
      request.headers['Authorization'] = 'Bearer $token';

      // Leer los bytes del archivo (compatible con Web y Nativo)
      final bytes = await imageFile.readAsBytes();

      // Determinar el tipo MIME basado en la extensión
      final extension = imageFile.name.split('.').last.toLowerCase();
      String contentType = 'image/jpeg'; // Por defecto

      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      } else if (extension == 'jpg' ||
          extension == 'jpeg' ||
          extension == 'jfif') {
        contentType = 'image/jpeg';
      }

      var multipartFile = http.MultipartFile.fromBytes(
        'photo', // Nombre del campo que espera el backend
        bytes,
        filename: imageFile.name,
        contentType: http.MediaType.parse(contentType),
      );

      request.files.add(multipartFile);

      // Enviar la petición
      print('📤 Subiendo foto de perfil...');
      print('🔗 URL: ${ApiConfig.perfilUrl}/upload-photo');
      print('🔑 Token presente: ${token.isNotEmpty}');

      var response = await request.send();

      // Leer la respuesta
      var responseData = await response.stream.bytesToString();
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response: $responseData');

      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        print('✅ Foto de perfil subida exitosamente');
        print('📷 URL de la foto: ${jsonResponse['photoUrl']}');

        // Guardar la URL de la foto en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('foto_perfil', jsonResponse['photoUrl']);

        return true;
      } else {
        print('❌ Error al subir foto: ${jsonResponse['message']}');
        return false;
      }
    } catch (e) {
      print('❌ Error en subirFotoPerfil: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Obtiene la URL de la foto de perfil del usuario
  ///
  /// Retorna la URL de la foto o null si no tiene
  Future<String?> obtenerFotoPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = AuthService.getToken();

      if (token == null || token.isEmpty) {
        print('❌ No hay token de autenticación');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.perfilUrl}/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fotoPerfil = data['user']['foto_perfil'];

        if (fotoPerfil != null && fotoPerfil.isNotEmpty) {
          // Guardar en SharedPreferences para uso offline
          await prefs.setString('foto_perfil', fotoPerfil);
          return fotoPerfil;
        }
      }

      return null;
    } catch (e) {
      print('❌ Error en obtenerFotoPerfil: $e');
      return null;
    }
  }

  /// Obtiene la URL completa de la foto de perfil
  ///
  /// [photoPath] - La ruta relativa de la foto (ej: "uploads/profile-photos/foto.jpg")
  /// Retorna la URL completa para cargar la imagen
  String obtenerUrlCompletaFoto(String photoPath) {
    return '${ApiConfig.baseUrl}/$photoPath';
  }
}
