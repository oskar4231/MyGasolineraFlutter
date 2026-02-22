import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:my_gasolinera/core/database/bbdd_intermedia/base_datos.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/provincia_service.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Servicio para actualizar el cache de gasolineras en segundo plano
class BackgroundRefreshService {
  final GasolinerasCacheService _cacheService;

  Timer? _refreshTimer;
  bool _isPaused = false;

  /// ✅ OPTIMIZACIÓN: Intervalo aumentado de 10-15 min a 20 min
  /// Reduce uso de CPU/batería sin afectar UX
  static const int refreshIntervalMinutes = 20;

  BackgroundRefreshService(AppDatabase db)
      : _cacheService = GasolinerasCacheService(db);

  /// Inicia el servicio de actualización en segundo plano
  void start() {
    AppLogger.info(
        'Iniciando actualización cada $refreshIntervalMinutes minutos',
        tag: 'BackgroundRefresh');

    _refreshTimer?.cancel();
    _isPaused = false;
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
    _isPaused = false;
  }

  /// ✅ OPTIMIZACIÓN: Pausar actualizaciones cuando app está en background
  void pause() {
    AppLogger.info('Pausando actualizaciones (app en background)',
        tag: 'BackgroundRefresh');
    _isPaused = true;
  }

  /// ✅ OPTIMIZACIÓN: Reanudar actualizaciones cuando app vuelve a foreground
  void resume() {
    AppLogger.info('Reanudando actualizaciones (app en foreground)',
        tag: 'BackgroundRefresh');
    _isPaused = false;
    // Actualizar inmediatamente al volver
    _performRefresh();
  }

  /// Realiza la actualización del cache
  Future<void> _performRefresh() async {
    // ✅ OPTIMIZACIÓN: No actualizar si la app está en background
    if (_isPaused) {
      AppLogger.info('Actualización omitida (app pausada)',
          tag: 'BackgroundRefresh');
      return;
    }

    // ✅ OPTIMIZACIÓN: Verificar estado del ciclo de vida
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    if (lifecycleState != null && lifecycleState != AppLifecycleState.resumed) {
      AppLogger.info('Actualización omitida (app no está activa)',
          tag: 'BackgroundRefresh');
      return;
    }

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
