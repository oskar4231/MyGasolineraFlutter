// Conditional import: web usa el stub vacío, nativo usa la implementación real.
// Esto evita que Isar (incompatible con JS) se compile en la versión web.
export 'isar_service_web.dart' if (dart.library.io) 'isar_service_native.dart';
