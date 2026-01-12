import 'package:google_maps_flutter/google_maps_flutter.dart';

class Gasolinera {
  final String id;
  final String rotulo;
  final String direccion;
  final double lat;
  final double lng;
  final String horario;

  final double gasolina95;
  final double gasolina95E10;
  final double gasolina98;
  final double gasoleoA;
  final double gasoleoPremium;
  final double glp;
  final double biodiesel;
  final double bioetanol;
  final double esterMetilico;
  final double hidrogeno;

  // Información de provincia
  final String provincia;
  final String idProvincia;

  Gasolinera({
    required this.id,
    required this.rotulo,
    required this.direccion,
    required this.lat,
    required this.lng,
    required this.provincia,
    required this.horario,
    required this.gasolina95,
    required this.gasolina95E10,
    required this.gasolina98,
    required this.gasoleoA,
    required this.gasoleoPremium,
    required this.glp,
    required this.biodiesel,
    required this.bioetanol,
    required this.esterMetilico,
    required this.hidrogeno,
    this.idProvincia = '',
  });

  // 🔧 Conversión segura de precios (acepta String o num)
  static double _parsePrecio(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      if (value.trim().isEmpty || value.trim().toUpperCase() == 'N/A')
        return 0.0;
      // Reemplazar coma por punto si es necesario
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }

