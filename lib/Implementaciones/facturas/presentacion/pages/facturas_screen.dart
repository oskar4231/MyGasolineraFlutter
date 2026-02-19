import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/facturas/data/services/factura_service.dart';
import 'package:my_gasolinera/Implementaciones/facturas/data/services/export_service.dart';

import 'crear_factura_screen.dart';
import 'detalle_factura_screen.dart';
import 'seleccion_facturas_screen.dart';
import 'package:my_gasolinera/Implementaciones/facturas/presentacion/widgets/factura_image_widget.dart';
import 'package:intl/intl.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';

class FacturasScreen extends StatefulWidget {
  const FacturasScreen({super.key});

  @override
  State<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends State<FacturasScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _facturas = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  static const int _limit = 10;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _cargarFacturas();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore && _hasMore) {
        _cargarFacturas(loadMore: true);
      }
    }
  }

  Future<void> _cargarFacturas({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
        _hasMore = true;
        // Don't clear _facturas immediately for better UX if refreshing, unless strict reset needed
      });
    }

    try {
      final response = await FacturaService.obtenerFacturas(
        page: _currentPage,
        limit: _limit,
      );

      final List<dynamic> data = response['data'] ?? [];
      final int totalPages = response['totalPages'] ?? 1;
      final int responsePage = response['currentPage'] ?? 1;

      final List<Map<String, dynamic>> nuevasFacturas =
          data.map((factura) => factura as Map<String, dynamic>).toList();

      if (mounted) {
        setState(() {
          if (loadMore) {
            _facturas.addAll(nuevasFacturas);
          } else {
            _facturas = nuevasFacturas;
          }

          _hasMore = responsePage < totalPages;
          if (_hasMore) _currentPage++;

          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar facturas: $e';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
      debugPrint('Error cargando facturas: $e');
    }
  }

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
      debugPrint('Error parsing date: $e');
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

  void _navegarACrearFactura() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CrearFacturaScreen()),
    );

    if (result == true) {
      if (mounted) {
        _cargarFacturas(); // Recargar desde inicio
      }
    }
  }

  void _navegarAExportar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeleccionFacturasScreen(facturas: _facturas),
      ),
    );
  }

  Future<void> _importarExcel() async {
    try {
      setState(() => _isLoading = true);

      final facturasImportadas = await ExportService.importarExcel();

      debugPrint(
          '📥 Resultado de importación: ${facturasImportadas?.length ?? 'null'} facturas');

      if (facturasImportadas != null && facturasImportadas.isNotEmpty) {
        debugPrint(
            '📥 Procesando ${facturasImportadas.length} facturas importadas...');
        int count = 0;
        for (var factura in facturasImportadas) {
          try {
            debugPrint('📥 Procesando factura: ${factura['titulo']}');
            String fecha = factura['fecha'] ??
                DateFormat('yyyy-MM-dd').format(DateTime.now());

            // Convert date to MySQL-compatible format (YYYY-MM-DD)
            if (fecha.contains('T')) {
              try {
                DateTime parsedDate = DateTime.parse(fecha);
                fecha = DateFormat('yyyy-MM-dd').format(parsedDate);
              } catch (e) {
                debugPrint('⚠️ Error parsing ISO date: $e');
              }
            } else if (fecha.contains('/')) {
              var parts = fecha.split('/');
              if (parts.length == 3) {
                fecha = '${parts[2]}-${parts[1]}-${parts[0]}';
              }
            }

            await FacturaService.crearFactura(
              titulo: factura['titulo'],
              coste: double.tryParse(factura['coste'].toString()) ?? 0.0,
              fecha: fecha,
              hora: factura['hora'] ?? '00:00',
              descripcion: factura['descripcion'],
              litrosRepostados: double.tryParse(
                  factura['litros_repostados']?.toString() ?? ''),
              precioPorLitro: double.tryParse(
                  factura['precio_por_litro']?.toString() ?? ''),
              kilometrajeActual:
                  int.tryParse(factura['kilometraje_actual']?.toString() ?? ''),
              tipoCombustible: factura['tipo_combustible'],
              imagenFile: null,
            );
            count++;
          } catch (e) {
            debugPrint('❌ Error importando factura individual: $e');
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Se importaron $count facturas correctamente')),
          );
        }
        _cargarFacturas(); // Recargar
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No se encontraron facturas en el archivo')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Factura eliminada correctamente')),
          );
          _cargarFacturas(); // Recargar
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar factura: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
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
                    l10n.facturas,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF3E3E42)
                            : Color.lerp(
                                theme.cardTheme.color ?? theme.cardColor,
                                Colors.white,
                                0.25),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF212124)
                            : null,
                        icon: Icon(Icons.more_vert,
                            color: theme.brightness == Brightness.dark
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface),
                        onSelected: (value) {
                          switch (value) {
                            case 'refresh':
                              _cargarFacturas();
                              break;
                            case 'export':
                              _navegarAExportar();
                              break;
                            case 'import':
                              _importarExcel();
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'refresh',
                            child: ListTile(
                              leading: Icon(Icons.refresh,
                                  color: theme.brightness == Brightness.dark
                                      ? theme.colorScheme.primary
                                      : null),
                              title: Text(l10n.actualizar,
                                  style: TextStyle(
                                      color: theme.brightness == Brightness.dark
                                          ? theme.colorScheme.onSurface
                                          : null)),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'export',
                            child: ListTile(
                              leading: Icon(Icons.download,
                                  color: theme.brightness == Brightness.dark
                                      ? theme.colorScheme.primary
                                      : null),
                              title: const Text('Exportar'),
                              textColor: theme.brightness == Brightness.dark
                                  ? theme.colorScheme.onSurface
                                  : null,
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'import',
                            child: ListTile(
                              leading: Icon(Icons.upload_file,
                                  color: theme.brightness == Brightness.dark
                                      ? theme.colorScheme.primary
                                      : null),
                              title: const Text('Importar'),
                              textColor: theme.brightness == Brightness.dark
                                  ? theme.colorScheme.onSurface
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: theme.colorScheme.primary),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 60, color: theme.colorScheme.error),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _cargarFacturas(),
                                  child: Text(l10n.reintentar),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _facturas.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long,
                                      size: 80,
                                      color: theme.colorScheme.outline),
                                  const SizedBox(height: 20),
                                  Text(
                                    l10n.noFacturas,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    l10n.presionaBotonFactura,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount:
                                  _facturas.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _facturas.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  );
                                }

                                final factura = _facturas[index];
                                return Card(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: FacturaImageWidget(
                                          facturaId: int.tryParse(
                                              (factura['id_factura'] ??
                                                      factura['id'] ??
                                                      factura['facturaId'])
                                                  .toString()),
                                          serverPath: factura['imagenPath'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context) => Icon(
                                            Icons.receipt,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      factura['titulo'] ?? l10n.sinDatos,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          '€${(factura['coste'] != null ? double.parse(factura['coste'].toString()) : 0.0).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        Text(
                                          '${_formatFecha(factura['fecha'])} - ${_formatHora(factura['hora'])}',
                                          style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.7)),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete_outline,
                                          color: theme.colorScheme.error),
                                      onPressed: () => _eliminarFactura(
                                        int.tryParse((factura['id_factura'] ??
                                                factura['id'] ??
                                                factura['facturaId'])
                                            .toString())!,
                                      ),
                                    ),
                                    onTap: () => _verDetalleFactura(factura),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_menuOpen) ...[
            FloatingActionButton.extended(
              heroTag: 'import',
              onPressed: () {
                setState(() => _menuOpen = false);
                _importarExcel();
              },
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF3E3E42)
                  : theme.colorScheme.surface,
              foregroundColor: theme.brightness == Brightness.dark
                  ? Colors.white
                  : theme.colorScheme.primary,
              label: const Text('Importar'),
              icon: Icon(Icons.upload_file,
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.primary
                      : null),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: 'export',
              onPressed: () {
                setState(() => _menuOpen = false);
                _navegarAExportar();
              },
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF3E3E42)
                  : theme.colorScheme.surface,
              foregroundColor: theme.brightness == Brightness.dark
                  ? Colors.white
                  : theme.colorScheme.primary,
              label: const Text('Exportar'),
              icon: Icon(Icons.download,
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.primary
                      : null),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: 'create',
              onPressed: () {
                setState(() => _menuOpen = false);
                _navegarACrearFactura();
              },
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF3E3E42)
                  : theme.colorScheme.surface,
              foregroundColor: theme.brightness == Brightness.dark
                  ? Colors.white
                  : theme.colorScheme.primary,
              label: Text(l10n.crearFactura),
              icon: Icon(Icons.add_circle_outline,
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.primary
                      : null),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: 'menu',
            onPressed: () {
              setState(() {
                _menuOpen = !_menuOpen;
              });
            },
            backgroundColor: theme.brightness == Brightness.dark
                ? const Color(0xFF3E3E42)
                : theme.primaryColor,
            child: Icon(
              _menuOpen ? Icons.close : Icons.add,
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
