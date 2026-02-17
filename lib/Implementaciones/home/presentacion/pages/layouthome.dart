import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/mapa/presentacion/widgets/map_widget.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/pages/ajustes.dart';
import 'package:my_gasolinera/Implementaciones/coches/presentacion/pages/coches.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/pages/favoritos.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/main.dart' as app;

// Importar los nuevos widgets
import 'package:my_gasolinera/Implementaciones/home/presentacion/widgets/home_header.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/widgets/home_bottom_bar.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/presentacion/widgets/filters_drawer.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/widgets/filter_dialogs/price_filter_dialog.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/widgets/filter_dialogs/fuel_filter_dialog.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/widgets/filter_dialogs/opening_filter_dialog.dart';

class Layouthome extends StatefulWidget {
  const Layouthome({super.key});

  @override
  State<Layouthome> createState() => _LayouthomeState();
}

class _LayouthomeState extends State<Layouthome> {
  bool _showMap = true;
  late GasolinerasCacheService _cacheService;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Filtros
  double? _precioDesde;
  double? _precioHasta;
  String? _tipoCombustibleSeleccionado;
  String? _tipoAperturaSeleccionado;

  // Lista de gasolineras cargadas del mapa (compartida con vista de lista)
  List<Gasolinera> _gasolinerasCargadas = [];

  @override
  void initState() {
    super.initState();
    _cacheService = GasolinerasCacheService(app.database);
  }

  void _mostrarFiltroPrecio() async {
    final result = await PriceFilterDialog.show(
      context,
      precioDesde: _precioDesde,
      precioHasta: _precioHasta,
      tipoCombustible: _tipoCombustibleSeleccionado,
    );

    if (result != null && mounted) {
      setState(() {
        _precioDesde = result['desde'];
        _precioHasta = result['hasta'];
      });
    }
  }

  void _mostrarFiltroCombustible() async {
    final result = await FuelFilterDialog.show(
      context,
      valorActual: _tipoCombustibleSeleccionado,
    );

    if (result != null && mounted) {
      setState(() {
        _tipoCombustibleSeleccionado = result;
        // Limpiar filtros de precio si cambia el combustible
        if (result != _tipoCombustibleSeleccionado) {
          _precioDesde = null;
          _precioHasta = null;
        }
      });
    }
  }

  void _mostrarFiltroApertura() async {
    final result = await OpeningFilterDialog.show(
      context,
      valorActual: _tipoAperturaSeleccionado,
    );

    if (result != null && mounted) {
      setState(() {
        _tipoAperturaSeleccionado = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      drawer: FiltersDrawer(
        onPriceFilterPressed: _mostrarFiltroPrecio,
        onFuelFilterPressed: _mostrarFiltroCombustible,
        onOpeningFilterPressed: _mostrarFiltroApertura,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header con logo y botones
            HomeHeader(
              showMap: _showMap,
              onToggleChanged: (isMap) {
                setState(() {
                  _showMap = isMap;
                });
              },
              onFavoritosPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritosScreen(),
                  ),
                );
              },
              onPriceFilterPressed: _mostrarFiltroPrecio,
              onOpenDrawer: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),

            // Contenido principal (Mapa o Lista)
            // Renderizado condicional para mejor rendimiento (el mapa solo existe cuando se muestra)
            Expanded(
              child: _showMap
                  ? MapWidget(
                      key: const PageStorageKey<String>('map_widget_key'),
                      cacheService: _cacheService,
                      combustibleSeleccionado: _tipoCombustibleSeleccionado,
                      precioDesde: _precioDesde,
                      precioHasta: _precioHasta,
                      tipoAperturaSeleccionado: _tipoAperturaSeleccionado,
                      onGasolinerasLoaded: (gasolineras) {
                        // Guardar gasolineras para la vista de lista
                        setState(() {
                          _gasolinerasCargadas = gasolineras;
                        });
                      },
                    )
                  : _GasolinerasListView(
                      gasolineras: _gasolinerasCargadas,
                      combustibleSeleccionado: _tipoCombustibleSeleccionado,
                      precioDesde: _precioDesde,
                      precioHasta: _precioHasta,
                      tipoAperturaSeleccionado: _tipoAperturaSeleccionado,
                    ),
            ),

            // Barra inferior con botones
            HomeBottomBar(
              onCochesPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CochesScreen(),
                  ),
                );
              },
              onAjustesPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AjustesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para la vista de lista de gasolineras
class _GasolinerasListView extends StatelessWidget {
  final List<Gasolinera> gasolineras;
  final String? combustibleSeleccionado;
  final double? precioDesde;
  final double? precioHasta;
  final String? tipoAperturaSeleccionado;

  const _GasolinerasListView({
    required this.gasolineras,
    this.combustibleSeleccionado,
    this.precioDesde,
    this.precioHasta,
    this.tipoAperturaSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (gasolineras.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_gas_station_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay gasolineras para mostrar',
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cambia al mapa para cargar gasolineras',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: gasolineras.length,
      itemBuilder: (context, index) {
        final gasolinera = gasolineras[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_gas_station,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        gasolinera.rotulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  gasolinera.direccion,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (gasolinera.gasolina95 > 0)
                      _buildPrecioChip(
                        'G95',
                        gasolinera.gasolina95,
                        Colors.green.shade700,
                      ),
                    if (gasolinera.gasoleoA > 0)
                      _buildPrecioChip(
                        'Diesel',
                        gasolinera.gasoleoA,
                        Colors.black87,
                      ),
                    if (gasolinera.gasolina98 > 0)
                      _buildPrecioChip(
                        'G98',
                        gasolinera.gasolina98,
                        Colors.blue.shade700,
                      ),
                    if (gasolinera.glp > 0)
                      _buildPrecioChip(
                        'GLP',
                        gasolinera.glp,
                        Colors.orange.shade700,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrecioChip(String label, double precio, Color color) {
    return Chip(
      label: Text(
        '$label: ${precio.toStringAsFixed(3)}€',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color, width: 1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
