import 'package:flutter/material.dart';
import 'package:my_gasolinera/principal/mapa/map_widget.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/coches/coches.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';
import 'favoritos.dart';
import 'package:my_gasolinera/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/main.dart' as app;

// Importar los nuevos widgets
import 'widgets/home_header.dart';
import 'widgets/home_bottom_bar.dart';
import 'widgets/filters_drawer.dart';
import 'widgets/filter_dialogs/price_filter_dialog.dart';
import 'widgets/filter_dialogs/fuel_filter_dialog.dart';
import 'widgets/filter_dialogs/opening_filter_dialog.dart';

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
            Expanded(
              child: Container(
                margin: _showMap
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                decoration: _showMap
                    ? null
                    : BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                child: Padding(
                  padding:
                      _showMap ? EdgeInsets.zero : const EdgeInsets.all(8.0),
                  child: _showMap
                      ? MapWidget(
                          cacheService: _cacheService,
                          combustibleSeleccionado: _tipoCombustibleSeleccionado,
                          precioDesde: _precioDesde,
                          precioHasta: _precioHasta,
                          tipoAperturaSeleccionado: _tipoAperturaSeleccionado,
                        )
                      : Center(
                          child: Text(
                            'Vista de lista - Por implementar',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                ),
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
