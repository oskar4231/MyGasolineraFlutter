import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/controllers/map_controller.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/map_helpers.dart';
import 'package:my_gasolinera/Implementaciones/mapa/presentacion/widgets/gasolinera_bottom.dart';
import 'package:my_gasolinera/Implementaciones/mapa/presentacion/widgets/map_cluster.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class MapWidget extends StatefulWidget {
  final GasolinerasCacheService cacheService;
  final Function(String provincia)? onProvinciaUpdate;
  final Function(List<Gasolinera> gasolineras)? onGasolinerasLoaded;

  // Filtros
  final String? combustibleSeleccionado;
  final double? precioDesde;
  final double? precioHasta;
  final String? tipoAperturaSeleccionado;
  final bool gesturesEnabled;
  final bool markersEnabled;

  const MapWidget({
    super.key,
    required this.cacheService,
    this.onProvinciaUpdate,
    this.onGasolinerasLoaded,
    this.combustibleSeleccionado,
    this.precioDesde,
    this.precioHasta,
    this.tipoAperturaSeleccionado,
    this.gesturesEnabled = true,
    this.markersEnabled = true,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget>
    with AutomaticKeepAliveClientMixin, MapClusterMixin {
  @override
  bool get wantKeepAlive => true;

  // ── Dependencias ───────────────────────────────────────────────────────────
  late final MapController _controller;
  final MarkerHelper _markerHelper = MarkerHelper();

  // ── Estado del mapa ────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  final Set<Marker> _userMarker = {};
  bool _isBottomSheetOpen = false;
  double _currentZoom = 15.0;
  CameraPosition? _currentCameraPosition;
  Timer? _cameraDebounceTimer;

  // ── MapClusterMixin: getters requeridos ────────────────────────────────────
  @override
  MarkerHelper get markerHelper => _markerHelper;
  @override
  List<String> get favoritosIds => _controller.favoritosIds;
  @override
  double get currentZoom => _currentZoom;
  @override
  Future<void> Function(Gasolinera, bool) get onMarkerTap =>
      (g, fav) => _mostrarInfoGasolinera(g, fav);

  @override
  void onClusterTap(LatLng location, double zoom) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, zoom),
    );
  }

  // ── Estilo del mapa ────────────────────────────────────────────────────────
  static const String _mapStyleLight = '''
[
  {"featureType": "poi",     "stylers": [{"visibility": "off"}]},
  {"featureType": "transit", "stylers": [{"visibility": "off"}]}
]
''';

  static const String _mapStyleDark = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#2d2d32"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#9e9e9e"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#2d2d32"}]},
  {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
  {"featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [{"color": "#b0b0b0"}]},
  {"featureType": "administrative.land_parcel", "stylers": [{"visibility": "off"}]},
  {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#d4d4d4"}]},
  {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#4a4a50"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#a0a0a0"}]},
  {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#555560"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#5e5e68"}]},
  {"featureType": "road.highway.controlled_access", "elementType": "geometry", "stylers": [{"color": "#6a6a72"}]},
  {"featureType": "road.local", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
  {"featureType": "transit", "stylers": [{"visibility": "off"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#1a1a2e"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#515170"}]}
]
''';

  // ── Ciclo de vida ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _controller = MapController(
      cacheService: widget.cacheService,
      onProvinciaUpdate: widget.onProvinciaUpdate,
      onGasolinerasLoaded: (gasolineras) {
        widget.onGasolinerasLoaded?.call(gasolineras);
        if (mounted) {
          clusterManager?.setItems(gasolineras);
          clusterManager?.updateMap();
          AppLogger.info(
            'ClusterManager actualizado con ${gasolineras.length} gasolineras',
            tag: 'MapWidget',
          );
        }
      },
      onPositionChanged: (pos) {
        if (mounted) {
          setState(() {
            _userMarker
              ..clear()
              ..add(_buildUserMarker(pos.latitude, pos.longitude));
          });
        }
      },
    );

    // Inicializar cluster y luego el controlador (GPS + datos)
    initClusterManager();
    _controller.initialize(_markerHelper);

    // Escuchar cambios del controlador para redibujar
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final pos = _controller.ubicacionActual;
    if (pos != null) {
      setState(() {
        _userMarker
          ..clear()
          ..add(_buildUserMarker(pos.latitude, pos.longitude));
      });
    }
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final filtersChanged = oldWidget.combustibleSeleccionado !=
            widget.combustibleSeleccionado ||
        oldWidget.precioDesde != widget.precioDesde ||
        oldWidget.precioHasta != widget.precioHasta ||
        oldWidget.tipoAperturaSeleccionado != widget.tipoAperturaSeleccionado;

    if (filtersChanged) {
      AppLogger.debug('Detectado cambio en filtros', tag: 'MapWidget');
      final pos = _controller.ubicacionActual;
      if (pos != null) {
        _controller.cargarGasolineras(
          pos.latitude,
          pos.longitude,
          combustibleSeleccionado: widget.combustibleSeleccionado,
          precioDesde: widget.precioDesde,
          precioHasta: widget.precioHasta,
          tipoAperturaSeleccionado: widget.tipoAperturaSeleccionado,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _cameraDebounceTimer?.cancel();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Marker _buildUserMarker(double lat, double lng) => Marker(
        markerId: const MarkerId('yo'),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );

  Future<void> _loadMapStyle(GoogleMapController controller) async {
    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final style = isDark ? _mapStyleDark : _mapStyleLight;
      await controller.setMapStyle(style);
      AppLogger.info(
        'Estilo del mapa aplicado (${isDark ? "oscuro" : "claro"})',
        tag: 'MapWidget',
      );
    } catch (e) {
      AppLogger.error('Error aplicando estilo del mapa',
          tag: 'MapWidget', error: e);
    }
  }

  // ── Bottom sheet ───────────────────────────────────────────────────────────

  Future<void> _mostrarInfoGasolinera(
      Gasolinera gasolinera, bool esFavorita) async {
    if (_isBottomSheetOpen) return;
    setState(() => _isBottomSheetOpen = true);

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GasolineraBottomSheet(
        gasolinera: gasolinera,
        esFavorita: esFavorita,
        onToggleFavorito: () async {
          await _controller.toggleFavorito(gasolinera.id);
          if (mounted) setState(() {});
        },
      ),
    );

    if (mounted) setState(() => _isBottomSheetOpen = false);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_controller.ubicacionActual == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final pos = _controller.ubicacionActual!;
    final allMarkers = _userMarker.union(clusterMarkers);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 15.0,
      ),
      markers: allMarkers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      gestureRecognizers: const {},
      onMapCreated: (controller) {
        _mapController = controller;
        clusterManager?.setMapId(controller.mapId);
        _loadMapStyle(controller);
        controller.animateCamera(
          CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
        );
      },
      onCameraMove: (position) {
        _currentCameraPosition = position;
        _currentZoom = position.zoom;
      },
      onCameraIdle: () async {
        if (_currentCameraPosition != null) {
          clusterManager?.onCameraMove(_currentCameraPosition!);
        }

        // Cargar gasolineras por bounding box con debounce 500ms
        _cameraDebounceTimer?.cancel();
        _cameraDebounceTimer = Timer(
          const Duration(milliseconds: 500),
          () async {
            if (_mapController == null || !mounted) return;
            try {
              final region = await _mapController!.getVisibleRegion();
              final swLat = region.southwest.latitude;
              final swLng = region.southwest.longitude;
              final neLat = region.northeast.latitude;
              final neLng = region.northeast.longitude;

              AppLogger.debug(
                'Bounding box: SW($swLat, $swLng) - NE($neLat, $neLng)',
                tag: 'MapWidget',
              );

              await _controller.cargarGasolinerasPorBounds(
                swLat: swLat,
                swLng: swLng,
                neLat: neLat,
                neLng: neLng,
                combustibleSeleccionado: widget.combustibleSeleccionado,
                precioDesde: widget.precioDesde,
                precioHasta: widget.precioHasta,
                tipoAperturaSeleccionado: widget.tipoAperturaSeleccionado,
              );
            } catch (e) {
              AppLogger.warning(
                'Error actualizando gasolineras por bounding box',
                tag: 'MapWidget',
                error: e,
              );
            }
          },
        );
      },
    );
  }
}
