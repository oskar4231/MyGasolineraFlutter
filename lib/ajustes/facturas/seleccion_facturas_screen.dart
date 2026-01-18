import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/export_service.dart';
// import 'package:my_gasolinera/ajustes/facturas/factura_image_widget.dart'; // Optional if we want images in list

class SeleccionFacturasScreen extends StatefulWidget {
  final List<Map<String, dynamic>> facturas;

  const SeleccionFacturasScreen({super.key, required this.facturas});

  @override
  State<SeleccionFacturasScreen> createState() =>
      _SeleccionFacturasScreenState();
}

class _SeleccionFacturasScreenState extends State<SeleccionFacturasScreen> {
  // Set of selected invoice IDs
  final Set<int> _selectedIds = {};
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // Start with all unselected? Or maybe select none.
    // Usually explicit selection is better.
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == widget.facturas.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.clear();
        for (var f in widget.facturas) {
          final id = f['id_factura'] ?? f['id'] ?? f['facturaId'];
          if (id != null) _selectedIds.add(id);
        }
      }
    });
  }

  Future<void> _exportar() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una factura')),
      );
      return;
    }

    // Filter selected
    final selectedFacturas = widget.facturas.where((f) {
      final id = f['id_factura'] ?? f['id'] ?? f['facturaId'];
      return _selectedIds.contains(id);
    }).toList();

    // Show dialog
    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar como...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel (.xlsx)'),
              onTap: () => Navigator.pop(context, 'excel'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('PDF (.pdf)'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
          ],
        ),
      ),
    );

    if (format == null) return;

    setState(() => _isExporting = true);

    try {
      if (format == 'excel') {
        await ExportService.exportarExcel(selectedFacturas);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exportado a Excel correctamente')),
          );
        }
      } else {
        await ExportService.exportarPDF(selectedFacturas);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exportado a PDF correctamente')),
          );
        }
      }
      // Close screen after export? Or stay? Let's stay.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = widget.facturas.isNotEmpty &&
        _selectedIds.length == widget.facturas.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Facturas'),
        actions: [
          TextButton(
            onPressed: _toggleSelectAll,
            child: Text(
              allSelected ? 'Deseleccionar' : 'Seleccionar todo',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          )
        ],
      ),
      body: _isExporting
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: widget.facturas.length,
              itemBuilder: (context, index) {
                final factura = widget.facturas[index];
                final id = factura['id_factura'] ??
                    factura['id'] ??
                    factura['facturaId'];
                final isSelected = _selectedIds.contains(id);
                final titulo = factura['titulo'] ?? 'Sin título';
                final fecha = factura['fecha'] ?? '';
                final coste = factura['coste']?.toString() ?? '0';

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (val) => _toggleSelection(id),
                  title: Text(titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$fecha - $coste €'),
                  secondary: const Icon(Icons.receipt),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _selectedIds.isEmpty ? null : _exportar,
          icon: const Icon(Icons.download),
          label: Text('Exportar (${_selectedIds.length})'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
