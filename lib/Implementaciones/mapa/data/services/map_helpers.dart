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
  /// Si [clusterCount] se proporciona, dibuja el número centrado en el icono.
  Future<BitmapDescriptor> _svgToBitmapDescriptor(
      String path, double targetWidth, {int? clusterCount}) async {
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

    // 6. Si es un cluster, dibujar el número de gasolineras permanentemente como un "Tooltip" nativo
    if (clusterCount != null) {
      final String text = '$clusterCount gasolineras';
      final double fontSize = (pictureInfo.size.width * 0.22); // Letra un poco más ajustada
      
      final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: fontSize,
          fontWeight: FontWeight.bold, // Negrita como tu captura
        ),
      )
        ..pushStyle(ui.TextStyle(
          color: const Color(0xFF000000), // Texto negro
        ))
        ..addText(text);

      final ui.Paragraph paragraph = paragraphBuilder.build();
      paragraph.layout(const ui.ParagraphConstraints(width: double.infinity));
      
      final double textWidth = paragraph.maxIntrinsicWidth;
      final double textHeight = paragraph.height;

      // Padding bastante ajustado como en una ventana InfoWindow real
      final double paddingX = fontSize * 0.5;
      final double paddingY = fontSize * 0.4;
      final double tooltipWidth = textWidth + (paddingX * 2);
      final double tooltipHeight = textHeight + (paddingY * 2);
      final double arrowHeight = fontSize * 0.4; // Altura del piquito hacia abajo

      // Posicionamos el tooltip centrado justo por encima del icono
      final double tooltipX = (pictureInfo.size.width - tooltipWidth) / 2.0;
      // El pico tocará la parte superior del icono orgánico
      final double tooltipY = -tooltipHeight - arrowHeight;

      // 1. Crear la forma (Tooltip cuadrado con pico abajo al centro)
      final ui.Path path = ui.Path();
      
      // Dibujar caja redondeada
      final ui.RRect tooltipRect = ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
        const ui.Radius.circular(6.0), // Bordes redondeados más notorios
      );
      path.addRRect(tooltipRect);

      // Dibujar piquito (triángulo central abajo)
      final double centerX = pictureInfo.size.width / 2.0;
      path.moveTo(centerX - arrowHeight, tooltipY + tooltipHeight); // Punto izq
      path.lineTo(centerX, tooltipY + tooltipHeight + arrowHeight); // Punta abajo
      path.lineTo(centerX + arrowHeight, tooltipY + tooltipHeight); // Punto der
      path.close();

      // Sombra
      canvas.drawPath(
        path.shift(const Offset(0, 3)), 
        ui.Paint()
          ..color = const Color(0x40000000)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4.0),
      );

      // Fondo blanco fijo
      canvas.drawPath(
        path,
        ui.Paint()..color = const Color(0xFFFFFFFF),
      );

      // 2. Dibujar el texto encima bien centrado
      final double textOffsetX = tooltipX + paddingX;
      final double textOffsetY = tooltipY + paddingY;

      canvas.drawParagraph(paragraph, Offset(textOffsetX, textOffsetY));
    }

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
      // Reducido a 80 para hacer la hitbox (y el icono en pantalla) más pequeña y precisa.
      // El aspect ratio seguirá calculándose automáticamente.
      _gasStationIcon = await _svgToBitmapDescriptor(
        'assets/images/iconoFinal.svg',
        150,
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
      // Reducido a 90 (ligeramente más grande que el normal) para hitbox precisa.
      _favoriteGasStationIcon = await _svgToBitmapDescriptor(
        'assets/images/iconoFavFinal.svg',
        150, // Un poco más grande para destacar, pero sin ocupar medio mapa
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

  /// Genera un icono de cluster dinámico con el número en el centro.
  /// Es asíncrono porque tiene que recrear el canvas.
  Future<BitmapDescriptor> getClusterMarker(int count) async {
    try {
      return await _svgToBitmapDescriptor(
        'assets/images/iconoFinal.svg',
        180, // Ligeramente más grande que un marcador normal
        clusterCount: count,
      );
    } catch (e) {
      AppLogger.error('Error generando cluster marker dinámico',
          tag: 'MapHelpers', error: e);
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
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
