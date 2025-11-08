// gasolinera.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Gasolinera {
  final String id;
  final String rotulo;
  final String direccion;
  final double lat;
  final double lng;
  final double precioGasolina95;
  final double precioGasoleoA;

  Gasolinera({
    required this.id,
    required this.rotulo,
    required this.direccion,
    required this.lat,
    required this.lng,
    required this.precioGasolina95,
    required this.precioGasoleoA,
  });

  // Función auxiliar para convertir String con coma a double
  static double _parsePrecio(String? precioStr) {
    if (precioStr == null || precioStr.isEmpty) return 0.0;
    // La API usa ',' como separador decimal.
    final cleanStr = precioStr.replaceAll(',', '.');
    return double.tryParse(cleanStr) ?? 0.0;
  }

  // Constructor de fábrica para crear una Gasolinera a partir de un JSON
  factory Gasolinera.fromJson(Map<String, dynamic> json) {
    // 💡 La API del Gobierno usa estos nombres de campo exactos, incluyendo tildes y mayúsculas.
    return Gasolinera(
      id: json['IDEESS'].toString(),
      rotulo: json['Rótulo'] ?? 'Sin Rótulo',
      direccion: '${json['Dirección'] ?? ''}, ${json['Municipio'] ?? ''}',
      // Las coordenadas también vienen como String con coma, pero la API las nombra así:
      lat: _parsePrecio(json['Latitud'] as String?),
      lng: _parsePrecio(json['Longitud (WGS84)'] as String?),
      
      // Precios comunes
      precioGasolina95: _parsePrecio(json['Precio Gasolina 95 E5'] as String?),
      precioGasoleoA: _parsePrecio(json['Precio Gasóleo A'] as String?),
    );
  }

  // Getter de conveniencia para las coordenadas
  LatLng get position => LatLng(lat, lng);
}