import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/core/config/api_config.dart';
import 'package:my_gasolinera/core/utils/http_helper.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

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
        AppLogger.error('No hay token de autenticación', tag: 'PerfilService');
        return false;
      }

      // Crear la petición multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.perfilUrl}/upload-photo'),
      );

      // Agregar el token en los headers
      request.headers.addAll(HttpHelper.getLanguageHeaders());
      request.headers.addAll(ApiConfig.headers);
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
      AppLogger.debug('Subiendo foto de perfil...', tag: 'PerfilService');
      AppLogger.debug('URL: ${ApiConfig.perfilUrl}/upload-photo',
          tag: 'PerfilService');
      AppLogger.debug('Token presente: ${token.isNotEmpty}',
          tag: 'PerfilService');

      var response = await request.send();

      // Leer la respuesta
      var responseData = await response.stream.bytesToString();
      AppLogger.debug('Status Code: ${response.statusCode}',
          tag: 'PerfilService');
      AppLogger.debug('Response: $responseData', tag: 'PerfilService');

      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        AppLogger.info('Foto de perfil subida exitosamente',
            tag: 'PerfilService');
        AppLogger.debug('URL de la foto: ${jsonResponse['photoUrl']}',
            tag: 'PerfilService');

        // Guardar la URL de la foto en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('foto_perfil', jsonResponse['photoUrl']);

        return true;
      } else {
        AppLogger.error('Error al subir foto: ${jsonResponse['message']}',
            tag: 'PerfilService');
        return false;
      }
    } catch (e) {
      AppLogger.error('Error en subirFotoPerfil',
          tag: 'PerfilService', error: e);
      AppLogger.debug('Stack trace: ${StackTrace.current}',
          tag: 'PerfilService');
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
        AppLogger.error('No hay token de autenticación', tag: 'PerfilService');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.perfilUrl}/profile'),
        headers: {
          ...HttpHelper.getLanguageHeaders(),
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
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
      AppLogger.error('Error en obtenerFotoPerfil',
          tag: 'PerfilService', error: e);
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
