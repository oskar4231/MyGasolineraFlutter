import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
<<<<<<< HEAD
import 'package:my_gasolinera/services/api_config.dart';

class EstadisticasAvanzadasService {
=======
class EstadisticasAvanzadasService {
  static const String baseUrl = 'http://localhost:3000';
>>>>>>> origin/main
  static Map<String, String> _getHeaders() {
    final token = AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }
<<<<<<< HEAD

=======
>>>>>>> origin/main
  /// Obtener consumo real (L/100km)
  static Future<Map<String, dynamic>> obtenerConsumoReal() async {
    try {
      final response = await http.get(
<<<<<<< HEAD
        Uri.parse('${ApiConfig.estadisticasUrl}/consumo-real'),
=======
        Uri.parse('$baseUrl/estadisticas/consumo-real'),
>>>>>>> origin/main
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
<<<<<<< HEAD
=======
        
        // Si no hay consejos del backend, generar consejos automáticos
        if (!data.containsKey('consejos')) {
          data['consejos'] = _generarConsejos(data);
        }
        
>>>>>>> origin/main
        return data;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerConsumoReal: $e');
      rethrow;
    }
  }

<<<<<<< HEAD
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

=======
  /// Generar consejos automáticos basados en datos de consumo
  static List<String> _generarConsejos(Map<String, dynamic> data) {
    final consejos = <String>[];
    
    // Analizar consumo promedio
    final consumoPromedio = double.tryParse(data['consumo_promedio']?.toString() ?? '0') ?? 0;
    
    if (consumoPromedio > 8) {
      consejos.add('⛽ Mantén una velocidad constante entre 80-100 km/h para mejorar la eficiencia.');
    } else if (consumoPromedio > 6) {
      consejos.add('⛽ Tu consumo es moderado. Evita aceleraciones bruscas para ahorrar combustible.');
    } else {
      consejos.add('⛽ ¡Excelente! Tu consumo es muy eficiente. Mantén estos hábitos.');
    }
    
    consejos.addAll([
      '🔧 Verifica la presión de los neumáticos mensualmente (ideal: 2.2-2.4 bar).',
      '🛢️ Realiza cambios de aceite según el intervalo recomendado de tu vehículo.',
      '🚗 Reduce el peso innecesario: retira objetos del maletero que no uses.',
      '🪟 Cierra las ventanillas a velocidades altas para reducir la resistencia aerodinámica.',
      '⏸️ Planifica tus rutas para evitar atascos y conducción en horas pico.',
    ]);
    
    return consejos;
  }
>>>>>>> origin/main
  /// Obtener costo por kilómetro (por coche)
  static Future<Map<String, dynamic>> obtenerCostoPorKm() async {
    try {
      final response = await http.get(
<<<<<<< HEAD
        Uri.parse('${ApiConfig.estadisticasUrl}/costo-por-km'),
=======
        Uri.parse('$baseUrl/estadisticas/costo-por-km'),
>>>>>>> origin/main
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
<<<<<<< HEAD

=======
        
>>>>>>> origin/main
        // Si no hay costos_por_coche, devolver mapa vacío
        if (!data.containsKey('costos_por_coche')) {
          data['costos_por_coche'] = [];
        }
<<<<<<< HEAD

=======
        
>>>>>>> origin/main
        return data;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerCostoPorKm: $e');
      rethrow;
    }
  }
<<<<<<< HEAD

=======
>>>>>>> origin/main
  /// Obtener información de mantenimiento
  static Future<List<Map<String, dynamic>>> obtenerMantenimiento() async {
    try {
      final response = await http.get(
<<<<<<< HEAD
        Uri.parse('${ApiConfig.estadisticasUrl}/mantenimiento'),
=======
        Uri.parse('$baseUrl/estadisticas/mantenimiento'),
>>>>>>> origin/main
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
<<<<<<< HEAD
}
=======
}
>>>>>>> origin/main
