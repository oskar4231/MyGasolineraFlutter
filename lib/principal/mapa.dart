<<<<<<< HEAD
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
=======
>>>>>>> origin/main
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
<<<<<<< HEAD
import 'package:my_gasolinera/principal/gasolineras/api_gasolinera.dart' as api;
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';
import 'package:my_gasolinera/main.dart' as app;
import 'package:my_gasolinera/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/services/provincia_service.dart';
=======
import 'package:my_gasolinera/principal/gasolineras/api_gasolinera.dart';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';
>>>>>>> origin/main

class MapaTiempoReal extends StatefulWidget {
  const MapaTiempoReal({super.key});

  @override
  _MapaTiempoRealState createState() => _MapaTiempoRealState();
}

class _MapaTiempoRealState extends State<MapaTiempoReal> {
<<<<<<< HEAD
  double _radiusKm = 25.0;
  Key _mapKey = UniqueKey(); // Para forzar reconstrucción si es necesario

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _radiusKm = prefs.getDouble('radius_km') ?? 25.0;
      });
    }
  }

=======
>>>>>>> origin/main
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Ubicación en Tiempo Real'),
        backgroundColor: Colors.blue,
      ),
<<<<<<< HEAD
      body: MapWidget(
        key: _mapKey,
        radiusKm: _radiusKm,
      ),
=======
      body: const MapWidget(),
>>>>>>> origin/main
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AjustesScreen()),
<<<<<<< HEAD
          ).then((_) {
            // Recargar preferencias al volver de ajustes
            _cargarPreferencias();
          });
=======
          );
