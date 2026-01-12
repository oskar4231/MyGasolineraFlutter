import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:my_gasolinera/bbdd_intermedia/ParaApk/tablaGasolineras.dart';
import 'package:my_gasolinera/bbdd_intermedia/ParaApk/tablaCacheProvincias.dart';
import 'package:my_gasolinera/bbdd_intermedia/ParaApk/tablaLocalImages.dart';
import 'package:my_gasolinera/bbdd_intermedia/ParaApk/tablaTheme.dart';

part 'baseDatosApk.g.dart';

/// Base de datos local para cache de gasolineras (VERSIÓN APK)
/// Usa SQLite nativo con drift_flutter
@DriftDatabase(tables: [
  GasolinerasTable,
  ProvinciaCacheTable,
  ThemeTable,
  LocalImagesTable
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // Incremented for new table schema (BLOB)

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Schema v1 -> v2 (Initial creation of tables including LocalImagesTable)
          // But since v2 was flawed, we just treat everything < 3 as needing update
        }

        if (from < 3) {
          // Re-create the LocalImagesTable to handle the new BLOB column
          // We drop it if it exists (from v2) and recreate it
          await m.deleteTable(localImagesTable.actualTableName);
          await m.createTable(localImagesTable);
        }
      },
    );
  }

  /// Abre la conexión a la base de datos SQLite nativa
  static QueryExecutor _openConnection() {
    print('📱 INICIANDO BASE DE DATOS APK (NATIVA)');
    return driftDatabase(name: 'gasolinera_cache_db');
  }

  // ==================== GASOLINERAS ====================

  /// Obtiene todas las gasolineras de una provincia
  Future<List<GasolinerasTableData>> getGasolinerasByProvincia(
      String provinciaId) async {
    return (select(gasolinerasTable)
          ..where((tbl) => tbl.idProvincia.equals(provinciaId)))
        .get();
  }

  /// Obtiene gasolineras de múltiples provincias
  Future<List<GasolinerasTableData>> getGasolinerasByProvincias(
      List<String> provinciaIds) async {
    return (select(gasolinerasTable)
          ..where((tbl) => tbl.idProvincia.isIn(provinciaIds)))
        .get();
  }

  /// Inserta o actualiza una gasolinera
  Future<void> upsertGasolinera(GasolinerasTableCompanion gasolinera) async {
    await into(gasolinerasTable).insertOnConflictUpdate(gasolinera);
  }

  /// Inserta o actualiza múltiples gasolineras
  Future<void> upsertGasolineras(
      List<GasolinerasTableCompanion> gasolineras) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(gasolinerasTable, gasolineras);
    });
  }

  /// Elimina gasolineras de una provincia
  Future<int> deleteGasolinerasByProvincia(String provinciaId) async {
    return (delete(gasolinerasTable)
          ..where((tbl) => tbl.idProvincia.equals(provinciaId)))
        .go();
  }

  /// Cuenta gasolineras por provincia
  Future<int> countGasolinerasByProvincia(String provinciaId) async {
    final query = selectOnly(gasolinerasTable)
      ..addColumns([gasolinerasTable.id.count()])
      ..where(gasolinerasTable.idProvincia.equals(provinciaId));

    final result = await query.getSingle();
    return result.read(gasolinerasTable.id.count()) ?? 0;
  }

  // ==================== PROVINCIA CACHE ====================

  /// Obtiene información de cache de una provincia
  Future<ProvinciaCacheTableData?> getProvinciaCache(String provinciaId) async {
    return (select(provinciaCacheTable)
          ..where((tbl) => tbl.provinciaId.equals(provinciaId)))
        .getSingleOrNull();
  }

  /// Actualiza información de cache de provincia
  Future<void> updateProvinciaCache(
      String provinciaId, String provinciaNombre, int recordCount) async {
    await into(provinciaCacheTable).insertOnConflictUpdate(
      ProvinciaCacheTableCompanion(
        provinciaId: Value(provinciaId),
        provinciaNombre: Value(provinciaNombre),
        lastUpdated: Value(DateTime.now()),
        recordCount: Value(recordCount),
      ),
    );
  }

  /// Verifica si el cache de una provincia está fresco (< 20 minutos)
  Future<bool> isCacheFresh(String provinciaId, {int maxMinutes = 20}) async {
    final cache = await getProvinciaCache(provinciaId);
    if (cache == null) return false;

    final now = DateTime.now();
    final difference = now.difference(cache.lastUpdated);
    return difference.inMinutes < maxMinutes;
  }

  /// Obtiene todas las provincias en cache
  Future<List<ProvinciaCacheTableData>> getAllProvinciasCache() async {
    return select(provinciaCacheTable).get();
  }

  /// Limpia cache antiguo (> 7 días)
  Future<void> cleanOldCache({int maxDays = 7}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: maxDays));

    // Obtener provincias antiguas
    final oldProvincias = await (select(provinciaCacheTable)
          ..where((tbl) => tbl.lastUpdated.isSmallerThanValue(cutoffDate)))
        .get();

    // Eliminar gasolineras de esas provincias
    for (final provincia in oldProvincias) {
      await deleteGasolinerasByProvincia(provincia.provinciaId);
    }

    // Eliminar registros de provincia cache
    await (delete(provinciaCacheTable)
          ..where((tbl) => tbl.lastUpdated.isSmallerThanValue(cutoffDate)))
        .go();
  }

  /// Borra TODO el caché de gasolineras (útil para forzar recarga completa)
  Future<void> clearAllCache() async {
    print('APK: 🗑️ Borrando TODO el caché de gasolineras...');

    // Eliminar todas las gasolineras
    await delete(gasolinerasTable).go();

    // Eliminar todos los registros de provincia cache
    await delete(provinciaCacheTable).go();

    print('✅ Caché completamente borrado');
  }

  // ==================== TEMA ====================

  /// Obtiene el ID del tema guardado
  Future<int> getThemeId() async {
    final query = selectOnly(themeTable)..addColumns([themeTable.themeId]);
    final result = await query.getSingleOrNull();
    return result?.read(themeTable.themeId) ?? 0;
  }

  /// Guarda el ID del tema
  Future<void> saveThemeId(int id) async {
    // Borramos cualquier configuración anterior (solo queremos una fila)
    await delete(themeTable).go();

    // Insertamos la nueva
    await into(themeTable).insert(
      ThemeTableCompanion(
        themeId: Value(id),
      ),
    );
  }

  // ==================== IMÁGENES LOCALES ====================

  Future<int> insertLocalImage(LocalImagesTableCompanion image) {
    return into(localImagesTable).insert(image);
  }

  Future<LocalImagesTableData?> getLocalImage(String type, String relatedId) {
    return (select(localImagesTable)
          ..where(
              (t) => t.imageType.equals(type) & t.relatedId.equals(relatedId)))
        .getSingleOrNull();
  }
}
