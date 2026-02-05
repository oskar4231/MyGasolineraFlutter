// Exportación condicional de la base de datos según la plataforma
//
// Si es web (dart.library.html), usa la implementación Web (IndexedDB)
// Si es nativo (por defecto), usa la implementación APK (SQLite/Drift nativo)

export 'package:my_gasolinera/core/database/bbdd_intermedia/ParaApk/base_datos_apk.dart'
    if (dart.library.html) 'package:my_gasolinera/core/database/bbdd_intermedia/ParaWeb/base_datos_web.dart';
