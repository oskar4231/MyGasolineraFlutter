import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/mapa/presentacion/widgets/map_widget.dart';
import 'package:geolocator/geolocator.dart' as geo;
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
import 'package:url_launcher/url_launcher.dart';
import 'package:my_gasolinera/Implementaciones/facturas/presentacion/pages/crear_factura_screen.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

class Layouthome extends StatefulWidget {
  const Layouthome({super.key});

  @override
  State<Layouthome> createState() => _LayouthomeState();
}

class _LayouthomeState extends State<Layouthome> {
  bool _showMap = true;
  late GasolinerasCacheService _cacheService;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Filtros ahora se gestionan a través de filterProvider en main.dart

  // Lista de gasolineras cargadas del mapa (compartida con vista de lista)
  List<Gasolinera> _gasolinerasCargadas = [];
  geo.Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _cacheService = GasolinerasCacheService(app.database);
  }

  void _mostrarFiltroPrecio() async {
    final result = await PriceFilterDialog.show(
      context,
      precioDesde: app.filterProvider.precioDesde,
      precioHasta: app.filterProvider.precioHasta,
      tipoCombustible: app.filterProvider.tipoCombustibleSeleccionado,
    );

    if (result != null && mounted) {
      await app.filterProvider
          .setPrecioFiltros(result['desde'], result['hasta']);
    }
  }

  void _mostrarFiltroCombustible() async {
    final result = await FuelFilterDialog.show(
      context,
      valorActual: app.filterProvider.tipoCombustibleSeleccionado,
    );

    if (result != null && mounted) {
      await app.filterProvider.setTipoCombustible(result);
    }
  }

  void _mostrarFiltroApertura() async {
    final result = await OpeningFilterDialog.show(
      context,
      valorActual: app.filterProvider.tipoAperturaSeleccionado,
    );

    if (result != null && mounted) {
      await app.filterProvider.setTipoApertura(result);
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
            // ✅ OPTIMIZACIÓN: Usar IndexedStack para mantener el Mapa vivo en memoria
            // Esto evita que Google Maps tenga que recargarse totalmente al cambiar de pestaña.
            Expanded(
              child: ListenableBuilder(
                listenable: app.filterProvider,
                builder: (context, _) {
                  return IndexedStack(
                    index: _showMap ? 0 : 1,
                    children: [
                      // El mapa ahora se mantiene en memoria
                      MapWidget(
                        key: const PageStorageKey<String>('map_widget_key'),
                        cacheService: _cacheService,
                        combustibleSeleccionado:
                            app.filterProvider.tipoCombustibleSeleccionado,
                        precioDesde: app.filterProvider.precioDesde,
                        precioHasta: app.filterProvider.precioHasta,
                        tipoAperturaSeleccionado:
                            app.filterProvider.tipoAperturaSeleccionado,
                        onGasolinerasLoaded: (gasolineras) {
                          if (_gasolinerasCargadas != gasolineras) {
                            setState(() {
                              _gasolinerasCargadas = gasolineras;
                            });
                          }
                        },
                        onLocationChanged: (pos) {
                          if (_currentPosition?.latitude != pos.latitude ||
                              _currentPosition?.longitude != pos.longitude) {
                            setState(() {
                              _currentPosition = pos;
                            });
                          }
                        },
                      ),
                      // La lista filtrada
                      _GasolinerasListView(
                        gasolineras: _gasolinerasCargadas,
                        currentPosition: _currentPosition,
                        combustibleSeleccionado:
                            app.filterProvider.tipoCombustibleSeleccionado,
                        precioDesde: app.filterProvider.precioDesde,
                        precioHasta: app.filterProvider.precioHasta,
                        tipoAperturaSeleccionado:
                            app.filterProvider.tipoAperturaSeleccionado,
                      ),
                    ],
                  );
                },
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
  final geo.Position? currentPosition;
  final String? combustibleSeleccionado;
  final double? precioDesde;
  final double? precioHasta;
  final String? tipoAperturaSeleccionado;

  const _GasolinerasListView({
    required this.gasolineras,
    this.currentPosition,
    this.combustibleSeleccionado,
    this.precioDesde,
    this.precioHasta,
    this.tipoAperturaSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;
    final filter = app.filterProvider;

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
              l10n.noGasolinerasCercanas,
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba a mover el mapa o cambiar filtros',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ OPTIMIZACIÓN: Ordenar la lista según el precio o cercanía
    List<Gasolinera> listReady = List.from(gasolineras);
    if (filter.ordenPrecio != null) {
      listReady.sort((a, b) {
        if (filter.ordenPrecio == 'distance') {
          if (currentPosition == null) return 0;
          double distA = geo.Geolocator.distanceBetween(
              currentPosition!.latitude,
              currentPosition!.longitude,
              a.lat,
              a.lng);
          double distB = geo.Geolocator.distanceBetween(
              currentPosition!.latitude,
              currentPosition!.longitude,
              b.lat,
              b.lng);
          return distA.compareTo(distB);
        }

        double precioA =
            _getPrecioComparacion(a, filter.tipoCombustibleSeleccionado);
        double precioB =
            _getPrecioComparacion(b, filter.tipoCombustibleSeleccionado);

        if (filter.ordenPrecio == 'asc') {
          return precioA.compareTo(precioB);
        } else {
          return precioB.compareTo(precioA);
        }
      });
    }

    return Column(
      children: [
        // Barra de ordenación
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
          ),
          child: Row(
            children: [
              Text(
                '${listReady.length} gasolineras',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _OrderButton(
                    label:
                        l10n.precioAscendente.split(' ').last, // "Ascendente"
                    icon: Icons.trending_down,
                    isSelected: filter.ordenPrecio == 'asc',
                    onTap: () => filter.setOrdenPrecio(
                        filter.ordenPrecio == 'asc' ? null : 'asc'),
                  ),
                  const SizedBox(width: 8),
                  _OrderButton(
                    label:
                        l10n.precioDescendente.split(' ').last, // "Descendente"
                    icon: Icons.trending_up,
                    isSelected: filter.ordenPrecio == 'desc',
                    onTap: () => filter.setOrdenPrecio(
                        filter.ordenPrecio == 'desc' ? null : 'desc'),
                  ),
                  const SizedBox(width: 8),
                  _OrderButton(
                    label: 'Cercanía',
                    icon: Icons.near_me,
                    isSelected: filter.ordenPrecio == 'distance',
                    onTap: () => filter.setOrdenPrecio(
                        filter.ordenPrecio == 'distance' ? null : 'distance'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: listReady.length,
            itemBuilder: (context, index) {
              final gasolinera = listReady[index];
              return Card(
                // ... (el resto del itemBuilder sigue igual)
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
                          InkWell(
                            onTap: () => _abrirGoogleMaps(
                                gasolinera.lat, gasolinera.lng),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.near_me_outlined,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (currentPosition != null)
                        _buildDistanceLabel(
                            gasolinera, currentPosition!, theme),
                      const SizedBox(height: 4),
                      Text(
                        gasolinera.direccion,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
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
          ),
        ),
      ],
    );
  }

  Future<void> _abrirGoogleMaps(double lat, double lng) async {
    final Uri mapsWebUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    try {
      await launchUrl(mapsWebUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      await launchUrl(mapsWebUri, mode: LaunchMode.platformDefault);
    }
  }

  double _getPrecioComparacion(Gasolinera g, String? combustible) {
    if (combustible != null) {
      switch (combustible) {
        case 'Gasolina 95':
          return g.gasolina95;
        case 'Gasolina 98':
          return g.gasolina98;
        case 'Diesel':
          return g.gasoleoA;
        case 'Diesel Premium':
          return g.gasoleoPremium;
        case 'Gas':
          return g.glp;
      }
    }
    // Si no hay combustible seleccionado o no coincide, usar el más barato disponible
    final precios = [
      g.gasolina95,
      g.gasolina98,
      g.gasoleoA,
      g.glp,
    ].where((p) => p > 0).toList();
    return precios.isEmpty ? 999.0 : precios.reduce((a, b) => a < b ? a : b);
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

  Widget _buildDistanceLabel(
      Gasolinera g, geo.Position currentPos, ThemeData theme) {
    final distanceMeters = geo.Geolocator.distanceBetween(
      currentPos.latitude,
      currentPos.longitude,
      g.lat,
      g.lng,
    );

    String distanceText = '';
    if (distanceMeters < 1000) {
      distanceText = '${distanceMeters.toStringAsFixed(0)} m';
    } else {
      distanceText = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }

    return Row(
      children: [
        Icon(Icons.location_on,
            size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          'a $distanceText de ti',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _OrderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
