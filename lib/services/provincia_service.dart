import 'package:shared_preferences/shared_preferences.dart';
import 'polygon_utils.dart';

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
    final prefs = await SharedPreferences.getInstance();

    print('ProvinciaService: Detectando (Polígonos) para Lat: $lat, Lng: $lng');

    // 1. Definir Polígonos Simplificados (Lat, Lng)
    // Estos puntos forman el "Mapa Invisible" aproximado

    // CASTELLÓN (ID: 12)
    // Polígono aproximado que cubre la provincia
    final castellonPolygon = [
      [40.80, -0.80], // Noroeste (interior, cerca de Teruel)
      [40.70, 0.20], // Costa Norte (Vinaròs)
      [40.30, 0.10], // Costa (Benicàssim)
      [39.80, 0.00], // Costa Sur (Sagunto frontera)
      [39.70, -0.50], // Interior Sur (frontera Valencia)
      [40.00, -1.00], // Interior (Segorbe área)
      [40.50, -0.90], // Interior Norte
    ];

    // VALENCIA (ID: 46)
    // Polígono aproximado que cubre la provincia (mejorado)
    final valenciaPolygon = [
      [39.90, -1.50], // Noroeste (cerca de Cuenca)
      [39.80, -0.50], // Norte (frontera con Castellón)
      [39.70, 0.00], // Costa Norte (Sagunto)
      [39.50, -0.35], // Valencia ciudad
      [39.00, -0.20], // Costa Sur (Gandía)
      [38.70, -0.60], // Sur (frontera con Alicante)
      [38.90, -1.20], // Suroeste (interior)
      [39.40, -1.50], // Oeste (Requena área)
    ];

    // ALICANTE (ID: 03)
    final alicantePolygon = [
      [38.80, -0.60], // Norte (frontera Valencia)
      [38.90, 0.20], // Costa Norte (Denia)
      [38.50, -0.05], // Benidorm área
      [37.80, -0.70], // Sur (Torrevieja)
      [38.00, -1.00], // Suroeste (Orihuela)
      [38.60, -1.00], // Interior (Villena)
    ];

    // ALBACETE (ID: 02)
    final albacetePolygon = [
      [39.40, -2.50], // Noroeste
      [39.20, -1.00], // Noreste (Frontera Valencia)
      [38.60, -1.00], // Este (Frontera Alicante/Murcia)
      [38.30, -1.50], // Sureste
      [38.40, -2.80], // Sur
      [39.00, -3.00], // Oeste
    ];

    // MADRID (ID: 28)
    final madridPolygon = [
      [41.16, -3.50], // Norte (Somosierra)
      [40.50, -3.00], // Este (Guadalajara border)
      [40.00, -3.00], // Sureste
      [39.80, -3.80], // Sur (Aranjuez/Toledo border)
      [40.20, -4.50], // Oeste
      [40.80, -4.20], // Noroeste
    ];

    // MURCIA (ID: 30) - Añadido para evitar conflictos con sur de Alicante/Albacete
    final murciaPolygon = [
      [38.40, -1.50], // Noroeste
      [38.00, -0.70], // Noreste
      [37.50, -0.60], // Costa
      [37.30, -1.80], // Sur
      [38.00, -2.20], // Oeste
    ];

    // 2. Comprobar Polígonos (Orden de prioridad opcional)

    // Check Castellón first (more specific, northern province)
    if (PolygonUtils.isPointInPolygon(lat, lng, castellonPolygon)) {
      print('ProvinciaService: ¡Detectado CASTELLÓN (por polígono)!');
      final info = ProvinciaInfo('12', 'Castellón');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    if (PolygonUtils.isPointInPolygon(lat, lng, valenciaPolygon)) {
      print('ProvinciaService: ¡Detectado VALENCIA (por polígono)!');
      final info = ProvinciaInfo('46', 'Valencia');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    if (PolygonUtils.isPointInPolygon(lat, lng, madridPolygon)) {
      print('ProvinciaService: ¡Detectado MADRID (por polígono)!');
      final info = ProvinciaInfo('28', 'Madrid');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    if (PolygonUtils.isPointInPolygon(lat, lng, alicantePolygon)) {
      print('ProvinciaService: ¡Detectado ALICANTE (por polígono)!');
      final info = ProvinciaInfo('03', 'Alicante');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    if (PolygonUtils.isPointInPolygon(lat, lng, albacetePolygon)) {
      print('ProvinciaService: ¡Detectado ALBACETE (por polígono)!');
      final info = ProvinciaInfo('02', 'Albacete');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    if (PolygonUtils.isPointInPolygon(lat, lng, murciaPolygon)) {
      print('ProvinciaService: ¡Detectado MURCIA (por polígono)!');
      final info = ProvinciaInfo('30', 'Murcia');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    // 3. Fallback: Detección por rangos simples (Legacy) para otras provincias
    // Barcelona
    if (lat >= 41.0 && lat <= 42.0 && lng >= 1.5 && lng <= 3.0) {
      final info = ProvinciaInfo('08', 'Barcelona');
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

    // Zaragoza
    if (lat >= 41.0 && lat <= 42.0 && lng >= -1.5 && lng <= -0.5) {
      final info = ProvinciaInfo('50', 'Zaragoza');
      await _saveLastProvincia(prefs, info);
      return info;
    }

    // Fallback: Si no cae en ningún polígono, mantener la lógica antigua o devolver la más cercana (o última)
    print(
        'ProvinciaService: No detectado en polígonos, comprobando caché o fallback...');

    // Si no se detecta, usar última conocida
    final lastId = prefs.getString(_prefsKeyLastProvincia);
    final lastNombre = prefs.getString(_prefsKeyLastProvinciaNombre);

    if (lastId != null && lastNombre != null) {
      print('ProvinciaService: Usando última conocida: $lastNombre');
      return ProvinciaInfo(lastId, lastNombre);
    }

    // Por defecto: Madrid
    print('ProvinciaService: Usando Default (Madrid)');
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
