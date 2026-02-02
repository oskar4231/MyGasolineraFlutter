import 'dart:convert';
import 'package:flutter/services.dart';

class CarDataService {
  List<dynamic> _marcas = [];
  List<dynamic> _modelos = [];
  List<dynamic> _motorizaciones = [];

  // Singleton pattern for easy access
  static final CarDataService _instance = CarDataService._internal();

  factory CarDataService() {
    return _instance;
  }

  CarDataService._internal();

  Future<void> loadData() async {
    try {
      final String marcasString =
          await rootBundle.loadString('assets/data/marcas.json');
      _marcas = json.decode(marcasString);

      final String modelosString =
          await rootBundle.loadString('assets/data/modelos.json');
      _modelos = json.decode(modelosString);

      final String motorizacionesString =
          await rootBundle.loadString('assets/data/motorizaciones.json');
      _motorizaciones = json.decode(motorizacionesString);

      print(
          'Datos de coches cargados: ${_marcas.length} marcas, ${_modelos.length} modelos, ${_motorizaciones.length} motorizaciones');
    } catch (e) {
      print('Error cargando datos de coches: $e');
      // Initialize with empty lists to avoid null errors
      _marcas = [];
      _modelos = [];
      _motorizaciones = [];
    }
  }

  List<dynamic> getMarcas() {
    // Sort alphabetically
    final List<dynamic> sorted = List.from(_marcas);
    sorted.sort(
        (a, b) => (a['nombre'] as String).compareTo(b['nombre'] as String));
    return sorted;
  }

  List<dynamic> getModelos(int marcaId) {
    // Filter by marca_id and sort alphabetically
    final filtered = _modelos.where((m) => m['marca_id'] == marcaId).toList();
    filtered.sort(
        (a, b) => (a['nombre'] as String).compareTo(b['nombre'] as String));
    return filtered;
  }

  List<dynamic> getMotorizaciones(int modeloId) {
    // Filter by modelo_id
    // Usually sorted by power or name, keeping default order is often fine or sort by name
    return _motorizaciones.where((m) => m['modelo_id'] == modeloId).toList();
  }
}
