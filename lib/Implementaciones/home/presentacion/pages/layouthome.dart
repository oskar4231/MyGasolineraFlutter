import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/mapa/presentacion/widgets/map_widget.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/pages/ajustes.dart';
import 'package:my_gasolinera/Implementaciones/coches/presentacion/pages/coches.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/pages/favoritos.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
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
  late GasolinerasCacheService _cacheService;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Filtros
  double? _precioDesde;
  double? _precioHasta;
  String? _tipoCombustibleSeleccionado;
  String? _tipoAperturaSeleccionado;

  // Lista de gasolineras cargadas del mapa (compartida con vista de lista)

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
              child: Stack(
                children: [
                  MapWidget(
                    key: const PageStorageKey<String>('map_widget_key'),
                    cacheService: _cacheService,
                    combustibleSeleccionado: _tipoCombustibleSeleccionado,
                    precioDesde: _precioDesde,
                    precioHasta: _precioHasta,
                    tipoAperturaSeleccionado: _tipoAperturaSeleccionado,
                  ),
                  // Marca de agua MyGasolinera
                  Positioned(
                    left: 8,
                    bottom: 36,
                    child: IgnorePointer(
                      child: Text(
                        'MyGasolinera',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.white.withValues(alpha: 0.55),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
