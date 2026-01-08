import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para detectar y gestionar la provincia actual del usuario
class ProvinciaService {
  static const String _prefsKeyLastProvincia = 'last_provincia_id';
  static const String _prefsKeyLastProvinciaNombre = 'last_provincia_nombre';

  /// Mapa de provincias españolas con sus códigos
  static const Map<String, String> provincias = {
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

  /// Obtiene la provincia actual basada en coordenadas GPS
  /// Por ahora usa un método simplificado basado en rangos geográficos
  /// En producción, se podría usar reverse geocoding o una API
  static Future<ProvinciaInfo> getProvinciaFromCoordinates(
      double lat, double lng) async {
    // Guardar en caché
    final prefs = await SharedPreferences.getInstance();

    // Detección simplificada por rangos geográficos aproximados
    // Madrid (centro de España)
    if (lat >= 40.0 && lat <= 41.0 && lng >= -4.0 && lng <= -3.0) {
      final info = ProvinciaInfo('28', 'Madrid');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    // Barcelona
    if (lat >= 41.0 && lat <= 42.0 && lng >= 1.5 && lng <= 3.0) {
      final info = ProvinciaInfo('08', 'Barcelona');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    // Valencia
    if (lat >= 39.0 && lat <= 40.0 && lng >= -1.0 && lng <= 0.5) {
      final info = ProvinciaInfo('46', 'Valencia');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    // Sevilla
    if (lat >= 37.0 && lat <= 38.0 && lng >= -6.5 && lng <= -5.0) {
      final info = ProvinciaInfo('41', 'Sevilla');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    // Málaga
    if (lat >= 36.5 && lat <= 37.5 && lng >= -5.0 && lng <= -4.0) {
      final info = ProvinciaInfo('29', 'Málaga');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    // Alicante
    if (lat >= 38.0 && lat <= 39.0 && lng >= -1.0 && lng <= 0.0) {
      final info = ProvinciaInfo('03', 'Alicante');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    // Zaragoza
    if (lat >= 41.0 && lat <= 42.0 && lng >= -1.5 && lng <= -0.5) {
      final info = ProvinciaInfo('50', 'Zaragoza');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    // Si no se detecta, usar última conocida o Madrid por defecto
    final lastId = prefs.getString(_prefsKeyLastProvincia);
    final lastNombre = prefs.getString(_prefsKeyLastProvinciaNombre);

    if (lastId != null && lastNombre != null) {
      return ProvinciaInfo(lastId, lastNombre);
    }

    // Por defecto: Madrid
    final defaultInfo = ProvinciaInfo('28', 'Madrid');
    await _saveLastProvincia(prefs, defaultInfo);
    return defaultInfo;
  }

  /// Obtiene provincias cercanas (para cargar gasolineras de provincias limítrofes)
  static List<String> getProvinciasVecinas(String provinciaId) {
    // Mapa simplificado de provincias vecinas
    const Map<String, List<String>> vecinas = {
      '28': [
        '40',
        '19',
        '16',
        '45',
        '05'
      ], // Madrid: Segovia, Guadalajara, Cuenca, Toledo, Ávila
      '08': ['17', '25', '43'], // Barcelona: Girona, Lleida, Tarragona
      '46': [
        '12',
        '44',
        '16',
        '03'
      ], // Valencia: Castellón, Teruel, Cuenca, Alicante
      '41': [
        '21',
        '06',
        '14',
        '11',
        '29'
      ], // Sevilla: Huelva, Badajoz, Córdoba, Cádiz, Málaga
      '29': [
        '41',
        '14',
        '18',
        '11'
      ], // Málaga: Sevilla, Córdoba, Granada, Cádiz
      '03': ['46', '30', '02'], // Alicante: Valencia, Murcia, Albacete
      '50': ['22', '31', '26', '42', '19', '44'], // Zaragoza
    };

    return vecinas[provinciaId] ?? [];
  }

  /// Guarda la última provincia conocida
  static Future<void> _saveLastProvincia(
      SharedPreferences prefs, ProvinciaInfo info) async {
    await prefs.setString(_prefsKeyLastProvincia, info.id);
    await prefs.setString(_prefsKeyLastProvinciaNombre, info.nombre);
  }

  /// Obtiene la última provincia conocida desde caché
  static Future<ProvinciaInfo?> getLastKnownProvincia() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsKeyLastProvincia);
    final nombre = prefs.getString(_prefsKeyLastProvinciaNombre);

    if (id != null && nombre != null) {
      return ProvinciaInfo(id, nombre);
    }
    return null;
  }
}

/// Información de una provincia
class ProvinciaInfo {
  final String id;
  final String nombre;

  ProvinciaInfo(this.id, this.nombre);

  @override
  String toString() => '$nombre ($id)';
}
