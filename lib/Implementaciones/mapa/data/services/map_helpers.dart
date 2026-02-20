import 'package:image/image.dart' as img;
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/geocoding_service.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Helper class para gestionar marcadores del mapa
class MarkerHelper {
  BitmapDescriptor? _gasStationIcon;
  BitmapDescriptor? _favoriteGasStationIcon;

  BitmapDescriptor? get gasStationIcon => _gasStationIcon;
  BitmapDescriptor? get favoriteGasStationIcon => _favoriteGasStationIcon;

  /// Procesa el icono: redimensiona y recorta bordes transparentes para mejorar el hitbox
  Future<Uint8List> processIcon(String path, int width) async {
    // 1. Cargar bytes del asset
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();

    // 2. Decodificar imagen usando package:image (Dart puro, funciona en web/desktop)
    img.Image? image = img.decodePng(bytes);

    if (image == null) return bytes; // Fallback si falla decodificación

    // 3. Redimensionar (Mantiene aspect ratio por defecto)
    img.Image resized = img.copyResize(image, width: width);

    // 4. Recortar bordes transparentes (Trim)
    // Esto es CLAVE para que el hitbox sea solo el icono
    img.Image trimmed = img.trim(resized, mode: img.TrimMode.transparent);

    // 5. Codificar de nuevo a PNG
    return Uint8List.fromList(img.encodePng(trimmed));
  }

  /// Carga los iconos personalizados para gasolineras
  Future<void> loadGasStationIcons() async {
    const ImageConfiguration config = ImageConfiguration();

    // 1. Load standard icon (Normal)
    try {
      // Intentar procesar (redimensionar + trim)
      // Usamos 140px como base, el trim lo reducirá al tamaño real del dibujo
      final Uint8List iconBytes = await processIcon(
        'assets/images/iconoFinal.png',
        140,
      );
      _gasStationIcon = BitmapDescriptor.fromBytes(iconBytes);
      AppLogger.info('Icono normal procesado (Resize+Trim)', tag: 'MapHelpers');
    } catch (e) {
      AppLogger.warning('Error procesando icono normal, usando fallback',
          tag: 'MapHelpers', error: e);

      try {
        _gasStationIcon = await BitmapDescriptor.fromAssetImage(
          config,
          'assets/images/iconoFinal.png',
        );
      } catch (e2) {}
    }

    // 2. Load favorite icon (Favorito)
    try {
      final Uint8List favIconBytes = await processIcon(
        'assets/images/iconoFavFinal.png',
        120,
      );
      _favoriteGasStationIcon = BitmapDescriptor.fromBytes(favIconBytes);
      AppLogger.info('Icono favorito procesado (Resize+Trim)',
          tag: 'MapHelpers');
    } catch (e) {
      AppLogger.warning('Error procesando icono favorito, usando fallback',
          tag: 'MapHelpers', error: e);

      try {
        _favoriteGasStationIcon = await BitmapDescriptor.fromAssetImage(
          config,
          'assets/images/iconoFavFinal.png',
        );
      } catch (e2) {}
    }
  }

  /// Crea un marcador para una gasolinera
  Marker createMarker(
    Gasolinera gasolinera,
    List<String> favoritosIds,
    Function(Gasolinera, bool) onTap, {
    bool markersEnabled = true,
  }) {
    bool esFavorita = favoritosIds.contains(gasolinera.id);

    BitmapDescriptor icon;

    // 1. Si es favorita y tenemos el icono de favoritos cargado, usamos ese
    if (esFavorita && _favoriteGasStationIcon != null) {
      icon = _favoriteGasStationIcon!;
    }
    // 2. Para el resto de gasolineras, usar el icono "assets/images/icono.png"
    else if (_gasStationIcon != null) {
      icon = _gasStationIcon!;
    }
    // 3. Fallback solo si falla la carga de assets
    else {
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    return Marker(
      markerId: MarkerId('eess_${gasolinera.id}'),
      position: gasolinera.position,
      icon: icon,
      anchor:
          const Offset(0.5, 1.0), // 🔷 Anchor en la base central para precisión
      zIndex: esFavorita ? 10.0 : 1.0, // 🔷 Favoritas siempre encima
      onTap: markersEnabled
          ? () {
              onTap(gasolinera, esFavorita);
            }
          : null,
    );
  }
}

/// Helper class para gestionar la provincia actual
class ProvinciaHelper {
  /// Actualiza la provincia actual usando geocodificación inversa
  /// Notifica mediante el callback onProvinciaUpdate
  static Future<String> actualizarProvincia(double lat, double lng) async {
    try {
      AppLogger.debug(
          'ProvinciaHelper: Actualizando provincia para ($lat, $lng)...',
          tag: 'MapHelpers');

      // Llamar al servicio de geocodificación
      final nombreProvincia =
          await GeocodingService.obtenerProvinciaDesdeCoords(lat, lng);

      AppLogger.info('ProvinciaHelper: Provincia detectada: $nombreProvincia',
          tag: 'MapHelpers');

      return nombreProvincia;
    } catch (e) {
      AppLogger.error('ProvinciaHelper: Error actualizando provincia',
          tag: 'MapHelpers', error: e);
      return 'Detectando...';
    }
  }
}
