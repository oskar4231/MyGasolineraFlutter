import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/facturas/data/services/export_service.dart';
// import 'package:my_gasolinera/Implementaciones/facturas/presentacion/widgets/factura_image_widget.dart'; // Optional if we want images in list

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
    final l10n = AppLocalizations.of(context)!;
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.seleccionarAlMenosUna)),
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
        title: Text(l10n.exportarComo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: Text(l10n.exportarExcel),
              onTap: () => Navigator.pop(context, 'excel'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(l10n.exportarPdf),
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
            SnackBar(content: Text(l10n.exportarExitoExcel)),
          );
        }
      } else {
        await ExportService.exportarPDF(selectedFacturas);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.exportarExitoPdf)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final allSelected = widget.facturas.isNotEmpty &&
        _selectedIds.length == widget.facturas.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: theme.colorScheme.onPrimary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.seleccionarFacturas,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _toggleSelectAll,
                    child: Text(
                      allSelected ? l10n.deseleccionar : l10n.seleccionarTodo,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isExporting
                  ? Center(
                      child: CircularProgressIndicator(
                          color: theme.colorScheme.primary))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.facturas.length,
                      itemBuilder: (context, index) {
                        final factura = widget.facturas[index];
                        final id = factura['id_factura'] ??
                            factura['id'] ??
                            factura['facturaId'];
                        final isSelected = _selectedIds.contains(id);
                        final titulo = factura['titulo'] ?? l10n.sinDatos;
                        final fecha = factura['fecha'] ?? '';
                        final coste = factura['coste']?.toString() ?? '0';

                        return Card(
                          color: theme.colorScheme.surfaceContainerHighest,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (val) => _toggleSelection(id),
                            activeColor: theme.colorScheme.primary,
                            checkColor: theme.colorScheme.onPrimary,
                            title: Text(titulo,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface)),
                            subtitle: Text('$fecha - $coste €',
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7))),
                            secondary: Icon(Icons.receipt,
                                color: theme.colorScheme.primary),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _selectedIds.isEmpty ? null : _exportar,
          icon: Icon(Icons.download, color: theme.colorScheme.onPrimary),
          label: Text(
            l10n.exportarConConteo(_selectedIds.length),
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
