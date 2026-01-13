// ═══════════════════════════════════════════════════════════════════════════
// 🔧 CONFIGURACIÓN IMPORTANTE - SWITCH WEB/APK
// ═══════════════════════════════════════════════════════════════════════════
//
// Este archivo controla si la aplicación se ejecuta en modo WEB o APK.
//
// ⚠️ IMPORTANTE: Cambia el valor de 'modoPlataforma' según donde quieras ejecutar:
//
//    📱 Para APK/Android/iOS/Desktop:  modoPlataforma = 1
//    🌐 Para Web (Chrome/Firefox):     modoPlataforma = 0
//
// ═══════════════════════════════════════════════════════════════════════════

/// Configuración de plataforma
///
/// 🌐 0 = WEB (usa IndexedDB, sin SQLite nativo)
/// 📱 1 = APK (usa SQLite nativo con Drift)
const int modoPlataforma = 1;

/// Verifica si estamos en modo APK
bool get esAPK => modoPlataforma == 1;

/// Verifica si estamos en modo Web
bool get esWeb => modoPlataforma == 0;

// ═══════════════════════════════════════════════════════════════════════════
// 📝 NOTAS ADICIONALES
// ═══════════════════════════════════════════════════════════════════════════
//
// - Después de cambiar el valor, ejecuta: flutter run
// - Para Web: flutter run -d chrome
// - Para APK: flutter build apk --debug
// - Para Desktop: flutter run -d windows
//
// ═══════════════════════════════════════════════════════════════════════════
