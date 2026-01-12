import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/factura_service.dart';
import 'package:my_gasolinera/services/api_config.dart';
import 'CrearFacturaScreen.dart';
import 'DetalleFacturaScreen.dart';
import 'package:my_gasolinera/ajustes/facturas/factura_image_widget.dart';
import 'package:intl/intl.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';

class FacturasScreen extends StatefulWidget {
  const FacturasScreen({super.key});

  @override
  State<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends State<FacturasScreen> {
  List<Map<String, dynamic>> _facturas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarFacturas();
  }

  Future<void> _cargarFacturas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final facturas = await FacturaService.obtenerFacturas();
      setState(() {
        _facturas = facturas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar facturas: $e';
        _isLoading = false;
      });
      print('Error cargando facturas: $e');
    }
  }

  String _formatFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return '';

    // Si viene en formato ISO (2025-12-10T23:00:00.000Z) o yyyy-MM-dd
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
            int.parse(partes[2].split(' ')[0]), // Por si viene con hora
          );
        }
      }

      if (dateTime != null) {
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
    } catch (e) {
      print('Error parsing date: $e');
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

  void _navegarACrearFactura() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CrearFacturaScreen()),
    );

    if (result == true) {
      // Si se creó una factura exitosamente, recargar la lista
      _cargarFacturas();
    }
  }

  void _verDetalleFactura(Map<String, dynamic> factura) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleFacturaScreen(factura: factura),
      ),
    );
  }

  Future<void> _eliminarFactura(int idFactura) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmarEliminar),
        content: Text(
          AppLocalizations.of(context)!.confirmarEliminar,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.eliminar,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await FacturaService.eliminarFactura(idFactura);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.facturaEliminadaExito)),
        );
        _cargarFacturas(); // Recargar la lista
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar factura: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.facturas,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh,
                color: Theme.of(context).appBarTheme.iconTheme?.color),
            onPressed: _cargarFacturas,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 80, color: Colors.red),
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _cargarFacturas,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.intenteNuevamente,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                )
              : _facturas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long,
                              size: 80, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)!.noFacturas,
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)!.presionaBotonFactura,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _facturas.length,
                      itemBuilder: (context, index) {
                        final factura = _facturas[index];
                        return Card(
                          color: Theme.of(context).cardColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FacturaImageWidget(
                                  facturaId:
                                      factura['id_factura'] ?? factura['id'],
                                  serverPath: factura['imagenPath'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context) => Icon(
                                    Icons.receipt,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              factura['titulo'] ?? 'Sin título',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '€${(factura['coste'] != null ? double.parse(factura['coste'].toString()) : 0.0).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '${_formatFecha(factura['fecha'])} - ${_formatHora(factura['hora'])}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7)),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete,
                                  color: Theme.of(context).colorScheme.error),
                              onPressed: () =>
                                  _eliminarFactura(factura['id_factura']),
                            ),
                            onTap: () => _verDetalleFactura(factura),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarACrearFactura,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
