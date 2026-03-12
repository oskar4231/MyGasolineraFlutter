import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  /// Convierte un SVG a un BitmapDescriptor compatible con Google Maps
  /// [targetWidth] es el ancho lógico que queremos en el mapa.
  /// El alto se calcula automáticamente para no deformar el SVG.
  Future<BitmapDescriptor> _svgToBitmapDescriptor(
      String path, double targetWidth) async {
    // 1. Cargar el string del SVG
    final String svgString = await rootBundle.loadString(path);

    // 2. Usar un SvgLoader para obtener una PictureInfo
    final SvgLoader loader = SvgStringLoader(svgString);
    final PictureInfo pictureInfo = await vg.loadPicture(loader, null);

    // 3. Obtener el devicePixelRatio para que no se vea borroso en móviles modernos/web
    final double devicePixelRatio =
        ui.PlatformDispatcher.instance.views.first.devicePixelRatio;

    // 4. Calcular el alto manteniendo las proporciones (Aspect Ratio)
    final double aspectRatio = pictureInfo.size.width / pictureInfo.size.height;
    final double targetHeight = targetWidth / aspectRatio;

    // 5. Escalar a resolución física (lógico * ratio)
    final int physicalWidth = (targetWidth * devicePixelRatio).toInt();
    final int physicalHeight = (targetHeight * devicePixelRatio).toInt();

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(pictureRecorder);

    // Escalar el lienzo basándose en el tamaño original del SVG respecto al tamaño físico a dibujar
    final double scaleX = physicalWidth / pictureInfo.size.width;
    final double scaleY = physicalHeight / pictureInfo.size.height;

    canvas.scale(scaleX, scaleY);
    canvas.drawPicture(pictureInfo.picture);

    final ui.Picture scaledPicture = pictureRecorder.endRecording();
    final ui.Image image =
        await scaledPicture.toImage(physicalWidth, physicalHeight);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('No se pudo convertir SVG a ByteData');
    }

    // Pasamos el devicePixelRatio, así Google Maps lo renderiza con nitidez perfecta
    return BitmapDescriptor.bytes(
      byteData.buffer.asUint8List(),
      imagePixelRatio: devicePixelRatio,
    );
  }

  /// Carga los iconos personalizados para gasolineras (versión SVG)
  Future<void> loadGasStationIcons() async {
    // 1. Cargar icono estándar (Normal)
    try {
      // Ajustamos el ancho base a un valor adecuado para el mapa
      _gasStationIcon = await _svgToBitmapDescriptor(
        'assets/images/iconoFinal.svg',
        100,
      );
      AppLogger.info('Icono normal SVG cargado perfectamente',
          tag: 'MapHelpers');
    } catch (e) {
      AppLogger.error('Error cargando icono normal SVG, usando fallback',
          tag: 'MapHelpers', error: e);
      _gasStationIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    // 2. Cargar icono de favoritos (Favorito)
    try {
      _favoriteGasStationIcon = await _svgToBitmapDescriptor(
        'assets/images/iconoFavFinal.svg',
        100, // Un poco más grande para destacar
      );
      AppLogger.info('Icono favorito SVG cargado perfectamente',
          tag: 'MapHelpers');
    } catch (e) {
      AppLogger.error('Error cargando icono favorito SVG, usando fallback',
          tag: 'MapHelpers', error: e);
      _favoriteGasStationIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
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

    if (esFavorita && _favoriteGasStationIcon != null) {
      icon = _favoriteGasStationIcon!;
    } else if (_gasStationIcon != null) {
      icon = _gasStationIcon!;
    } else {
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    return Marker(
      markerId: MarkerId('eess_${gasolinera.id}'),
      position: gasolinera.position,
      icon: icon,
      anchor: const Offset(0.5, 1.0),
      zIndexInt: esFavorita ? 10 : 1,
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