>>>>>>> origin/main
        },
        backgroundColor: Colors.blue,
        child: Image.asset(
          'lib/assets/ajustes.png',
          width: 24,
          height: 24,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class MapWidget extends StatefulWidget {
  final List<Gasolinera>? externalGasolineras;
  final Function(double lat, double lng)? onLocationUpdate;

  // Parámetros para filtros
  final String? combustibleSeleccionado;
  final double? precioDesde;
  final double? precioHasta;
  final String? tipoAperturaSeleccionado;
<<<<<<< HEAD
  final double radiusKm; // Nuevo parámetro
=======
>>>>>>> origin/main

  const MapWidget({
    super.key,
    this.externalGasolineras,
    this.onLocationUpdate,
    this.combustibleSeleccionado,
    this.precioDesde,
    this.precioHasta,
    this.tipoAperturaSeleccionado,
<<<<<<< HEAD
    this.radiusKm = 25.0, // Valor por defecto
=======
>>>>>>> origin/main
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? mapController;
  Position? _ubicacionActual;
  StreamSubscription<Position>? _positionStreamSub;
  final Set<Marker> _markers = {};
  final Set<Marker> _gasolinerasMarkers = {};
  BitmapDescriptor? _gasStationIcon;
  BitmapDescriptor? _favoriteGasStationIcon;
  Timer? _debounceTimer;
  Timer? _cameraDebounceTimer;
  List<String> _favoritosIds = [];
  bool _isBottomSheetOpen = false;

<<<<<<< HEAD
  // Cache service y provincia
  late GasolinerasCacheService _cacheService;
  String? _currentProvinciaId;
  bool _isLoadingFromCache = false;

  // Para carga progresiva
  bool _isLoadingProgressively = false;
=======
  static const int LIMIT_RESULTS = 50;
>>>>>>> origin/main

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _cacheService = GasolinerasCacheService(app.database);
=======
>>>>>>> origin/main
    _loadGasStationIcon();
    _iniciarSeguimiento();
    _cargarFavoritos();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambiaron los filtros o la lista externa, recargar gasolineras
    if (oldWidget.combustibleSeleccionado != widget.combustibleSeleccionado ||
        oldWidget.precioDesde != widget.precioDesde ||
        oldWidget.precioHasta != widget.precioHasta ||
        oldWidget.tipoAperturaSeleccionado != widget.tipoAperturaSeleccionado ||
<<<<<<< HEAD
        oldWidget.externalGasolineras != widget.externalGasolineras ||
        oldWidget.radiusKm != widget.radiusKm) {
      print(
          '🔄 MapWidget: Detectado cambio en configuración. Radio nuevo: ${widget.radiusKm}');

=======
        oldWidget.externalGasolineras != widget.externalGasolineras) {
>>>>>>> origin/main
      if (_ubicacionActual != null) {
        _cargarGasolineras(
          _ubicacionActual!.latitude,
          _ubicacionActual!.longitude,
<<<<<<< HEAD
          isInitialLoad: false,
=======
>>>>>>> origin/main
        );
      }
    }
  }

  Future<void> _cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favoritas_ids') ?? [];
    if (mounted) {
      setState(() {
        _favoritosIds = ids;
      });
    }
  }

<<<<<<< HEAD
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _loadGasStationIcon() async {
    try {
      final Uint8List iconBytes = await getBytesFromAsset(
        'lib/assets/location_9351238.png',
        100,
      );
      final Uint8List favIconBytes = await getBytesFromAsset(
        'lib/assets/localizacion_favs.png',
        100,
      );

      final BitmapDescriptor icon = BitmapDescriptor.fromBytes(iconBytes);
      final BitmapDescriptor favIcon = BitmapDescriptor.fromBytes(favIconBytes);

=======
  Future<void> _loadGasStationIcon() async {
    try {
      final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/assets/location_9351238.png',
      );
      final BitmapDescriptor favIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/assets/localizacion_favs.png',
      );

>>>>>>> origin/main
      if (mounted) {
        setState(() {
          _gasStationIcon = icon;
          _favoriteGasStationIcon = favIcon;
        });
      }
    } catch (e) {
      // Manejo de errores
<<<<<<< HEAD
      print('Error cargando iconos: $e');
=======
>>>>>>> origin/main
    }
  }

  double _obtenerPrecioCombustible(Gasolinera g, String tipoCombustible) {
    switch (tipoCombustible) {
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
      default:
        return 0.0;
    }
  }

  List<Gasolinera> _aplicarFiltros(List<Gasolinera> gasolineras) {
    List<Gasolinera> resultado = gasolineras;

    // 1. Filtro de combustible y precio
    if (widget.combustibleSeleccionado != null) {
      resultado = resultado.where((g) {
        double precio = _obtenerPrecioCombustible(
          g,
          widget.combustibleSeleccionado!,
        );

        if (precio == 0.0) return false;

        if (widget.precioDesde != null && precio < widget.precioDesde!) {
          return false;
        }
        if (widget.precioHasta != null && precio > widget.precioHasta!) {
          return false;
        }

        return true;
      }).toList();
    }

    // 2. Filtro de Apertura (Horario)
    if (widget.tipoAperturaSeleccionado != null) {
      resultado = resultado.where((g) {
        switch (widget.tipoAperturaSeleccionado) {
          case '24 Horas':
            return g.es24Horas;
          case 'Gasolineras atendidas por personal':
            return !g.es24Horas;
          case 'Gasolineras abiertas ahora':
            return g.estaAbiertaAhora;
          case 'Todas':
            return true;
          default:
            return true;
        }
      }).toList();
    }

    return resultado;
  }

<<<<<<< HEAD
  Future<void> _cargarGasolineras(double lat, double lng,
      {bool isInitialLoad = false}) async {
=======
  Future<void> _cargarGasolineras(double lat, double lng) async {
>>>>>>> origin/main
    List<Gasolinera> listaGasolineras;

    if (widget.externalGasolineras != null &&
        widget.externalGasolineras!.isNotEmpty) {
      listaGasolineras = widget.externalGasolineras!;
    } else {
<<<<<<< HEAD
      // Usar cache service con detección de provincia
      setState(() {
        _isLoadingFromCache = true;
      });

      try {
        // Detectar provincia actual
        final provinciaInfo =
            await ProvinciaService.getProvinciaFromCoordinates(lat, lng);
        _currentProvinciaId = provinciaInfo.id;

        print(
            'Mapa: Cargando gasolineras para provincia ${provinciaInfo.nombre}');

        // Cargar gasolineras de la provincia actual y vecinas
        final vecinas = ProvinciaService.getProvinciasVecinas(provinciaInfo.id);
        final provinciasToLoad = [provinciaInfo.id, ...vecinas.take(2)];

        listaGasolineras = await _cacheService.getGasolinerasMultiProvincia(
          provinciasToLoad,
          forceRefresh: false,
        );

        print(
            'Mapa: Cargadas ${listaGasolineras.length} gasolineras desde cache');
      } catch (e) {
        print('Mapa: Error al cargar desde cache, usando API: $e');
        // Usar API con filtro de provincia en lugar de todas las gasolineras
        if (_currentProvinciaId != null) {
          listaGasolineras =
              await api.fetchGasolinerasByProvincia(_currentProvinciaId!);
        } else {
          // Si no tenemos provincia, intentar detectarla
          final provinciaInfo =
              await ProvinciaService.getProvinciaFromCoordinates(lat, lng);
          listaGasolineras =
              await api.fetchGasolinerasByProvincia(provinciaInfo.id);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingFromCache = false;
          });
        }
      }
=======
      listaGasolineras = await fetchGasolineras();
>>>>>>> origin/main
    }

    listaGasolineras = _aplicarFiltros(listaGasolineras);

<<<<<<< HEAD
    print(
        '📍 Filtrando ${listaGasolineras.length} gasolineras por radio de ${widget.radiusKm} km');

    // Calcular distancias y filtrar por radio
    final gasolinerasCercanas = listaGasolineras.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).where((item) {
      // Filtrar por radio (convertir metros a km)
      final distanceKm = (item['distance'] as double) / 1000;
      return distanceKm <= widget.radiusKm;
    }).toList();

    // Ordenar por distancia
=======
    final gasolinerasCercanas = listaGasolineras.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).toList();

