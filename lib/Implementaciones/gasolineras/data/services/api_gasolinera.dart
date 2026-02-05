import 'package:http/http.dart' as http;
import 'package:my_gasolinera/core/config/api_config.dart';
import 'dart:convert';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Obtiene gasolineras cercanas a una ubicación (lat, lng)
Future<List<Gasolinera>> fetchGasolinerasPorCercania(
    double lat, double lng) async {
  try {
    final baseUrl = ApiConfig.baseUrl;
    final uri = Uri.parse('$baseUrl/api/gasolineras').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lng': lng.toString(),
      },
    );

    AppLogger.network('Solicitando gasolineras por cercanía',
        tag: 'ApiGasolinera');

    final response = await http
        .get(uri, headers: ApiConfig.headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final bodyUtf8 = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(bodyUtf8);

      if (jsonResponse['success'] == true) {
        final List<dynamic> listaGasolineras =
            jsonResponse['gasolineras'] ?? [];

        AppLogger.network(
            'Recibidas ${listaGasolineras.length} gasolineras por cercanía',
            tag: 'ApiGasolinera');

        return listaGasolineras
            .map((jsonItem) => Gasolinera.fromJson(jsonItem))
            .where((g) => g.lat != 0.0 && g.lng != 0.0)
            .toList();
      }
    }
    AppLogger.error('API Backend Error HTTP: ${response.statusCode}',
        tag: 'ApiGasolinera');
    return [];
  } catch (e) {
    AppLogger.error('API Backend Excepción', tag: 'ApiGasolinera', error: e);
    return [];
  }
}

/// Obtiene gasolineras filtradas por provincia
/// El ID de provincia es un código de 2 dígitos (ej: '28' para Madrid)
/// Obtiene gasolineras filtradas por provincia usando nuestro Backend Optimizado
/// El ID de provincia es un código de 2 dígitos (ej: '28' para Madrid)
Future<List<Gasolinera>> fetchGasolinerasByProvincia(String provinciaId) async {
  try {
    // 1. Obtener URL base del backend desde ConfigService
    final baseUrl = ApiConfig.baseUrl; // E.g., http://localhost:3000

    // 2. Construir URI para el nuevo endpoint
    // Endpoint: /api/gasolineras?id_provincia=28
    final uri = Uri.parse('$baseUrl/api/gasolineras')
        .replace(queryParameters: {'id_provincia': provinciaId});

    AppLogger.network('Solicitando gasolineras para provincia $provinciaId',
        tag: 'ApiGasolinera');

    // 3. Realizar petición con timeout corto (el backend debería ser rápido)
    final response = await http
        .get(uri, headers: ApiConfig.headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final bodyUtf8 = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(bodyUtf8);

      if (jsonResponse['success'] == true) {
        final List<dynamic> listaGasolineras =
            jsonResponse['gasolineras'] ?? [];

        AppLogger.network('Recibidas ${listaGasolineras.length} gasolineras',
            tag: 'ApiGasolinera');

        return listaGasolineras
            .map((jsonItem) => Gasolinera.fromJson(jsonItem))
            .where((g) => g.lat != 0.0 && g.lng != 0.0)
            .toList();
      } else {
        AppLogger.error('API Backend Error lógico: ${jsonResponse['message']}',
            tag: 'ApiGasolinera');
        return [];
      }
    } else {
      AppLogger.error('API Backend Error HTTP: ${response.statusCode}',
          tag: 'ApiGasolinera');
      return [];
    }
  } catch (e) {
    AppLogger.error('API Backend Excepción', tag: 'ApiGasolinera', error: e);
    // Fallback silencioso: devolver lista vacía para que la UI use caché si tiene
    return [];
  }
}

