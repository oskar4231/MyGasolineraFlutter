import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/geocoding_service.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Helper class para gestionar marcadores del mapa (adaptado a flutter_map)
class MarkerHelper {
  // Ya no necesitamos pre-cargar BitmapDescriptors ni hacer conversiones.
  // Con flutter_map, los SVG se renderizan directamente usando widgets SvgPicture.

  Future<void> loadGasStationIcons() async {
    // Mantengo esta firma de función para no romper contratos anteriores,
    // pero ya no hace falta compilar imágenes a Canvas ByteData en `flutter_map`.
    AppLogger.info('Iconos validados (no necesitan precache pesado)',
        tag: 'MapHelpers');
  }

  /// Crea un marcador para una gasolinera en formato flutter_map
  fm.Marker createMarker(
    Gasolinera gasolinera,
    List<String> favoritosIds,
    Function(Gasolinera, bool) onTap, {
    bool markersEnabled = true,
  }) {
    bool esFavorita = favoritosIds.contains(gasolinera.id);

    // Ajustar el tamaño del marcador dependiendo si es favorita
    final double markerWidth = esFavorita ? 55.0 : 45.0;
    final double markerHeight = esFavorita ? 55.0 : 45.0;

    return fm.Marker(
      key: ValueKey('eess_${gasolinera.id}'),
      point: LatLng(gasolinera.lat, gasolinera.lng),
      width: markerWidth,
      height: markerHeight,
      child: GestureDetector(
        onTap: markersEnabled ? () => onTap(gasolinera, esFavorita) : null,
        child: SvgPicture.asset(
          esFavorita
              ? 'assets/images/iconoFavFinal.svg'
              : 'assets/images/iconoFinal.svg',
          width: markerWidth,
          height: markerHeight,
        ),
      ),
    );
  }

  /// Construye un widget de Cluster decorado usando tu icono personalizado
  /// Esto se llamará cuando flutter_map_marker_cluster forme grupos
  Widget buildClusterWidget(BuildContext context, int count) {
    return SvgPicture.asset(
      'assets/images/icono+1.svg',
      width: 60,
      height: 60,
    );
  }
}

/// Helper class para gestionar la provincia actual
class ProvinciaHelper {
  static Future<String> actualizarProvincia(double lat, double lng) async {
    try {
      final nombreProvincia =
          await GeocodingService.obtenerProvinciaDesdeCoords(lat, lng);
      return nombreProvincia;
    } catch (e) {
      AppLogger.error('ProvinciaHelper: Error actualizando provincia',
          tag: 'MapHelpers', error: e);
      return 'Detectando...';
    }
  }
}