>>>>>>> origin/main
    gasolinerasCercanas.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

<<<<<<< HEAD
    final gasolinerasEnRadio =
        gasolinerasCercanas.map((e) => e['gasolinera'] as Gasolinera).toList();

    print(
        'Mapa: Mostrando ${gasolinerasEnRadio.length} gasolineras en radio de ${widget.radiusKm}km');

    // Carga progresiva: SOLO en carga inicial para dar feedback rápido
    if (isInitialLoad &&
        !_isLoadingProgressively &&
        gasolinerasEnRadio.length > 10) {
      setState(() {
        _isLoadingProgressively = true;
      });

      // Mostrar primero las 10 más cercanas
      final primeras10 = gasolinerasEnRadio.take(10).toList();
      final newMarkers = primeras10.map((g) => _crearMarcador(g)).toSet();

      if (mounted) {
        setState(() {
          _gasolinerasMarkers.clear();
          _gasolinerasMarkers.addAll(newMarkers);
        });
      }

      // Cargar el resto en segundo plano
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final resto = gasolinerasEnRadio.skip(10).toList();
          final restoMarkers = resto.map((g) => _crearMarcador(g)).toSet();

          setState(() {
            _gasolinerasMarkers.addAll(restoMarkers);
            _isLoadingProgressively = false;
          });
        }
      });

      return;
    }

    final topGasolineras = gasolinerasEnRadio;
=======
    final topGasolineras = gasolinerasCercanas
        .take(LIMIT_RESULTS)
        .map((e) => e['gasolinera'] as Gasolinera)
        .toList();
