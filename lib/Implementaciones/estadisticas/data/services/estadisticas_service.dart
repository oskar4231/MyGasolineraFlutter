import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/core/config/api_config.dart';

/// Servicio para obtener estadísticas de gastos de combustible
class EstadisticasService {
  /// Headers comunes con autenticación
  static Map<String, String> _getHeaders() {
    final token = AuthService.getToken();
    return {
      ...ApiConfig.headers,
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // ==================== MÉTODOS INDIVIDUALES ====================

  /// 1️⃣ Obtener gasto total del usuario
  static Future<Map<String, dynamic>> obtenerGastoTotal() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/total'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error en obtenerGastoTotal: $e');
      rethrow;
    }
  }

  /// 2️⃣ Obtener gasto del mes actual
  static Future<Map<String, dynamic>> obtenerGastoMesActual() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/mes-actual'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error en obtenerGastoMesActual: $e');
      rethrow;
    }
  }

  /// 3️⃣ Obtener promedio mensual (últimos 6 meses)
  static Future<Map<String, dynamic>> obtenerPromedioMensual() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/promedio-mensual'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error en obtenerPromedioMensual: $e');
      rethrow;
    }
  }

  /// 5️⃣ Obtener gasto anual (últimos 12 meses)
  static Future<Map<String, dynamic>> obtenerGastoAnual() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/anual'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error en obtenerGastoAnual: $e');
      rethrow;
    }
  }

  /// 6️⃣ Obtener comparación mes actual vs mes anterior
  static Future<Map<String, dynamic>> obtenerComparacionMensual() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/mes-comparacion'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error en obtenerComparacionMensual: $e');
      rethrow;
    }
  }

  /// 7️⃣ Obtener gastos por mes (para gráficas)
  static Future<List<Map<String, dynamic>>> obtenerGastosPorMes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/por-mes'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error en obtenerGastosPorMes: $e');
      rethrow;
    }
  }

  /// 8️⃣ Obtener promedio por factura
  static Future<Map<String, dynamic>> obtenerPromedioFactura() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/promedio-factura'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error en obtenerPromedioFactura: $e');
      rethrow;
    }
  }

  /// 1️⃣3️⃣ Obtener proyección de fin de mes
  static Future<Map<String, dynamic>> obtenerProyeccionFinMes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.estadisticasUrl}/proyeccion-fin-mes'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error en obtenerProyeccionFinMes: $e');
      rethrow;
    }
  }

  // ==================== MÉTODO COMPLETO (RECOMENDADO) ====================

  /// 🎯 Obtener todas las estadísticas en una sola llamada
  ///
  /// Retorna un objeto con todas las estadísticas necesarias:
  /// - resumen: Gasto total, promedio por factura, etc.
  /// - mesActual: Gasto del mes en curso
  /// - comparativa: Mes actual vs anterior
  /// - gastosPorMes: Array para gráficas
  /// - proyeccion: Proyección de fin de mes
  static Future<Map<String, dynamic>> obtenerTodasEstadisticas() async {
    try {
      // Hacer todas las llamadas en paralelo para mejor rendimiento
      final results = await Future.wait([
        obtenerGastoTotal(), // 0
        obtenerGastoMesActual(), // 1
        obtenerPromedioMensual(), // 2
        obtenerGastoAnual(), // 3
        obtenerComparacionMensual(), // 4
        obtenerGastosPorMes(), // 5
        obtenerPromedioFactura(), // 6
        obtenerProyeccionFinMes(), // 7
      ]);

      // Cast explícito para evitar errores de tipado
      final gastoTotal = results[0] as Map<String, dynamic>;
      final mesActual = results[1] as Map<String, dynamic>;
      final promedioMensual = results[2] as Map<String, dynamic>;
      final anual = results[3] as Map<String, dynamic>;
      final comparativa = results[4] as Map<String, dynamic>;
      final gastosPorMes = results[5] as List<Map<String, dynamic>>;
      final promedioFactura = results[6] as Map<String, dynamic>;
      final proyeccion = results[7] as Map<String, dynamic>;

      return {
        'resumen': {
          'gasto_total': gastoTotal['gasto_total'],
          'total_facturas': gastoTotal['total_facturas'],
          'promedio_por_factura': promedioFactura['promedio_por_factura'],
          'gasto_minimo': promedioFactura['gasto_minimo'],
          'gasto_maximo': promedioFactura['gasto_maximo'],
        },
        'mesActual': {
          'gasto': mesActual['gasto_mes_actual'],
          'facturas': mesActual['facturas_mes_actual'],
        },
        'promedioMensual': promedioMensual['promedio_mensual'],
        'anual': {
          'gasto': anual['gasto_anual'],
          'facturas': anual['facturas_anual'],
        },
        'comparativa': {
          'mes_actual': comparativa['gasto_mes_actual'],
          'mes_anterior': comparativa['gasto_mes_anterior'],
          'diferencia': comparativa['diferencia'],
          'porcentaje_cambio': comparativa['porcentaje_cambio'],
        },
        'gastosPorMes': gastosPorMes,
        'proyeccion': {
          'gasto_actual': proyeccion['gasto_actual'],
          'dias_transcurridos': proyeccion['dias_transcurridos'],
          'dias_totales_mes': proyeccion['dias_totales_mes'],
          'proyeccion_fin_mes': proyeccion['proyeccion_fin_mes'],
        },
      };
    } catch (e) {
      print('Error en obtenerTodasEstadisticas: $e');
      rethrow;
    }
  }
}
