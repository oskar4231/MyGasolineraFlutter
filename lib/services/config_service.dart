import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

/// Servicio responsable de configurar la URL del backend dinámicamente
class ConfigService {
  /// URL RAW del Gist que contiene la configuración del backend.
  /// Reemplazar con la URL real de tu Gist (botón "Raw" en GitHub).
  static const String _gistUrl =
      'https://gist.githubusercontent.com/Cristian-KN/d3c38c2cd0f3f5b6c3cc2cea828fc6c2/raw/backend-url.json'; // URL dinámica (latest)

  static const String _prefsKeyBackendUrl = 'backend_url';
  static const String _prefsKeyLastFetch = 'last_url_fetch';

  /// Timer para actualización periódica
  static Timer? _refreshTimer;

  /// Callback para notificar cambios de URL
  static Function()? onUrlChanged;

  /// Inicializa la configuración de la aplicación
  ///
  /// 1. Intenta cargar URL desde caché para inicio rápido
  /// 2. Intenta obtener nueva URL desde el Gist en segundo plano
  /// 3. Inicia actualización periódica cada 15 segundos (Gist es muy rápido)
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Cargar desde caché primero (si existe)
    final cachedUrl = prefs.getString(_prefsKeyBackendUrl);
    if (cachedUrl != null && cachedUrl.isNotEmpty) {
      print('ConfigService: Cargando URL desde caché: $cachedUrl');
      ApiConfig.setBaseUrl(cachedUrl);
    }

    // 2. Intentar actualizar desde el Gist con reintentos
    await _fetchWithRetry(prefs, maxRetries: 3);

    // 3. Iniciar actualización periódica cada 15 segundos (Gist es rápido ~100-300ms)
    startPeriodicRefresh();
  }

  /// Inicia actualización periódica de la URL del backend
  /// Chequea el Gist cada 15 segundos para detectar cambios rápidamente
  static void startPeriodicRefresh(
      {Duration interval = const Duration(seconds: 15)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (timer) async {
      print('ConfigService: Chequeando Gist para cambios de URL...');
      final prefs = await SharedPreferences.getInstance();
      await _fetchWithRetry(prefs, maxRetries: 1);
    });
  }

  /// Detiene la actualización periódica
  static void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Obtiene la URL con reintentos
  static Future<void> _fetchWithRetry(SharedPreferences prefs,
      {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('ConfigService: Intento $attempt de $maxRetries...');
        await _fetchAndSaveUrl(prefs);
        return; // Éxito, salir
      } catch (e) {
        print('ConfigService: Error en intento $attempt: $e');
        if (attempt < maxRetries) {
          // Esperar antes de reintentar (backoff exponencial)
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }

    // Si llegamos aquí, todos los intentos fallaron
    final cachedUrl = prefs.getString(_prefsKeyBackendUrl);
    if (cachedUrl == null) {
      print(
          'ConfigService: ⚠️ ADVERTENCIA: No hay URL en caché ni se pudo obtener del Gist. Usando URL por defecto.');
    }
  }

  /// Obtiene la URL del Gist y la guarda si es válida
  /// Si detecta un cambio de URL, notifica para hacer refresh
  static Future<void> _fetchAndSaveUrl(SharedPreferences prefs) async {
    if (_gistUrl.contains('PLACEHOLDER')) {
      print('ConfigService: ⚠️ URL del Gist no configurada. Saltando fetch.');
      return;
    }

    // Timeout de 5 segundos (Gist es rápido, no necesita 10s)
    final response =
        await http.get(Uri.parse(_gistUrl)).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String? newUrl = data['backend_url'];

      if (newUrl != null && newUrl.isNotEmpty) {
        // Verificar si la URL cambió
        final oldUrl = prefs.getString(_prefsKeyBackendUrl);
        final urlChanged = oldUrl != null && oldUrl != newUrl;

        // Guardar en caché
        await prefs.setString(_prefsKeyBackendUrl, newUrl);
        await prefs.setInt(
            _prefsKeyLastFetch, DateTime.now().millisecondsSinceEpoch);

        // Actualizar configuración
        ApiConfig.setBaseUrl(newUrl);

        if (urlChanged) {
          print(
              'ConfigService: 🔄 URL CAMBIÓ de "$oldUrl" a "$newUrl" - Notificando para refresh...');
          // Notificar cambio para que la app haga refresh
          if (onUrlChanged != null) {
            onUrlChanged!();
          }
        } else {
          print('ConfigService: URL verificada (sin cambios): $newUrl');
        }
      } else {
        throw Exception('El JSON del Gist no contiene "backend_url"');
      }
    } else {
      throw Exception(
          'Error ${response.statusCode} al obtener Gist: ${response.reasonPhrase}');
    }
  }

  /// Fuerza una actualización inmediata de la URL
  static Future<void> forceRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    await _fetchWithRetry(prefs, maxRetries: 3);
  }

  /// Obtiene la última vez que se actualizó la URL
  static Future<DateTime?> getLastFetchTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_prefsKeyLastFetch);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
}
