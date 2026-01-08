import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'services/config_service.dart';

/// Inicializa los listeners de mensajes para la consola del navegador
void setupBrowserConsoleListeners() {
  if (!kIsWeb) return;

  // Escuchar mensajes desde JavaScript
  html.window.onMessage.listen((event) {
    final data = event.data;

    // Verificar si es un mensaje de refresh
    if (data is Map && data['type'] == 'REFRESH_BACKEND_URL') {
      print('main.dart: Recibido comando de refresh desde consola');
      ConfigService.triggerRefreshFromConsole();
    }
  });

  print('main.dart: ✅ Listener de consola del navegador configurado');
}
