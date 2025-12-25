import 'package:my_gasolinera/bbdd_intermedia/ParaApk/baseDatosApk.dart';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';
import 'package:my_gasolinera/principal/gasolineras/api_gasolinera.dart' as api;
import 'package:my_gasolinera/services/provincia_service.dart';
import 'package:drift/drift.dart' as drift;

/// Servicio de cache para gasolineras con estrategia offline-first
class GasolinerasCacheService {
  final AppDatabase _db;

  /// Tiempo máximo de frescura del cache en minutos
  /// Reducido a 10 minutos para actualizaciones más frecuentes
  static const int cacheFreshnessMinutes = 10;

  GasolinerasCacheService(this._db);

  /// Obtiene gasolineras con estrategia offline-first
  /// 1. Intenta cargar desde cache si está fresco
  /// 2. Si no hay cache o está obsoleto, carga desde API
  /// 3. Si falla la API, usa cache antiguo como fallback
  Future<List<Gasolinera>> getGasolineras(String provinciaId,
      {bool forceRefresh = false}) async {
    try {
      // 1. Verificar frescura del cache
      final isFresh = await _db.isCacheFresh(provinciaId,
          maxMinutes: cacheFreshnessMinutes);

      if (!forceRefresh && isFresh) {
        print(
            'GasolinerasCacheService: Usando cache fresco para provincia $provinciaId');
        return await _loadFromCache(provinciaId);
      }

      // 2. Cache obsoleto o no existe, cargar desde API
      print(
          'GasolinerasCacheService: Cache obsoleto o no existe, cargando desde API...');
      final gasolineras = await api.fetchGasolinerasByProvincia(provinciaId);

      if (gasolineras.isNotEmpty) {
        // Guardar en cache
        await _saveToCache(provinciaId, gasolineras);
        return gasolineras;
      }

      // 3. API no devolvió datos, intentar usar cache antiguo
      print(
          'GasolinerasCacheService: API sin datos, intentando cache antiguo...');
      return await _loadFromCache(provinciaId);
    } catch (e) {
      print('GasolinerasCacheService: Error al obtener gasolineras: $e');
      // Fallback a cache en caso de error
      return await _loadFromCache(provinciaId);
    }
  }

  /// Obtiene gasolineras de múltiples provincias (para zonas fronterizas)
  Future<List<Gasolinera>> getGasolinerasMultiProvincia(
      List<String> provinciaIds,
      {bool forceRefresh = false}) async {
    final List<Gasolinera> allGasolineras = [];

    for (final provinciaId in provinciaIds) {
      final gasolineras =
          await getGasolineras(provinciaId, forceRefresh: forceRefresh);
      allGasolineras.addAll(gasolineras);
    }

    return allGasolineras;
  }

  /// Carga gasolineras desde cache local
  Future<List<Gasolinera>> _loadFromCache(String provinciaId) async {
    final cachedData = await _db.getGasolinerasByProvincia(provinciaId);

    if (cachedData.isEmpty) {
      print('GasolinerasCacheService: No hay datos en cache para $provinciaId');
      return [];
    }

    print(
        'GasolinerasCacheService: Cargadas ${cachedData.length} gasolineras desde cache');

    return cachedData.map((data) {
      return Gasolinera(
        id: data.id,
        rotulo: data.rotulo,
        direccion: data.direccion,
        lat: data.lat,
        lng: data.lng,
        horario: data.horario,
        gasolina95: data.gasolina95,
        gasolina95E10: data.gasolina95E10,
        gasolina98: data.gasolina98,
        gasoleoA: data.gasoleoA,
        gasoleoPremium: data.gasoleoPremium,
        glp: data.glp,
        biodiesel: data.biodiesel,
        bioetanol: data.bioetanol,
        esterMetilico: data.esterMetilico,
        hidrogeno: data.hidrogeno,
        provincia: data.provincia,
        idProvincia: data.idProvincia,
      );
    }).toList();
  }

  /// Guarda gasolineras en cache local
  Future<void> _saveToCache(
      String provinciaId, List<Gasolinera> gasolineras) async {
    print(
        'GasolinerasCacheService: Guardando ${gasolineras.length} gasolineras en cache...');

    // Eliminar datos antiguos de esta provincia
    await _db.deleteGasolinerasByProvincia(provinciaId);

    // Insertar nuevos datos
    final companions = gasolineras.map((g) {
      return GasolinerasTableCompanion(
        id: drift.Value(g.id),
        rotulo: drift.Value(g.rotulo),
        direccion: drift.Value(g.direccion),
        lat: drift.Value(g.lat),
        lng: drift.Value(g.lng),
        provincia: drift.Value(g.provincia),
        idProvincia: drift.Value(g.idProvincia),
        horario: drift.Value(g.horario),
        gasolina95: drift.Value(g.gasolina95),
        gasolina95E10: drift.Value(g.gasolina95E10),
        gasolina98: drift.Value(g.gasolina98),
        gasoleoA: drift.Value(g.gasoleoA),
        gasoleoPremium: drift.Value(g.gasoleoPremium),
        glp: drift.Value(g.glp),
        biodiesel: drift.Value(g.biodiesel),
        bioetanol: drift.Value(g.bioetanol),
        esterMetilico: drift.Value(g.esterMetilico),
        hidrogeno: drift.Value(g.hidrogeno),
        lastUpdated: drift.Value(DateTime.now()),
      );
    }).toList();

    await _db.upsertGasolineras(companions);

    // Actualizar metadata de provincia
    final provinciaNombre =
        ProvinciaService.provincias[provinciaId] ?? 'Desconocida';
    await _db.updateProvinciaCache(
        provinciaId, provinciaNombre, gasolineras.length);

    print('GasolinerasCacheService: Cache actualizado exitosamente');
  }

  /// Refresca el cache en segundo plano
  Future<void> refreshCache(String provinciaId) async {
    try {
      print(
          'GasolinerasCacheService: Refrescando cache para provincia $provinciaId...');
      await getGasolineras(provinciaId, forceRefresh: true);
    } catch (e) {
      print('GasolinerasCacheService: Error al refrescar cache: $e');
    }
  }

  /// Limpia cache antiguo (> 7 días)
  Future<void> cleanOldCache() async {
    await _db.cleanOldCache();
  }

  /// Obtiene información de todas las provincias en cache
  Future<List<ProvinciaCacheTableData>> getCacheInfo() async {
    return await _db.getAllProvinciasCache();
  }
}