>>>>>>> origin/main

    final newMarkers = topGasolineras.map((g) => _crearMarcador(g)).toSet();

    if (mounted) {
      setState(() {
        _gasolinerasMarkers.clear();
        _gasolinerasMarkers.addAll(newMarkers);
      });
    }
  }

  Marker _crearMarcador(Gasolinera gasolinera) {
    bool esFavorita = _favoritosIds.contains(gasolinera.id);

    // Logic for price color removed as we now use static icons
    // final formatter is still used for snippet

    BitmapDescriptor icon;

    // 1. Si es favorita y tenemos el icono de favoritos cargado, usamos ese
    if (esFavorita && _favoriteGasStationIcon != null) {
      icon = _favoriteGasStationIcon!;
    }
    // 2. Para el resto de gasolineras, usar el icono "location_9351238"
    else if (_gasStationIcon != null) {
      icon = _gasStationIcon!;
    }
    // 3. Fallback solo si falla la carga de assets
    else {
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    return Marker(
      markerId: MarkerId('eess_${gasolinera.id}'),
      position: gasolinera.position,
      icon: icon,
      onTap: () {
        _mostrarInfoGasolinera(gasolinera, esFavorita);
      },
    );
  }

  // Nuevo método para mostrar el bocadillo con la estrella
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
<<<<<<< HEAD
                  Expanded(
                    child: Text(
                      gasolinera.rotulo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
=======
                  Text(
                    gasolinera.rotulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
>>>>>>> origin/main
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _toggleFavorito(gasolinera.id);
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
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                    ),
                  if (gasolinera.gasoleoA > 0)
                    _buildPrecioItem(
                      'Diesel',
                      gasolinera.gasoleoA,
                      Icons.directions_car,
                      Colors.black,
                    ),
                  if (gasolinera.gasolina98 > 0)
                    _buildPrecioItem(
                      'Gasolina 98',
                      gasolinera.gasolina98,
                      Icons.local_gas_station,
                      Colors.blue,
                    ),
                  if (gasolinera.glp > 0)
                    _buildPrecioItem(
                      'GLP',
                      gasolinera.glp,
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Botón para añadir/eliminar de favoritos
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _toggleFavorito(gasolinera.id);
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
<<<<<<< HEAD
                    backgroundColor:
                        esFavorita ? Colors.red : const Color(0xFFFF9350),
=======
                    backgroundColor: esFavorita
                        ? Colors.red
                        : const Color(0xFFFF9350),
>>>>>>> origin/main
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

  Future<void> _toggleFavorito(String gasolineraId) async {
    final prefs = await SharedPreferences.getInstance();
    final idsFavoritos = prefs.getStringList('favoritas_ids') ?? [];

    if (idsFavoritos.contains(gasolineraId)) {
      idsFavoritos.remove(gasolineraId);
    } else {
      idsFavoritos.add(gasolineraId);
    }

    await prefs.setStringList('favoritas_ids', idsFavoritos);

    if (mounted) {
      setState(() {
        _favoritosIds = idsFavoritos;
      });
    }
  }

  Widget _buildPrecioItem(
    String nombre,
    double precio,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            '$nombre: ',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const Spacer(),
          Text(
            '${precio.toStringAsFixed(3)}€',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _iniciarSeguimiento() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      if (mounted) {
        setState(() {
          _ubicacionActual = posicion;
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('yo'),
              position: LatLng(posicion.latitude, posicion.longitude),
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
        });
<<<<<<< HEAD
        _cargarGasolineras(posicion.latitude, posicion.longitude,
            isInitialLoad: true);
=======
        _cargarGasolineras(posicion.latitude, posicion.longitude);
>>>>>>> origin/main

        if (widget.onLocationUpdate != null) {
          widget.onLocationUpdate!(posicion.latitude, posicion.longitude);
        }
      }
    } catch (e) {
      // ignore
    }

<<<<<<< HEAD
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

      if (widget.onLocationUpdate != null) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            widget.onLocationUpdate!(pos.latitude, pos.longitude);
          }
        });
      }
    });
=======
    _positionStreamSub =
        Geolocator.getPositionStream(
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

          if (widget.onLocationUpdate != null) {
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(seconds: 2), () {
              if (mounted) {
                widget.onLocationUpdate!(pos.latitude, pos.longitude);
              }
            });
          }
        });
>>>>>>> origin/main
  }

  @override
  Widget build(BuildContext context) {
    if (_ubicacionActual == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final allMarkers = _markers.union(_gasolinerasMarkers);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 300,
        child: GoogleMap(
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
<<<<<<< HEAD
                    final visibleRegion =
                        await mapController!.getVisibleRegion();
                    final centerLat = (visibleRegion.northeast.latitude +
                            visibleRegion.southwest.latitude) /
                        2;
                    final centerLng = (visibleRegion.northeast.longitude +
                            visibleRegion.southwest.longitude) /
                        2;
                    await _cargarGasolineras(centerLat, centerLng,
                        isInitialLoad: false);
=======
                    final visibleRegion = await mapController!
                        .getVisibleRegion();
                    final centerLat =
                        (visibleRegion.northeast.latitude +
                            visibleRegion.southwest.latitude) /
                        2;
                    final centerLng =
                        (visibleRegion.northeast.longitude +
                            visibleRegion.southwest.longitude) /
                        2;
                    await _cargarGasolineras(centerLat, centerLng);
>>>>>>> origin/main
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _debounceTimer?.cancel();
    _cameraDebounceTimer?.cancel();

    // ✅ CORRECCIÓN: Soluciona el error "Maps cannot be retrieved before calling buildView!" en Flutter Web
    // Posponemos el dispose para evitar el conflicto del ciclo de vida.
    if (mapController != null) {
      Future.delayed(Duration.zero, () {
        mapController!.dispose();
      });
    }

    super.dispose();
  }
}
