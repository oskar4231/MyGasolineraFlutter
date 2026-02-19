import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/facturas/data/services/export_service.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';

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
      // Return original if parsing fails
    }

    return fecha;
  }

  @override
  void initState() {
    super.initState();
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
    final isDark = theme.brightness == Brightness.dark;
    final allSelected = widget.facturas.isNotEmpty &&
        _selectedIds.length == widget.facturas.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header matching DetalleFactura/Ajustes
            Container(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: HoverBackButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    l10n.seleccionarFacturas,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
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
                        final fecha = _formatFecha(factura['fecha']);
                        final coste = (factura['coste'] != null
                                ? double.parse(factura['coste'].toString())
                                : 0.0)
                            .toStringAsFixed(2);

                        return Card(
                          color: theme.colorScheme.surfaceContainerHighest,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          child: Theme(
                            data: theme.copyWith(
                              checkboxTheme: theme.checkboxTheme.copyWith(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (val) => _toggleSelection(id),
                              activeColor: theme.colorScheme.primary,
                              checkColor: isDark ? Colors.black : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(titulo,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('$fecha - €$coste',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.7))),
                              ),
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.receipt,
                                    color: theme.colorScheme.primary),
                              ),
                            ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton(
              onPressed: _toggleSelectAll,
              child: Text(
                allSelected ? l10n.deseleccionar : l10n.seleccionarTodo,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: theme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _selectedIds.isEmpty ? null : _exportar,
              icon: Icon(Icons.download,
                  color: isDark ? Colors.black : Colors.white),
              label: Text(
                l10n.exportarConConteo(_selectedIds.length),
                style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
