import 'dart:convert';
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

  /// Inicializa la configuración de la aplicación
  ///
  /// 1. Intenta cargar URL desde caché para inicio rápido
  /// 2. Intenta obtener nueva URL desde el Gist en segundo plano
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Cargar desde caché primero (si existe)
    final cachedUrl = prefs.getString(_prefsKeyBackendUrl);
    if (cachedUrl != null && cachedUrl.isNotEmpty) {
      print('ConfigService: Cargando URL desde caché: $cachedUrl');
      ApiConfig.setBaseUrl(cachedUrl);
    }

    // 2. Intentar actualizar desde el Gist
    try {
      print('ConfigService: Buscando actualización de URL en Gist...');
      await _fetchAndSaveUrl(prefs);
    } catch (e) {
      print('ConfigService: Error al actualizar URL desde Gist: $e');
      if (cachedUrl == null) {
        print(
            'ConfigService: ⚠️ ADVERTENCIA: No hay URL en caché ni se pudo obtener del Gist. Usando URL por defecto.');
      }
    }
  }

  /// Obtiene la URL del Gist y la guarda si es válida
  static Future<void> _fetchAndSaveUrl(SharedPreferences prefs) async {
    if (_gistUrl.contains('PLACEHOLDER')) {
      print('ConfigService: ⚠️ URL del Gist no configurada. Saltando fetch.');
      return;
    }

    final response = await http.get(Uri.parse(_gistUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String? newUrl = data['backend_url'];

      if (newUrl != null && newUrl.isNotEmpty) {
        // Guardar en caché
        await prefs.setString(_prefsKeyBackendUrl, newUrl);
        // Actualizar configuración
        ApiConfig.setBaseUrl(newUrl);
        print(
            'ConfigService: URL actualizada exitosamente desde Gist: $newUrl');
      } else {
        throw Exception('El JSON del Gist no contiene "backend_url"');
      }
    } else {
      throw Exception(
          'Error ${response.statusCode} al obtener Gist: ${response.reasonPhrase}');
    }
  }
}
