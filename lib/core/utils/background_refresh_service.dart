import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:my_gasolinera/core/sync/sync_manager.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Servicio para actualizar datos en segundo plano
class BackgroundRefreshService {
  final SyncManager _syncManager;

  Timer? _refreshTimer;
  bool _isPaused = false;

  /// Intervalo general de revisiones en background
  static const int refreshIntervalMinutes = 20;

  BackgroundRefreshService(this._syncManager);

  /// Inicia el servicio de actualización en segundo plano
  void start() {
    AppLogger.info(
        'Iniciando servicio de sync en background cada $refreshIntervalMinutes minutos',
        tag: 'BackgroundRefresh');

    _refreshTimer?.cancel();
    _isPaused = false;
    _refreshTimer = Timer.periodic(
      const Duration(minutes: refreshIntervalMinutes),
      (timer) => _performRefresh(),
    );
  }

  /// Detiene el servicio de actualización
  void stop() {
    AppLogger.info('Deteniendo servicio de sync', tag: 'BackgroundRefresh');
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isPaused = false;
  }

  /// Pausar actualizaciones cuando app está en background
  void pause() {
    AppLogger.info('Pausando sync (app en background)',
        tag: 'BackgroundRefresh');
    _isPaused = true;
  }

  /// Reanudar actualizaciones cuando app vuelve a foreground
  void resume() {
    AppLogger.info('Reanudando sync (app en foreground)',
        tag: 'BackgroundRefresh');
    _isPaused = false;
    _performRefresh();
  }

  /// Realiza la sincronización controlada por el SyncManager
  Future<void> _performRefresh() async {
    if (_isPaused) {
      AppLogger.info('Sync omitida (app pausada)', tag: 'BackgroundRefresh');
      return;
    }

    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    if (lifecycleState != null && lifecycleState != AppLifecycleState.resumed) {
      AppLogger.info('Sync omitida (app no está activa)',
          tag: 'BackgroundRefresh');
      return;
    }

    try {
      AppLogger.info('Disparando SyncManager...', tag: 'BackgroundRefresh');
      await _syncManager.startBackgroundSync();
    } catch (e) {
      AppLogger.error('Error durante sync background',
          tag: 'BackgroundRefresh', error: e);
    }
  }

  /// Fuerza una actualización inmediata
  Future<void> forceRefresh() async {
    await _performRefresh();
  }
}
