/// Stub de SyncManager para Web.
/// En web no hay Isar, así que la sincronización local no hace nada.
/// Los datos se obtienen directamente de la API en cada petición.
class SyncManager {
  SyncManager({required dynamic isarService});

  Future<void> startBackgroundSync() async {
    // No-op en web: sin cache local Isar
  }
}
