import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/factura_service.dart';
import 'package:my_gasolinera/services/export_service.dart';

import 'CrearFacturaScreen.dart';
import 'DetalleFacturaScreen.dart';
import 'seleccion_facturas_screen.dart';
import 'package:my_gasolinera/ajustes/facturas/factura_image_widget.dart';
import 'package:intl/intl.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';

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

  // Animation for FAB
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _animationController,
    );
    _rotateAnimation =
        Tween<double>(begin: 0.0, end: 0.5).animate(CurvedAnimation(
      curve: Curves.easeOut,
      parent: _animationController,
    ));

    _scrollController.addListener(_onScroll);
    _cargarFacturas();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
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
    _toggleFab(); // Close menu
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
    _toggleFab(); // Close menu
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeleccionFacturasScreen(facturas: _facturas),
      ),
    );
  }

  Future<void> _importarExcel() async {
    _toggleFab(); // Close menu
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
            onPressed: () => _cargarFacturas(),
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
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
                            onPressed: () => _cargarFacturas(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              'Reintentar',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
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
                                  size: 80,
                                  color: Theme.of(context).primaryColor),
                              const SizedBox(height: 20),
                              Text(
                                'No hay facturas',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Usa el menú + para agregar o importar facturas',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(
                              top: 16, left: 16, right: 16, bottom: 80),
                          itemCount:
                              _facturas.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _facturas.length) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              );
                            }

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
                                      facturaId: int.tryParse(
                                          (factura['id_factura'] ??
                                                  factura['id'] ??
                                                  factura['facturaId'])
                                              .toString()),
                                      serverPath: factura['imagenPath'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context) => Icon(
                                        Icons.receipt,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  factura['titulo'] ?? 'Sin título',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${_formatFecha(factura['fecha'])} - ${_formatHora(factura['hora'])}',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7)),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete,
                                      color:
                                          Theme.of(context).colorScheme.error),
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

          // Overlay to dim background when menu is open
          if (_isFabOpen)
            GestureDetector(
              onTap: _toggleFab,
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          // Main FAB - positioned normally at bottom right
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              onPressed: _toggleFab,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: RotationTransition(
                turns: _rotateAnimation,
                child: const Icon(Icons.add),
              ),
            ),
          ),

          // Create Button - appears above the main FAB
          Positioned(
            right: 0,
            bottom: 72, // FAB height (56) + spacing (16)
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton.extended(
                  heroTag: 'create',
                  onPressed: _navegarACrearFactura,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Crear factura'),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),

          // Export Button - appears above Create button
          Positioned(
            right: 0,
            bottom: 144, // 72 + 56 (Create button height) + 16 (spacing)
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton.extended(
                  heroTag: 'export',
                  onPressed: _navegarAExportar,
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),

          // Import Button - appears above Export button
          Positioned(
            right: 0,
            bottom: 216, // 144 + 56 + 16
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton.extended(
                  heroTag: 'import',
                  onPressed: _importarExcel,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Importar'),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
