import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/factura_service.dart';

class DetalleFacturaScreen extends StatelessWidget {
  final Map<String, dynamic> factura;

  const DetalleFacturaScreen({super.key, required this.factura});

  String _formatFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return '';

    // Si viene en formato ISO (2025-12-10T23:00:00.000Z)
    if (fecha.contains('T')) {
      try {
        DateTime dateTime = DateTime.parse(fecha);
        return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
      } catch (e) {
        return fecha;
      }
    }

    return fecha;
  }

  String _formatHora(String? hora) {
    if (hora == null || hora.isEmpty) return '';

    // Si contiene segundos (:00 al final), quitarlos
    if (hora.split(':').length > 2) {
      final partes = hora.split(':');
      return '${partes[0]}:${partes[1]}';
    }

    return hora;
  }

  String _buildImageUrl(String path) {
    // Normalizar ruta (reemplazar backslashes con slashes para URL)
    final normalizedPath = path.replaceAll('\\', '/');
    return '${FacturaService.baseUrl}/$normalizedPath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE8DA),
      appBar: AppBar(
        title: const Text(
          'Detalle Factura',
          style: TextStyle(
            color: Color(0xFF492714),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 2, 1, 1),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la factura
            Card(
              color: const Color(0xFFFFCFB0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    _buildInfoRow('Título', factura['titulo']),
                    const SizedBox(height: 12),

                    // Costo Total
                    _buildInfoRow(
                      'Coste Total',
                      '€${(factura['coste'] != null ? double.parse(factura['coste'].toString()) : 0.0).toStringAsFixed(2)}',
                      isAmount: true,
                    ),
                    const SizedBox(height: 12),

                    // Fecha y Hora
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            'Fecha',
                            _formatFecha(factura['fecha']),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoRow(
                            'Hora',
                            _formatHora(factura['hora']),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Descripción
                    if (factura['descripcion'] != null &&
                        factura['descripcion'].isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Descripción', factura['descripcion']),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Imagen de la factura
            if (factura['imagenPath'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Comprobante:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF492714),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                backgroundColor: Colors.black,
                                appBar: AppBar(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  iconTheme: const IconThemeData(
                                    color: Colors.white,
                                  ),
                                ),
                                body: Center(
                                  child: InteractiveViewer(
                                    minScale: 0.5,
                                    maxScale: 4.0,
                                    child: Image.network(
                                      _buildImageUrl(factura['imagenPath']),
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                color: Colors.white,
                                                size: 100,
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          _buildImageUrl(factura['imagenPath']),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAmount = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF492714),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isAmount ? 20 : 16,
            color: const Color(0xFF492714),
            fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
