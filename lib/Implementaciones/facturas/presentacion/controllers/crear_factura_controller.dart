import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_gasolinera/Implementaciones/facturas/data/services/factura_service.dart';
import 'package:my_gasolinera/Implementaciones/coches/data/services/coche_service.dart';
import 'package:my_gasolinera/core/utils/local_image_service.dart';
import 'package:my_gasolinera/Implementaciones/facturas/data/services/ocr_service.dart';

class CrearFacturaController {
  final ImagePicker _picker = ImagePicker();

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<XFile?> seleccionarImagenGaleria() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
  }

  Future<XFile?> tomarFoto() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
  }

  Future<Map<String, dynamic>> procesarEscaneo(String imagePath) async {
    return await OcrService().scanAndExtract(imagePath);
  }

  Future<List<Map<String, dynamic>>> cargarCoches() async {
    final coches = await CocheService.obtenerCoches();
    return coches.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> guardarFactura({
    required String titulo,
    required double coste,
    required String fecha,
    required String hora,
    required String descripcion,
    required XFile? imagen,
    required double? litrosRepostados,
    required double? precioPorLitro,
    required int? kilometrajeActual,
    required String? tipoCombustible,
    required int? idCoche,
  }) async {
    final dateParts = fecha.split('/');
    final formattedFecha = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

    final response = await FacturaService.crearFactura(
      titulo: titulo,
      coste: coste,
      fecha: formattedFecha,
      hora: hora,
      descripcion: descripcion,
      imagenFile: null,
      litrosRepostados: litrosRepostados,
      precioPorLitro: precioPorLitro,
      kilometrajeActual: kilometrajeActual,
      tipoCombustible: tipoCombustible,
      idCoche: idCoche,
    );

    final idFactura =
        response['id'] ?? response['id_factura'] ?? response['facturaId'];

    if (imagen != null && idFactura != null) {
      await LocalImageService.saveImage(
          imagen, 'factura', idFactura.toString());
    }

    return response;
  }
}
