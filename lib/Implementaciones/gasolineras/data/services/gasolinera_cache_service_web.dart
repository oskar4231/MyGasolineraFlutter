import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/api_gasolinera.dart'
    as api;
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementación de GasolinerasCacheService para Web.
/// En web no hay Isar, así que los datos se obtienen directamente desde la API.
class GasolinerasCacheService {
  GasolinerasCacheService(dynamic isarService);

  Future<List<Gasolinera>> getGasolineras(String provinciaId) async {
    AppLogger.info(
        'Web: cargando gasolineras desde API para provincia $provinciaId',
        tag: 'GasolinerasCacheService');
    return api.fetchGasolinerasByProvincia(provinciaId);
  }

  Future<List<Gasolinera>> getGasolinerasMultiProvincia(
      List<String> provinciaIds) async {
    final List<Gasolinera> todas = [];
    for (final id in provinciaIds) {
      final gasolineras = await getGasolineras(id);
      todas.addAll(gasolineras);
    }
    return todas;
  }

  /// En web, busca favoritos usando el mapa id→provincia guardado en SharedPreferences
  Future<List<Gasolinera>> getGasolinerasByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final prefs = await SharedPreferences.getInstance();
      // Leer el mapa id→provincia guardado por toggleFavorito
      final provinciaEntries =
          prefs.getStringList('favoritas_provincias') ?? [];
      final Map<String, String> provinciaMap = Map.fromEntries(
        provinciaEntries.map((e) {
          final parts = e.split('|');
          return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
        }),
      );

      // Agrupar IDs por provincia
      final Map<String, List<String>> idsPorProvincia = {};

      for (final id in ids) {
        final prov = provinciaMap[id];
        if (prov != null && prov.isNotEmpty) {
          idsPorProvincia.putIfAbsent(prov, () => []).add(id);
        }
      }

      if (idsPorProvincia.isEmpty) {
        AppLogger.warning(
            'Web: favoritos sin provincia guardada, no se puede cargar desde API',
            tag: 'GasolinerasCacheService');
        return [];
      }

      // Buscar en la API por cada provincia y filtrar por ID
      final List<Gasolinera> resultado = [];
      for (final entry in idsPorProvincia.entries) {
        final gasolineras = await api.fetchGasolinerasByProvincia(entry.key);
        final filtradas =
            gasolineras.where((g) => entry.value.contains(g.id)).toList();
        resultado.addAll(filtradas);
      }

      AppLogger.info('Web: cargados ${resultado.length} favoritos desde API',
          tag: 'GasolinerasCacheService');
      return resultado;
    } catch (e) {
      AppLogger.error('Web: error cargando favoritos desde API',
          tag: 'GasolinerasCacheService', error: e);
      return [];
    }
  }

  Future<List<Gasolinera>> getGasolinerasByBounds({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
  }) async {
    return api.fetchGasolinerasByBounds(
      swLat: swLat,
      swLng: swLng,
      neLat: neLat,
      neLng: neLng,
    );
  }
}
