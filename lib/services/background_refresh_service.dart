import 'dart:async';
import 'package:my_gasolinera/bbdd_intermedia/ParaApk/baseDatosApk.dart';
import 'package:my_gasolinera/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/services/provincia_service.dart';

/// Servicio para actualizar el cache de gasolineras en segundo plano
class BackgroundRefreshService {
  final AppDatabase _db;
  final GasolinerasCacheService _cacheService;

  Timer? _refreshTimer;

  /// Intervalo de actualización en minutos (15-20 minutos)
  static const int refreshIntervalMinutes = 18;

  BackgroundRefreshService(this._db)
      : _cacheService = GasolinerasCacheService(_db);

  /// Inicia el servicio de actualización en segundo plano
  void start() {
    print(
        'BackgroundRefreshService: Iniciando actualización cada $refreshIntervalMinutes minutos');

    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(minutes: refreshIntervalMinutes),
      (timer) => _performRefresh(),
    );
  }

  /// Detiene el servicio de actualización
  void stop() {
    print('BackgroundRefreshService: Deteniendo actualización');
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Realiza la actualización del cache
  Future<void> _performRefresh() async {
    try {
      print('BackgroundRefreshService: Iniciando actualización de cache...');

      // Obtener última provincia conocida
      final provinciaInfo = await ProvinciaService.getLastKnownProvincia();

      if (provinciaInfo == null) {
        print(
            'BackgroundRefreshService: No hay provincia conocida, saltando actualización');
        return;
      }

      // Actualizar provincia actual
      await _cacheService.refreshCache(provinciaInfo.id);

      // Actualizar provincias vecinas (para viajes)
      final vecinas = ProvinciaService.getProvinciasVecinas(provinciaInfo.id);
      for (final vecinaId in vecinas.take(2)) {
        // Solo las 2 más cercanas
        await _cacheService.refreshCache(vecinaId);
      }

      // Limpiar cache antiguo
      await _cacheService.cleanOldCache();

      print('BackgroundRefreshService: Actualización completada exitosamente');
    } catch (e) {
      print('BackgroundRefreshService: Error durante actualización: $e');
    }
  }

  /// Fuerza una actualización inmediata
  Future<void> forceRefresh() async {
    await _performRefresh();
  }
}
