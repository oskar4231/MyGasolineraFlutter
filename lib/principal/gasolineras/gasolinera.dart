import 'package:google_maps_flutter/google_maps_flutter.dart';

class Gasolinera {
  final String id;
  final String rotulo;
  final String direccion;
  final double lat;
  final double lng;

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

  // 🔧 Conversión segura de precios con coma decimal
  static double _parsePrecio(String? precioStr) {
    if (precioStr == null || precioStr.trim().isEmpty || precioStr.trim().toUpperCase() == 'N/A') return 0.0;
    return double.tryParse(precioStr.replaceAll(',', '.')) ?? 0.0;
  }

  // 🏭 Constructor desde JSON oficial del Ministerio
  factory Gasolinera.fromJson(Map<String, dynamic> json) {
    return Gasolinera(
      id: json['IDEESS'].toString(),
      rotulo: json['Rótulo'] ?? 'Sin Rótulo',
      direccion: '${json['Dirección'] ?? ''}, ${json['Municipio'] ?? ''}',
      lat: _parsePrecio(json['Latitud'] as String?),
      lng: _parsePrecio(json['Longitud (WGS84)'] as String?),
      gasolina95: _parsePrecio(json['Precio Gasolina 95 E5'] as String?),
      gasolina95E10: _parsePrecio(json['Precio Gasolina 95 E10'] as String?),
      gasolina98: _parsePrecio(json['Precio Gasolina 98 E5'] as String?),
      gasoleoA: _parsePrecio(json['Precio Gasoleo A'] as String?),
      gasoleoPremium: _parsePrecio(json['Precio Gasoleo Premium'] as String?),
      glp: _parsePrecio(json['Precio Gases licuados del petróleo'] as String?),
      biodiesel: _parsePrecio(json['Precio Biodiesel'] as String?),
      bioetanol: _parsePrecio(json['Precio Bioetanol'] as String?),
      esterMetilico: _parsePrecio(json['Precio Éster metílico'] as String?),
      hidrogeno: _parsePrecio(json['Precio Hidrogeno'] as String?),
    );
  }

  // 📍 Getter para usar en Google Maps
  LatLng get position => LatLng(lat, lng);
}