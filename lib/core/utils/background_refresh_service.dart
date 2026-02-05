import 'dart:async';
import 'package:my_gasolinera/core/database/bbdd_intermedia/base_datos.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/provincia_service.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Servicio para actualizar el cache de gasolineras en segundo plano
class BackgroundRefreshService {
  final GasolinerasCacheService _cacheService;

  Timer? _refreshTimer;

  /// Intervalo de actualización en minutos (15-20 minutos)
  static const int refreshIntervalMinutes = 18;

  BackgroundRefreshService(AppDatabase db)
      : _cacheService = GasolinerasCacheService(db);

  /// Inicia el servicio de actualización en segundo plano
  void start() {
    AppLogger.info(
        'Iniciando actualización cada $refreshIntervalMinutes minutos',
        tag: 'BackgroundRefresh');

    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(minutes: refreshIntervalMinutes),
      (timer) => _performRefresh(),
    );
  }

  /// Detiene el servicio de actualización
  void stop() {
    AppLogger.info('Deteniendo actualización', tag: 'BackgroundRefresh');
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Realiza la actualización del cache
  Future<void> _performRefresh() async {
    try {
      AppLogger.info('Iniciando actualización de cache...',
          tag: 'BackgroundRefresh');

      // Obtener última provincia conocida
      final provinciaInfo = await ProvinciaService.getLastKnownProvincia();

      if (provinciaInfo == null) {
        AppLogger.info('No hay provincia conocida, saltando actualización',
            tag: 'BackgroundRefresh');
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

      AppLogger.info('Actualización completada exitosamente',
          tag: 'BackgroundRefresh');
    } catch (e) {
      AppLogger.error('Error durante actualización',
          tag: 'BackgroundRefresh', error: e);
    }
  }

  /// Fuerza una actualización inmediata
  Future<void> forceRefresh() async {
    await _performRefresh();
  }
}
