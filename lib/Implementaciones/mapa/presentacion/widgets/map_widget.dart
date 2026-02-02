import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/map_helpers.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/gasolinera_logic.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';

class MapWidget extends StatefulWidget {
  final GasolinerasCacheService cacheService;
  final Function(String provincia)? onProvinciaUpdate;

  // Parámetros para filtros
  final String? combustibleSeleccionado;
  final double? precioDesde;
  final double? precioHasta;
  final String? tipoAperturaSeleccionado;
  final double radiusKm;
  final bool gesturesEnabled;
  final bool markersEnabled;

  const MapWidget({
    super.key,
    required this.cacheService,
    this.onProvinciaUpdate,
    this.combustibleSeleccionado,
    this.precioDesde,
    this.precioHasta,
    this.tipoAperturaSeleccionado,
    this.radiusKm = 25.0,
    this.gesturesEnabled = true,
    this.markersEnabled = true,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ Preservar estado al cambiar de pantalla
  GoogleMapController? mapController;
  Position? _ubicacionActual;
  StreamSubscription<Position>? _positionStreamSub;
  final Set<Marker> _markers = {};
  final Set<Marker> _gasolinerasMarkers = {};
  Timer? _debounceTimer;
  Timer? _cameraDebounceTimer;
  bool _isBottomSheetOpen = false;

  // Helpers y lógica
  late MarkerHelper _markerHelper;
  late GasolineraLogic _gasolineraLogic;

  @override
  void initState() {
    super.initState();
    _markerHelper = MarkerHelper();
    _gasolineraLogic = GasolineraLogic(widget.cacheService);

    // ✅ CORRECCIÓN: Esperar a que los iconos se carguen antes de iniciar GPS
    // Esto asegura que los marcadores tengan iconos cuando se creen
    _inicializarMapa();
  }

  /// Inicializa el mapa cargando iconos y favoritos antes de iniciar GPS
  Future<void> _inicializarMapa() async {
    // 1. Cargar iconos de marcadores (crítico para mostrar gasolineras)
    await _markerHelper.loadGasStationIcons();
    print('✅ MapWidget: Iconos de marcadores cargados');

    // 2. Cargar favoritos
    await _gasolineraLogic.cargarFavoritos();
    print(
        '✅ MapWidget: Favoritos cargados (${_gasolineraLogic.favoritosIds.length} favoritos)');

    // 3. Actualizar UI para mostrar que está listo
    if (mounted) setState(() {});

    // 4. Iniciar seguimiento GPS (esto cargará las gasolineras)
    _iniciarSeguimiento();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambiaron los filtros, recargar gasolineras
    if (oldWidget.combustibleSeleccionado != widget.combustibleSeleccionado ||
        oldWidget.precioDesde != widget.precioDesde ||
        oldWidget.precioHasta != widget.precioHasta ||
        oldWidget.tipoAperturaSeleccionado != widget.tipoAperturaSeleccionado ||
        oldWidget.radiusKm != widget.radiusKm) {
      print(
          '🔄 MapWidget: Detectado cambio en configuración. Radio nuevo: ${widget.radiusKm}');

      if (_ubicacionActual != null) {
        _cargarGasolineras(
          _ubicacionActual!.latitude,
          _ubicacionActual!.longitude,
          isInitialLoad: false,
        );
      }
    }
  }

  /// Actualiza la provincia actual usando geocodificación inversa
  Future<void> _actualizarProvincia(double lat, double lng) async {
    final nombreProvincia = await ProvinciaHelper.actualizarProvincia(lat, lng);

    // Notificar al widget padre para actualizar el AppBar
    if (widget.onProvinciaUpdate != null) {
      widget.onProvinciaUpdate!(nombreProvincia);
    }
  }

  /// Carga gasolineras cercanas
  Future<void> _cargarGasolineras(double lat, double lng,
      {bool isInitialLoad = false}) async {
    final gasolinerasEnRadio = await _gasolineraLogic.cargarGasolineras(
      lat,
      lng,
      combustibleSeleccionado: widget.combustibleSeleccionado,
      precioDesde: widget.precioDesde,
      precioHasta: widget.precioHasta,
      tipoAperturaSeleccionado: widget.tipoAperturaSeleccionado,
      radiusKm: widget.radiusKm,
      isInitialLoad: isInitialLoad,
      onLoadingStateChange: (isLoading) {
        if (mounted) setState(() {});
      },
    );

    // Carga progresiva: SOLO en carga inicial para dar feedback rápido
    if (isInitialLoad &&
        !_gasolineraLogic.isLoadingProgressively &&
        gasolinerasEnRadio.length > 10) {
      _gasolineraLogic.setLoadingProgressively(true);
      if (mounted) setState(() {});

      // Mostrar primero las 10 más cercanas
      final primeras10 = gasolinerasEnRadio.take(10).toList();
      final newMarkers = primeras10
          .map((g) => _markerHelper.createMarker(
                g,
                _gasolineraLogic.favoritosIds,
                _mostrarInfoGasolinera,
                markersEnabled: widget.markersEnabled,
              ))
          .toSet();

      print(
          '🗺️ MapWidget (Progresivo): Creados ${newMarkers.length} marcadores iniciales');

      if (mounted) {
        setState(() {
          _gasolinerasMarkers.clear();
          _gasolinerasMarkers.addAll(newMarkers);
        });
        print(
            '✅ MapWidget (Progresivo): Marcadores iniciales actualizados (${_gasolinerasMarkers.length} marcadores)');
      }

      // Cargar el resto en segundo plano
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final resto = gasolinerasEnRadio.skip(10).toList();
          final restoMarkers = resto
              .map((g) => _markerHelper.createMarker(
                    g,
                    _gasolineraLogic.favoritosIds,
                    _mostrarInfoGasolinera,
                    markersEnabled: widget.markersEnabled,
                  ))
              .toSet();

          print(
              '🗺️ MapWidget (Progresivo): Creados ${restoMarkers.length} marcadores adicionales');

          setState(() {
            _gasolinerasMarkers.addAll(restoMarkers);
            _gasolineraLogic.setLoadingProgressively(false);
          });
          print(
              '✅ MapWidget (Progresivo): Total de marcadores: ${_gasolinerasMarkers.length}');
        }
      });

      return;
    }

