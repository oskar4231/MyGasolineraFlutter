import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  static Future<void> launchMaps(double lat, double lng) async {
    // URL UNIVERSAL que suele ser interceptada por Google Maps en Android/iOS
    // travelmode=driving asegura modo coche
    // dir_action=navigate inicia la navegación turn-by-turn si es posible
    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving&dir_action=navigate');

    try {
      // Intentamos abrir con "externalNonBrowserApplication" primero para forzar la App nativa
      if (!await launchUrl(googleMapsUrl,
          mode: LaunchMode.externalNonBrowserApplication)) {
        // Fallback: Si falla (no hay app instalada), abrimos en navegador (plataforma externa genérica)
        if (!await launchUrl(googleMapsUrl,
            mode: LaunchMode.externalApplication)) {
          throw 'No se pudo abrir el mapa';
        }
      }
    } catch (e) {
      // Último recurso: intentar abrir como plataforma (navegador in-app o sistema)
      // aunque externalApplication debería cubrir navegador del sistema.
      await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
    }
  }
}
