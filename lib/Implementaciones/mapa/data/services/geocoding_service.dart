import 'package:geocoding/geocoding.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/provincia_service.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// 🌍 Servicio de Geocodificación Inversa
/// Convierte coordenadas GPS (lat, lng) → Dirección (provincia, ciudad, calle)
class GeocodingService {
  /// Obtiene el nombre de la provincia desde coordenadas GPS
  ///
  /// **Ejemplo:**
  /// ```dart
  /// final provincia = await GeocodingService.obtenerProvinciaDesdeCoords(40.416775, -3.703790);
  /// print(provincia); // "Madrid"
  /// ```
  ///
  /// **Cómo funciona:**
  /// 1. Usa el paquete `geocoding` para hacer geocodificación inversa
  /// 2. Extrae el nombre de la provincia del resultado
  /// 3. Si falla, usa `ProvinciaService` como fallback (detección por polígonos)
  ///
  /// **Parámetros:**
  /// - `lat`: Latitud (ej: 40.416775)
  /// - `lng`: Longitud (ej: -3.703790)
  ///
  /// **Retorna:**
  /// - Nombre de la provincia (ej: "Madrid", "Valencia", "Barcelona")
  /// - En caso de error, devuelve "Desconocida" o la provincia detectada por polígonos
  static Future<String> obtenerProvinciaDesdeCoords(
      double lat, double lng) async {
    try {
      AppLogger.debug('Geocoding: Detectando provincia para ($lat, $lng)...',
          tag: 'GeocodingService');

      // 1. Llamar a la API de geocodificación inversa
      // Esto convierte coordenadas → dirección completa
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) {
        AppLogger.warning(
            'Geocoding: No se encontraron resultados, usando fallback',
            tag: 'GeocodingService');
        return await _usarFallback(lat, lng);
      }

      // 2. Extraer el primer resultado (el más preciso)
      Placemark lugar = placemarks.first;

      // 3. Obtener el nombre de la provincia
      // En España, el campo `administrativeArea` contiene la provincia
      String? provincia = lugar.administrativeArea;

      // Debug: Mostrar todos los campos disponibles
      AppLogger.debug('Geocoding Debug:', tag: 'GeocodingService');
      AppLogger.debug('   - País: ${lugar.country}', tag: 'GeocodingService');
      AppLogger.debug(
          '   - Provincia (administrativeArea): ${lugar.administrativeArea}',
          tag: 'GeocodingService');
      AppLogger.debug('   - Ciudad (locality): ${lugar.locality}',
          tag: 'GeocodingService');
      AppLogger.debug('   - Subadministrativa: ${lugar.subAdministrativeArea}',
          tag: 'GeocodingService');
      AppLogger.debug('   - Código postal: ${lugar.postalCode}',
          tag: 'GeocodingService');

      if (provincia != null && provincia.isNotEmpty) {
        AppLogger.info('Geocoding: Provincia detectada: $provincia',
            tag: 'GeocodingService');
        return provincia;
      } else {
        AppLogger.warning('Geocoding: Campo provincia vacío, usando fallback',
            tag: 'GeocodingService');
        return await _usarFallback(lat, lng);
      }
    } catch (e) {
      // Manejo de errores (sin conexión, límite de API, etc.)
      AppLogger.error('Geocoding Error', tag: 'GeocodingService', error: e);
      AppLogger.debug('   Usando fallback (ProvinciaService)...',
          tag: 'GeocodingService');
      return await _usarFallback(lat, lng);
    }
  }

  /// Fallback: Usa ProvinciaService para detectar provincia por polígonos
  /// Esto funciona sin conexión a internet
  static Future<String> _usarFallback(double lat, double lng) async {
    try {
      final provinciaInfo =
          await ProvinciaService.getProvinciaFromCoordinates(lat, lng);
      AppLogger.info(
        'Fallback: Provincia detectada por polígonos: ${provinciaInfo.nombre}',
        tag: 'GeocodingService',
      );
      return provinciaInfo.nombre;
    } catch (e) {
      AppLogger.error('Fallback Error', tag: 'GeocodingService', error: e);
      return 'Desconocida';
    }
  }

  /// Obtiene la dirección completa desde coordenadas GPS
  ///
  /// **Ejemplo:**
  /// ```dart
  /// final direccion = await GeocodingService.obtenerDireccionCompleta(40.416775, -3.703790);
  /// print(direccion); // "Calle de Alcalá, 123, Madrid, España"
  /// ```
  static Future<String> obtenerDireccionCompleta(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) {
        return 'Dirección no disponible';
      }

      Placemark lugar = placemarks.first;

      // Construir dirección completa
      List<String> partes = [];

      if (lugar.street != null && lugar.street!.isNotEmpty) {
        partes.add(lugar.street!);
      }
      if (lugar.locality != null && lugar.locality!.isNotEmpty) {
        partes.add(lugar.locality!);
      }
      if (lugar.administrativeArea != null &&
          lugar.administrativeArea!.isNotEmpty) {
        partes.add(lugar.administrativeArea!);
      }
      if (lugar.country != null && lugar.country!.isNotEmpty) {
        partes.add(lugar.country!);
      }

      return partes.join(', ');
    } catch (e) {
      AppLogger.error('Error obteniendo dirección completa',
          tag: 'GeocodingService', error: e);
      return 'Dirección no disponible';
    }
  }
}