    final newMarkers = gasolinerasEnRadio
        .map((g) => _markerHelper.createMarker(
              g,
              _gasolineraLogic.favoritosIds,
              _mostrarInfoGasolinera,
              markersEnabled: widget.markersEnabled,
            ))
        .toSet();

    print(
        '🗺️ MapWidget: Creados ${newMarkers.length} marcadores para mostrar en el mapa');

    if (mounted) {
      setState(() {
        _gasolinerasMarkers.clear();
        _gasolinerasMarkers.addAll(newMarkers);
      });
      print(
          '✅ MapWidget: Marcadores actualizados en el estado (${_gasolinerasMarkers.length} marcadores)');
    }
  }

  /// Muestra el bottom sheet con información de la gasolinera
  Future<void> _mostrarInfoGasolinera(
    Gasolinera gasolinera,
    bool esFavorita,
  ) async {
    if (_isBottomSheetOpen) return;

    setState(() {
      _isBottomSheetOpen = true;
    });

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      gasolinera.rotulo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _gasolineraLogic.toggleFavorito(gasolinera.id);
                      setState(() {});
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      esFavorita ? Icons.star : Icons.star_border,
                      color: esFavorita ? Colors.amber : Colors.grey,
                      size: 32,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                gasolinera.direccion,
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6)),
              ),

              const SizedBox(height: 20),

              // Precios
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (gasolinera.gasolina95 > 0)
                    _buildPrecioItem(
                      'Gasolina 95',
                      gasolinera.gasolina95,
                      Icons.local_gas_station,
                      Colors.green,
                      gasolinera.rotulo,
                    ),
                  if (gasolinera.gasoleoA > 0)
                    _buildPrecioItem(
                      'Diesel',
                      gasolinera.gasoleoA,
                      Icons.directions_car,
                      Theme.of(context).colorScheme.onSurface,
                      gasolinera.rotulo,
                    ),
                  if (gasolinera.gasolina98 > 0)
                    _buildPrecioItem(
                      'Gasolina 98',
                      gasolinera.gasolina98,
                      Icons.local_gas_station,
                      Colors.blue,
                      gasolinera.rotulo,
                    ),
                  if (gasolinera.glp > 0)
                    _buildPrecioItem(
                      'GLP',
                      gasolinera.glp,
                      Icons.local_fire_department,
                      Colors.orange,
                      gasolinera.rotulo,
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Botón para añadir/eliminar de favoritos
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _gasolineraLogic.toggleFavorito(gasolinera.id);
                    setState(() {});
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    esFavorita ? Icons.star : Icons.star_border,
                    color: Colors.white,
                  ),
                  label: Text(
                    esFavorita ? 'Eliminar de favoritos' : 'Añadir a favoritos',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: esFavorita
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón de Repostaje Rápido Genérico
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CrearFacturaScreen(
                          prefilledGasolineraName: gasolinera.rotulo,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  label: const Text(
                    'Repostaje Rápido',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF9350), // Color naranja/principal
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (mounted) {
      setState(() {
        _isBottomSheetOpen = false;
      });
    }
  }

  Widget _buildPrecioItem(
    String nombre,
    double precio,
    IconData icon,
    Color color,
    String gasolineraNombre,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            '$nombre: ',
            style: TextStyle(
                fontSize: 16,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const Spacer(),
          Text(
            '${precio.toStringAsFixed(3)}€',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Inicia el seguimiento de ubicación GPS
  Future<void> _iniciarSeguimiento() async {
    print('🌍 MapWidget: Iniciando seguimiento GPS...');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ MapWidget: Servicio de ubicación deshabilitado');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ MapWidget: Permisos de ubicación denegados');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print('❌ MapWidget: Permisos de ubicación denegados permanentemente');
      return;
    }

    Position? posicion;

    try {
      print('📍 MapWidget: Obteniendo ubicación actual...');
      posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print(
              '⏱️ MapWidget: Timeout obteniendo ubicación actual, intentando última conocida...');
          throw TimeoutException('GPS timeout');
        },
      );
      print(
          '✅ MapWidget: Ubicación actual obtenida: ${posicion.latitude}, ${posicion.longitude}');
    } catch (e) {
      print('⚠️ MapWidget: Error obteniendo ubicación actual: $e');
      print('🔄 MapWidget: Intentando obtener última ubicación conocida...');

      try {
        posicion = await Geolocator.getLastKnownPosition();
        if (posicion != null) {
          print(
              '✅ MapWidget: Última ubicación conocida obtenida: ${posicion.latitude}, ${posicion.longitude}');
        } else {
          print('❌ MapWidget: No hay última ubicación conocida');
        }
      } catch (e2) {
        print('❌ MapWidget: Error obteniendo última ubicación: $e2');
      }
    }

    if (posicion != null && mounted) {
      setState(() {
        _ubicacionActual = posicion;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('yo'),
            position: LatLng(posicion!.latitude, posicion.longitude),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      });

      print('🗺️ MapWidget: Cargando gasolineras para ubicación inicial...');
      _cargarGasolineras(posicion.latitude, posicion.longitude,
          isInitialLoad: true);

      // Actualizar provincia inicial
      _actualizarProvincia(posicion.latitude, posicion.longitude);
    } else {
      print('❌ MapWidget: No se pudo obtener ninguna ubicación');
    }

    // Iniciar stream de actualizaciones de ubicación
    print('📡 MapWidget: Iniciando stream de actualizaciones GPS...');
    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position pos) {
      if (!mounted) return;
      setState(() {
        _ubicacionActual = pos;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('yo'),
            position: LatLng(pos.latitude, pos.longitude),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      });

      // Actualizar provincia cada vez que el usuario se mueve >5 metros
      _actualizarProvincia(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ IMPORTANTE para AutomaticKeepAliveClientMixin

    if (_ubicacionActual == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final allMarkers = _markers.union(_gasolinerasMarkers);

    return GoogleMap(
      onMapCreated: (controller) {
        mapController = controller;
        if (_ubicacionActual != null) {
          controller.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(
                _ubicacionActual!.latitude,
                _ubicacionActual!.longitude,
              ),
            ),
          );
        }
      },
      onCameraIdle: () async {
        _cameraDebounceTimer?.cancel();
        _cameraDebounceTimer = Timer(
          const Duration(milliseconds: 500),
          () async {
            if (mapController != null && mounted) {
              try {
                final visibleRegion = await mapController!.getVisibleRegion();
                final centerLat = (visibleRegion.northeast.latitude +
                        visibleRegion.southwest.latitude) /
                    2;
                final centerLng = (visibleRegion.northeast.longitude +
                        visibleRegion.southwest.longitude) /
                    2;
                await _cargarGasolineras(centerLat, centerLng,
                    isInitialLoad: false);
              } catch (e) {}
            }
          },
        );
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(
          _ubicacionActual!.latitude,
          _ubicacionActual!.longitude,
        ),
        zoom: 15,
      ),
      markers: allMarkers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      scrollGesturesEnabled: widget.gesturesEnabled,
      zoomGesturesEnabled: widget.gesturesEnabled,
      tiltGesturesEnabled: widget.gesturesEnabled,
      rotateGesturesEnabled: widget.gesturesEnabled,
    );
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _debounceTimer?.cancel();
    _cameraDebounceTimer?.cancel();
    super.dispose();
  }
}
