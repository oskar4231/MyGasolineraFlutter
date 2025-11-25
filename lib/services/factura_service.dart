import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FacturaService {
  static const String baseUrl = 'http://localhost:3000';

  // Obtener todas las facturas del usuario
  static Future<List<Map<String, dynamic>>> obtenerFacturas() async {
    try {
      final token = AuthService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/facturas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((factura) => factura as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error al obtener facturas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerFacturas: $e');
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
    String? imagenPath,
  }) async {
    try {
      final token = AuthService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final body = {
        'titulo': titulo,
        'coste': coste, // Cambiar a 'coste' para que coincida con el backend
        'fecha': fecha,
        'hora': hora,
        'descripcion': descripcion ?? '',
        'imagenPath': imagenPath ?? '',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/facturas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Error al crear factura: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en crearFactura: $e');
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
        Uri.parse('$baseUrl/facturas/$idFactura'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar factura: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en eliminarFactura: $e');
      rethrow;
    }
  }
}
