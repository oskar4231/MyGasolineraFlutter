import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/core/config/api_config.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class FacturaService {
  // Obtener facturas paginadas
  static Future<Map<String, dynamic>> obtenerFacturas(
      {int page = 1, int limit = 10}) async {
    try {
      final token = AuthService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final uri = Uri.parse('${ApiConfig.facturasUrl}?page=$page&limit=$limit');

      final response = await http.get(
        uri,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener facturas: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error en obtenerFacturas',
          tag: 'FacturaService', error: e);
      rethrow;
    }
  }

  // Crear una nueva factura
  static Future<Map<String, dynamic>> crearFactura({
    required String titulo,
    required double coste,
    required String fecha,
    required String hora,
    String? descripcion,
    XFile? imagenFile,
    double? litrosRepostados,
    double? precioPorLitro,
    int? kilometrajeActual,
    String? tipoCombustible,
    int? idCoche,
  }) async {
    try {
      final token = AuthService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      // Crear una petición multipart para enviar la imagen
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.facturasUrl),
      );

      // Agregar headers de autenticación
      request.headers.addAll(ApiConfig.headers);
      request.headers['Authorization'] = 'Bearer $token';

      // Agregar campos del formulario
      request.fields['titulo'] = titulo;
      request.fields['coste'] = coste.toString();
      request.fields['fecha'] = fecha;
      request.fields['hora'] = hora;
      request.fields['descripcion'] = descripcion ?? '';
      request.fields['litros_repostados'] = litrosRepostados?.toString() ?? '';
      request.fields['precio_por_litro'] = precioPorLitro?.toString() ?? '';
      request.fields['kilometraje_actual'] =
          kilometrajeActual?.toString() ?? '';
      request.fields['tipo_combustible'] = tipoCombustible ?? '';
      request.fields['id_coche'] = idCoche?.toString() ?? '';

      // Agregar la imagen si existe
      if (imagenFile != null) {
        try {
          // Leer los bytes del archivo (compatible con Web y Nativo)
          final bytes = await imagenFile.readAsBytes();

          // Determinar el tipo MIME basado en la extensión
          final extension = imagenFile.name.split('.').last.toLowerCase();
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
            'imagen', // Nombre del campo que espera el backend
            bytes,
            filename: imagenFile.name,
            contentType: http.MediaType.parse(contentType),
          );

          request.files.add(multipartFile);
        } catch (e) {
          AppLogger.error('Error al leer la imagen',
              tag: 'FacturaService', error: e);
          // Continuar sin imagen si hay error
        }
      }

      // Enviar la petición
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
          'Error al crear factura: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      AppLogger.error('Error en crearFactura', tag: 'FacturaService', error: e);
      rethrow;
    }
  }

  // Eliminar una factura
  static Future<void> eliminarFactura(int idFactura) async {
    try {
      final token = AuthService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.facturasUrl}/$idFactura'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar factura: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error en eliminarFactura',
          tag: 'FacturaService', error: e);
      rethrow;
    }
  }
}
