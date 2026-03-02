import 'package:isar/isar.dart';
import 'package:my_gasolinera/core/database/isar_service.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/core/database/isar_models/gasolinera_local.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Servicio de lectura para gasolineras usando Isar local cache
class GasolinerasCacheService {
  final IsarService _isarService;

  GasolinerasCacheService(this._isarService);

  /// Obtiene gasolineras mapeadas al dominio desde la DB Isar
  Future<List<Gasolinera>> getGasolineras(String provinciaId) async {
    try {
      final isar = await _isarService.db;

      final cachedData = await isar.gasolineraLocals
          .filter()
          .idProvinciaEqualTo(provinciaId)
          .findAll();

      AppLogger.database(
          'Cargadas ${cachedData.length} gasolineras desde Isar cache para $provinciaId',
          tag: 'GasolinerasCacheService');

      return cachedData.map((data) => _mapToDomain(data)).toList();
    } catch (e) {
      AppLogger.error('Error al obtener gasolineras de Isar',
          tag: 'GasolinerasCacheService', error: e);
      return [];
    }
  }

  /// Obtiene gasolineras de múltiples provincias
  Future<List<Gasolinera>> getGasolinerasMultiProvincia(
      List<String> provinciaIds) async {
    final List<Gasolinera> allGasolineras = [];
    for (final id in provinciaIds) {
      final gasolineras = await getGasolineras(id);
      allGasolineras.addAll(gasolineras);
    }
    return allGasolineras;
  }

  /// Obtiene gasolineras por una lista de IDs específicos
  Future<List<Gasolinera>> getGasolinerasByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final isar = await _isarService.db;
      final cachedData = await isar.gasolineraLocals
          .filter()
          .anyOf(ids, (q, String id) => q.remoteIdEqualTo(id))
          .findAll();
      return cachedData.map((data) => _mapToDomain(data)).toList();
    } catch (e) {
      AppLogger.error('Error al obtener gasolineras por IDs',
          tag: 'GasolinerasCacheService', error: e);
      return [];
    }
  }

  /// Map Isar Model back to Domain Model
  Gasolinera _mapToDomain(GasolineraLocal data) {
    return Gasolinera(
      id: data.remoteId ?? '',
      rotulo: data.rotulo ?? '',
      direccion: data.direccion ?? '',
      lat: data.lat ?? 0.0,
      lng: data.lng ?? 0.0,
      horario: data.horario ?? '',
      gasolina95: data.gasolina95 ?? 0.0,
      gasolina95E10: data.gasolina95E10 ?? 0.0,
      gasolina98: data.gasolina98 ?? 0.0,
      gasoleoA: data.gasoleoA ?? 0.0,
      gasoleoPremium: data.gasoleoPremium ?? 0.0,
      glp: data.glp ?? 0.0,
      biodiesel: data.biodiesel ?? 0.0,
      bioetanol: data.bioetanol ?? 0.0,
      esterMetilico: data.esterMetilico ?? 0.0,
      hidrogeno: data.hidrogeno ?? 0.0,
      provincia: data.provincia ?? '',
      idProvincia: data.idProvincia ?? '',
    );
  }
}
