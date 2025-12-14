import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/factura_service.dart';

class DetalleFacturaScreen extends StatelessWidget {
  final Map<String, dynamic> factura;

  const DetalleFacturaScreen({super.key, required this.factura});

  String _formatFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return '';

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

    if (hora.split(':').length > 2) {
      final partes = hora.split(':');
      return '${partes[0]}:${partes[1]}';
    }

    return hora;
  }

  String _buildImageUrl(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return '${FacturaService.baseUrl}/$normalizedPath';
  }

  @override
  Widget build(BuildContext context) {
    // --- VARIABLES DINÁMICAS DE TEMA ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Background: Crema en claro, Negro en oscuro
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFFFE8DA);
    
    // Header/Iconos: Marrón en claro, Blanco en oscuro
    final headerColor = isDark ? Colors.white : const Color(0xFF492714);
    
    // Tarjeta de información
    final cardColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFCFB0);
    
    // Textos dentro de la tarjeta
    // Label (título pequeño): Marrón en claro, Gris claro en oscuro
    final labelColor = isDark ? Colors.white70 : const Color(0xFF492714);
    // Value (texto grande): Marrón en claro, Blanco en oscuro
    final valueColor = isDark ? Colors.white : const Color(0xFF492714);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Detalle Factura',
          style: TextStyle(
            color: headerColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: headerColor,
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
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    _buildInfoRow('Título', factura['titulo'], labelColor, valueColor),
                    const SizedBox(height: 12),

                    // Costo Total
                    _buildInfoRow(
                      'Coste Total',
                      '€${(factura['coste'] != null ? double.parse(factura['coste'].toString()) : 0.0).toStringAsFixed(2)}',
                      labelColor,
                      valueColor,
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
                            labelColor,
                            valueColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoRow(
                            'Hora',
                            _formatHora(factura['hora']),
                            labelColor,
                            valueColor,
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
                          _buildInfoRow(
                            'Descripción', 
                            factura['descripcion'],
                            labelColor,
                            valueColor,
                          ),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Comprobante:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: headerColor,
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

  Widget _buildInfoRow(String label, String value, Color labelColor, Color valueColor, {bool isAmount = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isAmount ? 20 : 16,
            color: valueColor,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}