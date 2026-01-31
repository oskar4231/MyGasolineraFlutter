import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/core/config/api_config.dart';

class EstadisticasAvanzadasService {
  static Map<String, String> _getHeaders() {
    final token = AuthService.getToken();
    return {
      ...ApiConfig.headers,
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  /// Obtener consumo real (L/100km)
  static Future<Map<String, dynamic>> obtenerConsumoReal() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/consumo-real'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerConsumoReal: $e');
      rethrow;
    }
  }

  /// Obtener consejos personalizados desde el backend
  static Future<List<String>> obtenerConsejos() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/consejos'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> consejos = data['consejos'] ?? [];
        return consejos.map((c) => c.toString()).toList();
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerConsejos: $e');
      return [];
    }
  }

  /// Obtener costo por kilómetro (por coche)
  static Future<Map<String, dynamic>> obtenerCostoPorKm() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/costo-por-km'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Si no hay costos_por_coche, devolver mapa vacío
        if (!data.containsKey('costos_por_coche')) {
          data['costos_por_coche'] = [];
        }

        return data;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerCostoPorKm: $e');
      rethrow;
    }
  }

  /// Obtener información de mantenimiento
  static Future<List<Map<String, dynamic>>> obtenerMantenimiento() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/mantenimiento'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerMantenimiento: $e');
      rethrow;
    }
  }
}
