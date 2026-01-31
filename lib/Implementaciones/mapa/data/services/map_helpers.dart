import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';
import 'package:my_gasolinera/services/geocoding_service.dart';

/// Helper class para gestionar marcadores del mapa
class MarkerHelper {
  BitmapDescriptor? _gasStationIcon;
  BitmapDescriptor? _favoriteGasStationIcon;

  BitmapDescriptor? get gasStationIcon => _gasStationIcon;
  BitmapDescriptor? get favoriteGasStationIcon => _favoriteGasStationIcon;

  /// Convierte un asset en bytes para crear iconos personalizados
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  /// Carga los iconos personalizados para gasolineras
  Future<void> loadGasStationIcons() async {
    // Load standard icon
    try {
      final Uint8List iconBytes = await getBytesFromAsset(
        'assets/images/icono_1.png',
        100,
      );
      _gasStationIcon = BitmapDescriptor.fromBytes(iconBytes);
      print('✅ Icono normal cargado correctamente');
    } catch (e) {
      print('❌ Error cargando icono normal: $e');
    }

    // Load favorite icon
    try {
      final Uint8List favIconBytes = await getBytesFromAsset(
        'assets/images/iconoFav_1.png',
        100,
      );
      _favoriteGasStationIcon = BitmapDescriptor.fromBytes(favIconBytes);
      print('✅ Icono favorito cargado correctamente');
    } catch (e) {
      print('❌ Error cargando icono favorito: $e');
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
      print('🔄 ProvinciaHelper: Actualizando provincia para ($lat, $lng)...');

      // Llamar al servicio de geocodificación
      final nombreProvincia =
          await GeocodingService.obtenerProvinciaDesdeCoords(lat, lng);

      print('✅ ProvinciaHelper: Provincia detectada: $nombreProvincia');

      return nombreProvincia;
    } catch (e) {
      print('❌ ProvinciaHelper: Error actualizando provincia: $e');
      return 'Detectando...';
    }
  }
}