    return 0.0;
  }

  // 🏭 Constructor desde JSON oficial del Ministerio O desde nuestro backend
  factory Gasolinera.fromJson(Map<String, dynamic> json) {
    // Detectar si el JSON tiene lat/lng directos (backend) o Latitud/Longitud (API Gobierno)
    // El backend envía 'lat' (num) y 'lng' (num).
    // La API Gobierno envía 'Latitud' (String) y 'Longitud (WGS84)' (String).

    double lat;
    double lng;

    if (json.containsKey('lat') && json['lat'] is num) {
      lat = (json['lat'] as num).toDouble();
    } else {
      lat = _parsePrecio(json['Latitud']);
    }

    if (json.containsKey('lng') && json['lng'] is num) {
      lng = (json['lng'] as num).toDouble();
    } else {
      lng = _parsePrecio(json['Longitud (WGS84)']);
    }

    return Gasolinera(
      id: (json['IDEESS'] ?? json['id'] ?? '').toString(),
      rotulo: json['Rótulo'] ?? json['rotulo'] ?? 'Sin Rótulo',
      direccion: (json['Dirección'] ?? json['direccion'] ?? '') +
          // Si viene del gobierno, añadir municipio. Si viene del backend, la dirección ya suele estar completa o el municipio viene aparte
          (json.containsKey('Municipio') &&
                  (json['Dirección'] != null || json['direccion'] != null)
              ? ', ${json['Municipio']}'
              : ''),
      horario: json['Horario'] ?? json['horario'] ?? '',
      lat: lat,
      lng: lng,
      // Usar _parsePrecio para todos, maneja String y num automáticamente
      gasolina95: _parsePrecio(json['Precio Gasolina 95 E5']),
      gasolina95E10: _parsePrecio(json['Precio Gasolina 95 E10']),
      gasolina98: _parsePrecio(json['Precio Gasolina 98 E5']),
      gasoleoA: _parsePrecio(json['Precio Gasoleo A']),
      gasoleoPremium: _parsePrecio(json['Precio Gasoleo Premium']),
      glp: _parsePrecio(json['Precio Gases licuados del petróleo']),
      biodiesel: _parsePrecio(json['Precio Biodiesel']),
      bioetanol: _parsePrecio(json['Precio Bioetanol']),
      esterMetilico: _parsePrecio(json['Precio Éster metílico']),
      hidrogeno: _parsePrecio(json['Precio Hidrogeno']),
      provincia: json['Provincia'] ?? json['provincia'] ?? '',
      idProvincia:
          json['IDProvincia'] ?? json['idProvincia'] ?? json['IDCCAA'] ?? '',
    );
  }

  // 📍 Getter para usar en Google Maps
  LatLng get position => LatLng(lat, lng);

  // 🕐 Verificar si es 24 horas
  bool get es24Horas {
    final h = horario.toUpperCase();
    return h.contains('24H') || h.contains('24 H') || h.contains('24 HORAS');
  }

  // 🕐 Verificar si está abierta ahora
  bool get estaAbiertaAhora {
    if (es24Horas) return true;
    if (horario.isEmpty)
      return false; // Si no hay horario, asumimos cerrada o desconocida

    final now = DateTime.now();
    final currentDay = now.weekday; // 1=Lunes, 7=Domingo
    final currentTime = now.hour * 60 + now.minute; // Minutos desde medianoche

    try {
      // Formato típico API: "L-D: 07:00-22:00" o "L-V: 07:00-22:00; S: 08:00-15:00"
      final rangos = horario.split(';');

      for (var rango in rangos) {
        rango = rango.trim();
        if (!rango.contains(':')) continue;

        // Separar días de horas. Ej: "L-D" de "07:00-22:00"
        // Buscamos el primer ':' que separa los días de las horas
        int firstColon = rango.indexOf(':');
        String diasStr = rango.substring(0, firstColon).trim();
        String horasStr = rango.substring(firstColon + 1).trim();

        // Verificar si hoy está dentro del rango de días
        if (_esDiaEnRango(currentDay, diasStr)) {
          // Parsear horas "07:00-22:00"
          final horas = horasStr.split('-');
          if (horas.length != 2) continue;

          final apertura = _parseHora(horas[0].trim());
          final cierre = _parseHora(horas[1].trim());

          if (apertura != null && cierre != null) {
            // Caso normal: apertura < cierre (ej: 07:00 - 22:00)
            if (apertura <= cierre) {
              if (currentTime >= apertura && currentTime <= cierre) return true;
            }
            // Caso nocturno cruzando medianoche: apertura > cierre (ej: 22:00 - 06:00)
            else {
              if (currentTime >= apertura || currentTime <= cierre) return true;
            }
          }
        }
      }
    } catch (e) {
      // Si falla el parseo, devolvemos false por seguridad
      return false;
    }

    return false;
  }

  static int? _parseHora(String hora) {
    try {
      final partes = hora.split(':');
      if (partes.length != 2) return null;
      final hh = int.tryParse(partes[0].trim());
      final mm = int.tryParse(partes[1].trim());
      if (hh == null || mm == null) return null;
      return hh * 60 + mm;
    } catch (e) {
      return null;
    }
  }

  static bool _esDiaEnRango(int dia, String rangoStr) {
    rangoStr = rangoStr.toUpperCase().trim();

    final Map<String, int> diasMap = {
      'L': 1, 'M': 2, 'X': 3, 'J': 4, 'V': 5, 'S': 6, 'D': 7,
      'MI': 3, 'JU': 4, 'VI': 5, 'SA': 6, 'DO': 7 // Variantes posibles
    };

    if (rangoStr == 'L-D') return true;

    // Rango tipo "L-V"
    if (rangoStr.contains('-')) {
      final partes = rangoStr.split('-');
      if (partes.length == 2) {
        // Limpiar strings para obtener solo las letras clave
        String inicioStr = partes[0].trim();
        String finStr = partes[1].trim();

        // Manejo básico de abreviaturas
        int? inicio = diasMap[inicioStr] ?? diasMap[inicioStr.substring(0, 1)];
        int? fin = diasMap[finStr] ?? diasMap[finStr.substring(0, 1)];

        if (inicio != null && fin != null) {
          if (inicio <= fin) {
            return dia >= inicio && dia <= fin;
          } else {
            return dia >= inicio || dia <= fin;
          }
        }
      }
    }

    // Días sueltos separados por comas (S,D)
    if (rangoStr.contains(',')) {
      final diasSueltos = rangoStr.split(',');
      for (var d in diasSueltos) {
        int? dNum = diasMap[d.trim()] ?? diasMap[d.trim().substring(0, 1)];
        if (dNum == dia) return true;
      }
      return false;
    }

    // Día único
    int? diaUnico = diasMap[rangoStr] ??
        (rangoStr.isNotEmpty ? diasMap[rangoStr.substring(0, 1)] : null);
    return dia == diaUnico;
  }
}