/// 🆕 Clase central para mapeo de provincias (sin redundancia)
class ProvinciaMapper {
  /// Mapeo bidireccional: nombre ↔ código
  static const Map<String, String> provinciaMap = {
    // Provincias por nombre (clave) → código (valor)
    'Álava': '01',
    'Albacete': '02',
    'Alicante': '03',
    'Almería': '04',
    'Ávila': '05',
    'Badajoz': '06',
    'Barcelona': '08',
    'Burgos': '09',
    'Cáceres': '10',
    'Cádiz': '11',
    'Castellón': '12',
    'Ciudad Real': '13',
    'Córdoba': '14',
    'Cuenca': '16',
    'Girona': '17',
    'Granada': '18',
    'Guadalajara': '19',
    'Guipúzcoa': '20',
    'Huelva': '21',
    'Huesca': '22',
    'Jaén': '23',
    'La Coruña': '15',
    'La Rioja': '26',
    'Las Palmas': '35',
    'León': '24',
    'Lleida': '25',
    'Lugo': '27',
    'Madrid': '28',
    'Málaga': '29',
    'Murcia': '30',
    'Navarra': '31',
    'Ourense': '32',
    'Palencia': '34',
    'Palma de Mallorca': '07',
    'Pontevedra': '36',
    'Salamanca': '37',
    'Santa Cruz de Tenerife': '38',
    'Segovia': '40',
    'Sevilla': '41',
    'Soria': '42',
    'Tarragona': '43',
    'Teruel': '44',
    'Toledo': '45',
    'Valencia': '46',
    'Valladolid': '47',
    'Vizcaya': '48',
    'Zamora': '49',
    'Zaragoza': '50',
    'Ceuta': '51',
    'Melilla': '52',
    'Asturias': '33',
    'Cantabria': '39',
    'Baleares': '07',
    'Canarias': '35',

    // Variantes por Comunidades Autónomas
    'Comunidad de Madrid': '28',
    'Cataluña': '08',
    'Comunidad Valenciana': '46',
    'Andalucía': '41',
    'Aragon': '50',
    'Castilla y León': '47',
    'País Vasco': '48',
    'Extremadura': '06',
    'Castilla-La Mancha': '13',
    'Galicia': '27',
    'Región de Murcia': '30',
  };

  /// Mapeo inverso: código → nombre (generado automáticamente)
  static final Map<String, String> codigoMap = Map.fromEntries(
      provinciaMap.entries.map((e) => MapEntry(e.value, e.key)));

  /// Obtiene el ID de provincia desde el nombre
  /// "Comunidad de Madrid" → "28"
  static String? obtenerIdDesdeNombre(String nombreProvincia) {
    if (provinciaMap.containsKey(nombreProvincia)) {
      return provinciaMap[nombreProvincia];
    }

    AppLogger.warning('Provincia no encontrada: $nombreProvincia',
        tag: 'ProvinciaMapper');
    return null;
  }

  /// Obtiene el nombre de provincia desde el código
  /// "28" → "Madrid"
  static String obtenerNombreDesdeId(String codigo) {
    return codigoMap[codigo] ?? 'Desconocida';
  }

  /// Obtiene el código de provincia desde cualquier nombre (con fuzzy matching)
  /// Útil si el geocoding devuelve variantes
  static String? obtenerIdConTolernacia(String nombreProvincia) {
    // Búsqueda exacta primero
    if (provinciaMap.containsKey(nombreProvincia)) {
      return provinciaMap[nombreProvincia];
    }

    // Búsqueda sin acentos (normalizada)
    String normalizado = _normalizarTexto(nombreProvincia);
    for (var entrada in provinciaMap.entries) {
      if (_normalizarTexto(entrada.key) == normalizado) {
        return entrada.value;
      }
    }

    AppLogger.warning(
        'Provincia no mapeada (ni siquiera normalizada): $nombreProvincia',
        tag: 'ProvinciaMapper');
    return null;
  }

  /// Normaliza texto: elimina acentos y convierte a minúsculas
  static String _normalizarTexto(String texto) {
    const Map<String, String> acentos = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'a',
      'É': 'e',
      'Í': 'i',
      'Ó': 'o',
      'Ú': 'u',
    };

    String resultado = texto.toLowerCase();
    acentos.forEach((key, value) {
      resultado = resultado.replaceAll(key, value);
    });
    return resultado;
  }
}
