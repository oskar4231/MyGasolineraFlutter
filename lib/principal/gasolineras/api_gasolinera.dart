import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';

Future<List<Gasolinera>> fetchGasolineras() async {
  const url = 'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/';
  final uri = Uri.parse(url);

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final bodyUtf8 = utf8.decode(response.bodyBytes);
      final data = json.decode(bodyUtf8);

      final List<dynamic> listaEESS = data['ListaEESSPrecio'] ?? [];

      return listaEESS
          .map((jsonItem) => Gasolinera.fromJson(jsonItem))
          .where((g) => g.lat != 0.0 && g.lng != 0.0)
          .toList();
    } else {
      print('Error al cargar datos: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error de red o decodificación: $e');
    return [];
  }
}
