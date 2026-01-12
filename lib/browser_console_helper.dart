// Selección condicional de la implementación
// Si estamos en web (dart.library.html disponible), usa la versión web
// Si no, usa la versión stub (vacía)
import 'browser_console_helper_stub.dart'
    if (dart.library.html) 'browser_console_helper_web.dart' as impl;

/// Inicializa los listeners de mensajes para la consola del navegador
void setupBrowserConsoleListeners() {
  impl.setupBrowserConsoleListeners();
}
