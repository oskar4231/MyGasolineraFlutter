import 'package:google_maps_flutter/google_maps_flutter.dart';

class Gasolinera {
  final String id;
  final String rotulo;
  final String direccion;
  final double lat;
  final double lng;
  final String horario;

  // Precios
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

  Gasolinera({
    required this.id,
    required this.rotulo,
    required this.direccion,
    required this.lat,
    required this.lng,
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
  });

  // --- GETTERS ---
  LatLng get position => LatLng(lat, lng);

  bool get es24Horas {
    final h = horario.toUpperCase();
    return h.contains('24H') || h.contains('24 HORAS') || h.contains('L-D: 00:00-24:00');
  }

  bool get estaAbiertaAhora {
    if (es24Horas) return true;
    try {
      final now = DateTime.now();
      final currentHour = now.hour;
      final currentMinute = now.minute;
      final regex = RegExp(r'(\d{2}):(\d{2})-(\d{2}):(\d{2})');
      final match = regex.firstMatch(horario);

      if (match != null) {
        final openH = int.parse(match.group(1)!);
        final openM = int.parse(match.group(2)!);
        final closeH = int.parse(match.group(3)!);
        final closeM = int.parse(match.group(4)!);
        final currentTimeInMinutes = currentHour * 60 + currentMinute;
        final openTimeInMinutes = openH * 60 + openM;
        final closeTimeInMinutes = closeH * 60 + closeM;
        return currentTimeInMinutes >= openTimeInMinutes && currentTimeInMinutes <= closeTimeInMinutes;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  static double _parsePrecio(dynamic input) {
    if (input == null) return 0.0;
    if (input is double) return input;
    if (input is int) return input.toDouble();
    if (input is String) {
      if (input.trim().isEmpty || input.trim().toUpperCase() == 'N/A') return 0.0;
      return double.tryParse(input.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  factory Gasolinera.fromJson(Map<String, dynamic> json) {
    return Gasolinera(
      id: json['IDEESS'].toString(),
      rotulo: json['Rótulo'] ?? 'Sin Rótulo',
      direccion: '${json['Dirección'] ?? ''}, ${json['Municipio'] ?? ''}',
      horario: json['Horario'] ?? '',
      lat: _parsePrecio(json['Latitud']),
      lng: _parsePrecio(json['Longitud (WGS84)']),
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
    );
  }
}