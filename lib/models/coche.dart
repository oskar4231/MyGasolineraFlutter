class Coche {
  final int? idCoche;
  final String marca;
  final String modelo;
  final List<String> tiposCombustible;
  final int? kilometrajeInicial;
  final double? capacidadTanque;
  final double? consumoTeorico;
  final String? fechaUltimoCambioAceite;
  final int? kmUltimoCambioAceite;
  final int intervaloCambioAceiteKm;
  final int intervaloCambioAceiteMeses;

  Coche({
    this.idCoche,
    required this.marca,
    required this.modelo,
    required this.tiposCombustible,
    this.kilometrajeInicial,
    this.capacidadTanque,
    this.consumoTeorico,
    this.fechaUltimoCambioAceite,
    this.kmUltimoCambioAceite,
    this.intervaloCambioAceiteKm = 15000,
    this.intervaloCambioAceiteMeses = 12,
  });

  // Factory para crear un Coche desde JSON del backend
  factory Coche.fromJson(Map<String, dynamic> json) {
    List<String> combustibles = [];
    if (json['combustible'] != null) {
      combustibles = json['combustible']
          .toString()
          .split(', ')
          .map((e) => e.trim())
          .toList();
    }

    return Coche(
      idCoche: json['id_coche'],
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      tiposCombustible: combustibles,
      kilometrajeInicial: json['kilometraje_inicial'] != null
          ? int.tryParse(json['kilometraje_inicial'].toString())
          : null,
      capacidadTanque: json['capacidad_tanque'] != null
          ? double.tryParse(json['capacidad_tanque'].toString())
          : null,
      consumoTeorico: json['consumo_teorico'] != null
          ? double.tryParse(json['consumo_teorico'].toString())
          : null,
      fechaUltimoCambioAceite: json['fecha_ultimo_cambio_aceite'],
      kmUltimoCambioAceite: json['km_ultimo_cambio_aceite'] != null
          ? int.tryParse(json['km_ultimo_cambio_aceite'].toString())
          : null,
      intervaloCambioAceiteKm: json['intervalo_cambio_aceite_km'] != null
          ? int.tryParse(json['intervalo_cambio_aceite_km'].toString()) ?? 15000
          : 15000,
      intervaloCambioAceiteMeses: json['intervalo_cambio_aceite_meses'] != null
          ? int.tryParse(json['intervalo_cambio_aceite_meses'].toString()) ?? 12
          : 12,
    );
  }
}
