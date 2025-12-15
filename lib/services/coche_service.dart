import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_gasolinera/services/auth_service.dart';

class CocheService {
  static const String baseUrl = 'http://localhost:3000';

  // Obtener todos los coches del usuario - devuelve List<dynamic> en lugar de List<Coche>
  static Future<List<dynamic>> obtenerCoches() async {
    try {
      final token = AuthService.getToken();

      if (token == null || token.isEmpty) {
        print('No hay token, usuario no autenticado');
        return [];
      }

      final url = Uri.parse('$baseUrl/coches');

      print('Cargando coches desde: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Respuesta status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> cochesJson = json.decode(response.body);
        return cochesJson;  // Devuelve List<dynamic> directamente
      } else {
        print('Error al cargar coches: ${response.statusCode}');
        throw Exception('Error al cargar coches: ${response.statusCode}');
      }
    } catch (error) {
      print('Error de conexión al cargar coches: $error');
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

      final url = Uri.parse('$baseUrl/insertCar');
      final combustibleString = tiposCombustible.join(', ');

      print('Intentando crear coche en: $url');
      print('Marca: $marca');
      print('Modelo: $modelo');
      print('Combustible: $combustibleString');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
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

      print('Respuesta status: ${response.statusCode}');
      print('Respuesta body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData;  // Devuelve Map<String, dynamic> directamente
      } else {
        final responseData = json.decode(response.body);
        String errorMessage =
            responseData['message'] ?? 'Error al crear el coche';
        throw Exception(errorMessage);
      }
    } catch (error) {
      print('Error de conexión al crear coche: $error');
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

      final url = Uri.parse('$baseUrl/coches/$idCoche');

      print('Eliminando coche: $idCoche');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Respuesta status: ${response.statusCode}');
      print('Respuesta body: ${response.body}');

      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        String errorMessage =
            responseData['message'] ?? 'Error al eliminar el coche';
        throw Exception(errorMessage);
      }
    } catch (error) {
      print('Error al eliminar coche: $error');
      rethrow;
    }
  }
}