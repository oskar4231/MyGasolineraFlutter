import 'dart:async';
import 'package:isar/isar.dart';
import 'package:my_gasolinera/core/database/isar_service_native.dart';
import 'package:my_gasolinera/core/security/auth_storage.dart';
import 'package:my_gasolinera/core/database/isar_models/user_local.dart';
import 'package:my_gasolinera/core/database/isar_models/gasolinera_local.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/api_gasolinera.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncManager {
  final IsarService _isarService;

  static const int _gasolineraSyncCooldownMs = 15 * 60 * 1000;

  SyncManager({required IsarService isarService}) : _isarService = isarService;

  Future<void> startBackgroundSync() async {
    final isLoggedIn = await AuthStorage.isLoggedIn();
    if (!isLoggedIn) return;

    await _syncUserData();
    await _syncGasStationsData();
  }

  Future<void> _syncUserData() async {
    try {
      final token = await AuthStorage.getToken();
      final userId = await AuthStorage.getUserId();
      if (token == null || userId == null) return;

      final isar = await _isarService.db;

      final fetchedUser = UserLocal()
        ..remoteId = int.tryParse(userId) ?? 1
        ..email = await AuthStorage.getEmail() ?? 'user@example.com'
        ..name = 'Mock User'
        ..lastSync = DateTime.now();

      await isar.writeTxn(() async {
        await isar.userLocals.put(fetchedUser);
      });
    } catch (e) {
      AppLogger.error('Error syncing user data', tag: 'SyncManager', error: e);
    }
  }

  Future<void> _syncGasStationsData() async {
    try {
      final isar = await _isarService.db;
      final lastSyncTime = await _getLastGasolineraSyncTime(isar);
      final now = DateTime.now().millisecondsSinceEpoch;

      if (lastSyncTime == null ||
          (now - lastSyncTime) > _gasolineraSyncCooldownMs) {
        final nuevasGasolineras = await fetchGasolinerasByProvincia('28');

        final locales = nuevasGasolineras.map((g) {
          return GasolineraLocal()
            ..remoteId = g.id
            ..rotulo = g.rotulo
            ..direccion = g.direccion
            ..lat = g.lat
            ..lng = g.lng
            ..horario = g.horario
            ..provincia = g.provincia
            ..idProvincia = g.idProvincia
            ..gasolina95 = g.gasolina95
            ..gasolina95E10 = g.gasolina95E10
            ..gasolina98 = g.gasolina98
            ..gasoleoA = g.gasoleoA
            ..gasoleoPremium = g.gasoleoPremium
            ..glp = g.glp
            ..biodiesel = g.biodiesel
            ..bioetanol = g.bioetanol
            ..esterMetilico = g.esterMetilico
            ..hidrogeno = g.hidrogeno;
        }).toList();

        await isar.writeTxn(() async {
          await isar.gasolineraLocals.clear();
          await isar.gasolineraLocals.putAll(locales);
        });

        await _saveGasolineraSyncTime(isar, now);
        AppLogger.info('Gasolineras synced successfully from API.',
            tag: 'SyncManager');
      } else {
        AppLogger.info(
            'Skipping Gas Station sync. Using cached data (15m cooldown).',
            tag: 'SyncManager');
      }
    } catch (e) {
      AppLogger.error('Error syncing gas stations data',
          tag: 'SyncManager', error: e);
    }
  }

  static const String _syncKey = 'last_gasolinera_sync_time';

  Future<int?> _getLastGasolineraSyncTime(Isar isar) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_syncKey);
  }

  Future<void> _saveGasolineraSyncTime(Isar isar, int timeMs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_syncKey, timeMs);
  }
}
