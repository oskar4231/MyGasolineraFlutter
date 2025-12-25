import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';

/// Obtiene todas las gasolineras de España
Future<List<Gasolinera>> fetchGasolineras() async {
  const url =
      'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/';
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

/// Obtiene gasolineras filtradas por provincia
/// El ID de provincia es un código de 2 dígitos (ej: '28' para Madrid)
Future<List<Gasolinera>> fetchGasolinerasByProvincia(String provinciaId) async {
  // La API del gobierno no tiene endpoint por provincia, así que cargamos todas
  // y filtramos localmente. En el futuro se podría usar una API propia en el backend.
  final allGasolineras = await fetchGasolineras();

  // Filtrar por provincia
  return allGasolineras.where((g) {
    // Intentar matchear por idProvincia o por nombre de provincia
    return g.idProvincia == provinciaId ||
        g.provincia
            .toLowerCase()
            .contains(_getProvinciaNombre(provinciaId).toLowerCase());
  }).toList();
}

/// Mapeo de códigos de provincia a nombres (simplificado)
String _getProvinciaNombre(String codigo) {
  const Map<String, String> provincias = {
    '01': 'Álava',
    '02': 'Albacete',
    '03': 'Alicante',
    '04': 'Almería',
    '05': 'Ávila',
    '06': 'Badajoz',
    '07': 'Baleares',
    '08': 'Barcelona',
    '09': 'Burgos',
    '10': 'Cáceres',
    '11': 'Cádiz',
    '12': 'Castellón',
    '13': 'Ciudad Real',
    '14': 'Córdoba',
    '15': 'A Coruña',
    '16': 'Cuenca',
    '17': 'Girona',
    '18': 'Granada',
    '19': 'Guadalajara',
    '20': 'Guipúzcoa',
    '21': 'Huelva',
    '22': 'Huesca',
    '23': 'Jaén',
    '24': 'León',
    '25': 'Lleida',
    '26': 'La Rioja',
    '27': 'Lugo',
    '28': 'Madrid',
    '29': 'Málaga',
    '30': 'Murcia',
    '31': 'Navarra',
    '32': 'Ourense',
    '33': 'Asturias',
    '34': 'Palencia',
    '35': 'Las Palmas',
    '36': 'Pontevedra',
    '37': 'Salamanca',
    '38': 'Santa Cruz de Tenerife',
    '39': 'Cantabria',
    '40': 'Segovia',
    '41': 'Sevilla',
    '42': 'Soria',
    '43': 'Tarragona',
    '44': 'Teruel',
    '45': 'Toledo',
    '46': 'Valencia',
    '47': 'Valladolid',
    '48': 'Vizcaya',
    '49': 'Zamora',
    '50': 'Zaragoza',
    '51': 'Ceuta',
    '52': 'Melilla',
  };
  return provincias[codigo] ?? '';
}
