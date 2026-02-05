import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/core/config/api_config.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class CocheService {
  // Obtener todos los coches del usuario - devuelve List<dynamic> en lugar de List<Coche>
  static Future<List<dynamic>> obtenerCoches() async {
    try {
      final token = AuthService.getToken();

      if (token == null || token.isEmpty) {
        AppLogger.warning('No hay token, usuario no autenticado',
            tag: 'CocheService');
        return [];
      }

      final url = Uri.parse(ApiConfig.cochesUrl);

      AppLogger.debug('Cargando coches desde: $url', tag: 'CocheService');

      final response = await http.get(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.debug('Respuesta status: ${response.statusCode}',
          tag: 'CocheService');

      if (response.statusCode == 200) {
        final List<dynamic> cochesJson = json.decode(response.body);
        return cochesJson; // Devuelve List<dynamic> directamente
      } else {
        AppLogger.error('Error al cargar coches: ${response.statusCode}',
            tag: 'CocheService');
        throw Exception('Error al cargar coches: ${response.statusCode}');
      }
    } catch (error) {
      AppLogger.error('Error de conexión al cargar coches',
          tag: 'CocheService', error: error);
      rethrow;
    }
  }

  // Crear un nuevo coche - devuelve Map<String, dynamic> en lugar de Coche
  static Future<Map<String, dynamic>> crearCoche({
    required String marca,
    required String modelo,
    required List<String> tiposCombustible,
    int? kilometrajeInicial,
    double? capacidadTanque,
    double? consumoTeorico,
    String? fechaUltimoCambioAceite,
    int? kmUltimoCambioAceite,
    int intervaloCambioAceiteKm = 15000,
    int intervaloCambioAceiteMeses = 12,
  }) async {
    try {
      final token = AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Debes iniciar sesión primero para añadir coches');
      }

      final url = Uri.parse(ApiConfig.getUrl('/insertCar'));
      final combustibleString = tiposCombustible.join(', ');

      AppLogger.debug('Intentando crear coche en: $url', tag: 'CocheService');
      AppLogger.debug('Marca: $marca', tag: 'CocheService');
      AppLogger.debug('Modelo: $modelo', tag: 'CocheService');
      AppLogger.debug('Combustible: $combustibleString', tag: 'CocheService');

      final response = await http.post(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'marca': marca,
          'modelo': modelo,
          'combustible': combustibleString,
          'kilometraje_inicial': kilometrajeInicial,
          'capacidad_tanque': capacidadTanque,
          'consumo_teorico': consumoTeorico,
          'fecha_ultimo_cambio_aceite': fechaUltimoCambioAceite,
          'km_ultimo_cambio_aceite': kmUltimoCambioAceite,
          'intervalo_cambio_aceite_km': intervaloCambioAceiteKm,
          'intervalo_cambio_aceite_meses': intervaloCambioAceiteMeses,
        }),
      );

      AppLogger.debug('Respuesta status: ${response.statusCode}',
          tag: 'CocheService');
      AppLogger.debug('Respuesta body: ${response.body}', tag: 'CocheService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData; // Devuelve Map<String, dynamic> directamente
      } else {
        final responseData = json.decode(response.body);
        String errorMessage =
            responseData['message'] ?? 'Error al crear el coche';
        throw Exception(errorMessage);
      }
    } catch (error) {
      AppLogger.error('Error de conexión al crear coche',
          tag: 'CocheService', error: error);
      rethrow;
    }
  }

  // Eliminar un coche
  static Future<void> eliminarCoche(int idCoche) async {
    try {
      final token = AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Debes iniciar sesión para eliminar coches');
      }

      final url = Uri.parse('${ApiConfig.cochesUrl}/$idCoche');

      AppLogger.debug('Eliminando coche: $idCoche', tag: 'CocheService');

      final response = await http.delete(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.debug('Respuesta status: ${response.statusCode}',
          tag: 'CocheService');
      AppLogger.debug('Respuesta body: ${response.body}', tag: 'CocheService');

      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        String errorMessage =
            responseData['message'] ?? 'Error al eliminar el coche';
        throw Exception(errorMessage);
      }
    } catch (error) {
      AppLogger.error('Error al eliminar coche',
          tag: 'CocheService', error: error);
      rethrow;
    }
  }
}
