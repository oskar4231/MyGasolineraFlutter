import 'package:web/web.dart' as web;
import 'package:my_gasolinera/core/config/config_service.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Inicializa los listeners de mensajes para la consola del navegador
/// Versión WEB - Usa package:web
void setupBrowserConsoleListeners() {
  // Escuchar mensajes desde JavaScript
  web.window.onMessage.listen((web.MessageEvent event) {
    if (event.data == null) return;

    // Convertir JSAny? a objeto Dart si es posible
    final data = event.data;

    // Verificar si es un mensaje de refresh
    if (_isRefreshMessage(data)) {
      AppLogger.info('Recibido comando de refresh desde consola',
          tag: 'BrowserConsole');
      ConfigService.triggerRefreshFromConsole();
    }
  });

  AppLogger.info('Listener de consola del navegador configurado',
      tag: 'BrowserConsole');
}

/// Helper para verificar el mensaje de forma segura con JS Interop
bool _isRefreshMessage(JSAny? data) {
  if (data == null || !data.isA<JSObject>()) return false;

  final jsObj = data as JSObject;
  if (jsObj.hasProperty('type'.toJS).toDart) {
    final type = jsObj.getProperty('type'.toJS);
    return type.isA<JSString>() &&
        (type as JSString).toDart == 'REFRESH_BACKEND_URL';
  }
  return false;
}
