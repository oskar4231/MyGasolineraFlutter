import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:my_gasolinera/ajustes/facturas/factura_image_widget.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';

class DetalleFacturaScreen extends StatelessWidget {
  final Map<String, dynamic> factura;

  const DetalleFacturaScreen({super.key, required this.factura});

  String _formatFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return '';

    try {
      DateTime? dateTime;
      if (fecha.contains('T')) {
        dateTime = DateTime.parse(fecha);
      } else if (fecha.contains('-')) {
        final partes = fecha.split('-');
        if (partes.length == 3) {
          dateTime = DateTime(
            int.parse(partes[0]),
            int.parse(partes[1]),
            int.parse(partes[2].split(' ')[0]),
          );
        }
      }

      if (dateTime != null) {
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
    } catch (e) {
      print('Error parsing date in detalle: $e');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.detalleFactura,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
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
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    _buildInfoRow(context, AppLocalizations.of(context)!.titulo,
                        factura['titulo']),
                    const SizedBox(height: 12),

                    // Costo Total
                    _buildInfoRow(
                      context,
                      AppLocalizations.of(context)!.costeTotal,
                      '€${(factura['coste'] != null ? double.parse(factura['coste'].toString()) : 0.0).toStringAsFixed(2)}',
                      isAmount: true,
                    ),
                    const SizedBox(height: 12),

                    // Fecha y Hora
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            context,
                            AppLocalizations.of(context)!.fecha,
                            _formatFecha(factura['fecha']),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoRow(
                            context,
                            AppLocalizations.of(context)!.hora,
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
                          _buildInfoRow(
                              context,
                              AppLocalizations.of(context)!.descripcion,
                              factura['descripcion']),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Imagen de la factura
            if (factura['imagenPath'] != null ||
                factura['id_factura'] != null ||
                factura['id'] != null ||
                factura['facturaId'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      AppLocalizations.of(context)!.comprobante,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
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
                                    child: FacturaImageWidget(
                                      facturaId: int.tryParse(
                                          (factura['id_factura'] ??
                                                  factura['id'] ??
                                                  factura['facturaId'])
                                              .toString()),
                                      serverPath: factura['imagenPath'],
                                      fit: BoxFit.contain,
                                      errorBuilder: (context) => const Icon(
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
                        child: FacturaImageWidget(
                          facturaId: factura['id_factura'] ??
                              factura['id'] ??
                              factura['facturaId'],
                          serverPath: factura['imagenPath'],
                          fit: BoxFit.cover,
                          errorBuilder: (context) {
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

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {bool isAmount = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isAmount ? 20 : 16,
            color: theme.colorScheme.onSurface,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
