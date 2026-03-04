// Conditional import: web usa stub (sin Isar), nativo usa implementacion real.
export 'gasolinera_cache_service_web.dart'
    if (dart.library.io) 'gasolinera_cache_service_native.dart';
