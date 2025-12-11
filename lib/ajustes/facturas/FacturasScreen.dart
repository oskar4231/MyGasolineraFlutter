import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/factura_service.dart';
import 'CrearFacturaScreen.dart';
import 'DetalleFacturaScreen.dart';

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
    final normalizedPath = path.replaceAll('\\', '/');
    return '${FacturaService.baseUrl}/$normalizedPath';
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
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta factura?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await FacturaService.eliminarFactura(idFactura);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Factura eliminada correctamente')),
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
      backgroundColor: const Color(0xFFFFE8DA),
      appBar: AppBar(
        title: const Text(
          'Mis Facturas',
          style: TextStyle(
            color: Color(0xFF492714),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF492714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF492714)),
            onPressed: _cargarFacturas,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9350)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF492714),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _cargarFacturas,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9350),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _facturas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long, size: 80, color: Color(0xFFFF9350)),
                  SizedBox(height: 20),
                  Text(
                    'No hay facturas',
                    style: TextStyle(fontSize: 18, color: Color(0xFF492714)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Presiona el botón + para agregar una factura',
                    style: TextStyle(color: Color(0xFF492714)),
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
                  color: const Color(0xFFFFCFB0),
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
                        color: const Color(0xFFFF9955),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: factura['imagenPath'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _buildImageUrl(factura['imagenPath']),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.receipt,
                                      color: Color(0xFF492714),
                                    ),
                              ),
                            )
                          : const Icon(Icons.receipt, color: Color(0xFF492714)),
                    ),
                    title: Text(
                      factura['titulo'] ?? 'Sin título',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF492714),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '€${(factura['coste'] != null ? double.parse(factura['coste'].toString()) : 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF492714),
                          ),
                        ),
                        Text(
                          '${_formatFecha(factura['fecha'])} - ${_formatHora(factura['hora'])}',
                          style: const TextStyle(color: Color(0xFF492714)),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFF492714)),
                      onPressed: () => _eliminarFactura(factura['id_factura']),
                    ),
                    onTap: () => _verDetalleFactura(factura),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarACrearFactura,
        backgroundColor: const Color(0xFFFF9350),
        foregroundColor: const Color(0xFF492714),
        child: const Icon(Icons.add),
      ),
    );
  }
}
