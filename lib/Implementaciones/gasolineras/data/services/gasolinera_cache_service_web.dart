import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Stub de GasolinerasCacheService para Web.
/// En web no hay Isar, así que simplemente devuelve listas vacías.
/// Los datos se obtienen directamente desde la API en el mapa.
class GasolinerasCacheService {
  GasolinerasCacheService(dynamic isarService);

  Future<List<Gasolinera>> getGasolineras(String provinciaId) async {
    AppLogger.info('Web: sin cache local, usa API directamente',
        tag: 'GasolinerasCacheService');
    return [];
  }

  Future<List<Gasolinera>> getGasolinerasMultiProvincia(
      List<String> provinciaIds) async {
    return [];
  }

  Future<List<Gasolinera>> getGasolinerasByIds(List<String> ids) async {
    return [];
  }

  Future<List<Gasolinera>> getGasolinerasByBounds({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
  }) async {
    return [];
  }
}
