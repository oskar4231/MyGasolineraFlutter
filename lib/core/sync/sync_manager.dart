import 'dart:async';
import 'package:isar/isar.dart';
import 'package:my_gasolinera/core/database/isar_service.dart';
import 'package:my_gasolinera/core/security/auth_storage.dart';
import 'package:my_gasolinera/core/database/isar_models/user_local.dart';
import 'package:my_gasolinera/core/database/isar_models/gasolinera_local.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/api_gasolinera.dart';

class SyncManager {
  final IsarService _isarService;

  // 15 minutes cooldown for gas stations (in milliseconds)
  static const int _gasolineraSyncCooldownMs = 15 * 60 * 1000;

  SyncManager({
    required IsarService isarService,
  }) : _isarService = isarService;

  /// Starts the silent synchronization process in the background.
  /// Typically called exactly once after a successful login or app startup
  /// if already logged in.
  Future<void> startBackgroundSync() async {
    // 1. Check if user is logged in
    final isLoggedIn = await AuthStorage.isLoggedIn();
    if (!isLoggedIn) return; // Do not sync if no active session

    // 2. Fetch User Data (Cars, Invoices, Profile) from MariaDB backend
    await _syncUserData();

    // 3. Fetch Public Gas Stations Data
    await _syncGasStationsData();
  }

  Future<void> _syncUserData() async {
    try {
      final token = await AuthStorage.getToken();
      final userId = await AuthStorage.getUserId();

      if (token == null || userId == null) return;

      final isar = await _isarService.db;

      // MOCK DATA FOR NOW: We assume we got this from the backend
      final fetchedUser = UserLocal()
        ..remoteId = int.tryParse(userId) ?? 1
        ..email = await AuthStorage.getEmail() ?? 'user@example.com'
        ..name = 'Mock User'
        ..lastSync = DateTime.now();

      // Save user to Isar (this will automatically replace the old one due to @Index replace: true)
      await isar.writeTxn(() async {
        await isar.userLocals.put(fetchedUser);

        // e.g. await isar.carLocals.putAll(mappedCars);
      });
    } catch (e) {
      AppLogger.error('Error syncing user data', tag: 'SyncManager', error: e);
    }
  }

  Future<void> _syncGasStationsData() async {
    try {
      final isar = await _isarService.db;

      // Check when we last synced gas stations
      final lastSyncTime = await _getLastGasolineraSyncTime(isar);
      final now = DateTime.now().millisecondsSinceEpoch;

      // Only fetch from API if we haven't synced in the last 15 minutes
      if (lastSyncTime == null ||
          (now - lastSyncTime) > _gasolineraSyncCooldownMs) {
        // Fetch from API (Madrid como ejemplo; ajusta la provincia según necesidad)
        final nuevasGasolineras = await fetchGasolinerasByProvincia('28');

        // Map API Models to Isar Models
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

        // Clear and save to Isar
        await isar.writeTxn(() async {
          await isar.gasolineraLocals.clear();
          await isar.gasolineraLocals.putAll(locales);
        });

        // Save the current timestamp as the last sync time
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

  // --- Utility functions for storing sync timestamps in Isar ---
  // In a real app we might create a specific Isar collection "SyncMetadata" just for this,
  // but for simplicity we can use standard SharedPreferences or just a dummy User field.
  // Here we'll simulate it, but you should probably use SharedPreferences or a tiny config table.

  // For demonstration, these will just be simple placeholders.
  // Recommend adding a Config table to Isar for key/value pairs like this.
  Future<int?> _getLastGasolineraSyncTime(Isar isar) async {
    // Replace with real config lookup
    return null;
  }

  Future<void> _saveGasolineraSyncTime(Isar isar, int timeMs) async {
    // Replace with real config save
  }
}
