import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/core/config/api_config.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Servicio responsable de gestionar la configuración del backend.
/// Se ha movido de una actualización dinámica vía Gist a una URL fija de Ngrok.
class ConfigService {
  static const String _prefsKeyBackendUrl = 'backend_url';
  static const String _prefsKeyLastFetch = 'last_url_fetch';

  /// Callback para notificar cambios de URL (Mantenido por compatibilidad de firma)
  static Function()? onUrlChanged;

  /// Inicializa la configuración de la aplicación con la URL fija definida en ApiConfig
  static Future<void> initialize() async {
    AppLogger.info('Inicializando con URL fija: ${ApiConfig.baseUrl}',
        tag: 'ConfigService');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyBackendUrl, ApiConfig.baseUrl);
    await prefs.setInt(
        _prefsKeyLastFetch, DateTime.now().millisecondsSinceEpoch);
  }

  /// Inicia actualización periódica (Desactivado para URL fija)
  static void startPeriodicRefresh(
      {Duration interval = const Duration(seconds: 15)}) {
    AppLogger.info('Actualización periódica desactivada (usando URL fija)',
        tag: 'ConfigService');
  }

  /// Detiene la actualización periódica
  static void stopPeriodicRefresh() {
    // No hace nada ahora que no hay timer
  }

  /// Fuerza una actualización de los metadatos de conexión local
  static Future<void> forceRefresh() async {
    AppLogger.info('Refresh solicitado - Manteniendo URL fija',
        tag: 'ConfigService');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyBackendUrl, ApiConfig.baseUrl);
    await prefs.setInt(
        _prefsKeyLastFetch, DateTime.now().millisecondsSinceEpoch);
  }

  /// Obtiene la última vez que se "actualizó" la configuración (ahora devuelve el tiempo actual o guardado)
  static Future<DateTime?> getLastFetchTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_prefsKeyLastFetch);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.now();
  }

  /// Método llamado desde la consola del navegador
  static Future<void> triggerRefreshFromConsole() async {
    await forceRefresh();
  }
}
