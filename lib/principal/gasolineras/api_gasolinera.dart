// map_page.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';
// ... otros imports

Future<List<Gasolinera>> fetchGasolineras() async {
  // 🎯 URL exacta proporcionada por el usuario
  const url = 'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/';
  final uri = Uri.parse(url);

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // La API del gobierno a veces usa codificación 'windows-1252',
      // por lo que decodificamos explícitamente a UTF-8 para evitar problemas con tildes (ñ, ó, etc.).
      final bodyUtf8 = utf8.decode(response.bodyBytes);
      final data = json.decode(bodyUtf8);

      // La lista de gasolineras está anidada en la clave 'ListaEESSPrecio'
      final List<dynamic> listaEESS = data['ListaEESSPrecio'] ?? [];

      // Mapeamos el JSON a objetos Gasolinera
      return listaEESS
          .map((jsonItem) => Gasolinera.fromJson(jsonItem))
          // Filtramos las que no tienen coordenadas válidas (lat o lng es 0.0)
          .where((g) => g.lat != 0.0 && g.lng != 0.0)
          .toList();

    } else {
      // ignore: avoid_print
      print('Error al cargar datos: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    // ignore: avoid_print
    print('Error de red o decodificación: $e');
    return [];
  }
}