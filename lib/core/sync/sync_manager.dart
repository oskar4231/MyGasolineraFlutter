// Conditional import: web usa stub (sin Isar), nativo usa implementacion real.
export 'sync_manager_web.dart'
    if (dart.library.io) 'sync_manager_native.dart';
