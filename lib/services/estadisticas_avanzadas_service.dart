import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
class EstadisticasAvanzadasService {
  static const String baseUrl = 'http://localhost:3000';
  static Map<String, String> _getHeaders() {
    final token = AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }
  /// Obtener consumo real (L/100km)
  static Future<Map<String, dynamic>> obtenerConsumoReal() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estadisticas/consumo-real'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerConsumoReal: $e');
      rethrow;
    }
  }
  /// Obtener costo por kilómetro
  static Future<Map<String, dynamic>> obtenerCostoPorKm() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estadisticas/costo-por-km'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
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
        Uri.parse('$baseUrl/estadisticas/mantenimiento'),
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