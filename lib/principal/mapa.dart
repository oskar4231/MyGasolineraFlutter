import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/principal/gasolineras/api_gasolinera.dart' as api;
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';
import 'package:my_gasolinera/main.dart' as app;
import 'package:my_gasolinera/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/services/provincia_service.dart';

class MapaTiempoReal extends StatefulWidget {
  const MapaTiempoReal({super.key});

  @override
  _MapaTiempoRealState createState() => _MapaTiempoRealState();
}

class _MapaTiempoRealState extends State<MapaTiempoReal> {
  double _radiusKm = 25.0;
  final Key _mapKey = UniqueKey(); // Para forzar reconstrucción si es necesario

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Ubicación en Tiempo Real',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: MapWidget(
        key: _mapKey,
        radiusKm: _radiusKm,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AjustesScreen()),
          ).then((_) {
            // Recargar preferencias al volver de ajustes
            _cargarPreferencias();
          });
        },
        backgroundColor: theme.colorScheme.primary,
        child: Image.asset(
          'lib/assets/ajustes.png',
          width: 24,
          height: 24,
          color: theme.colorScheme.onPrimary,
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
  final double radiusKm; // Nuevo parámetro

  const MapWidget({
    super.key,
    this.externalGasolineras,
    this.onLocationUpdate,
    this.combustibleSeleccionado,
    this.precioDesde,
    this.precioHasta,
    this.tipoAperturaSeleccionado,
    this.radiusKm = 25.0, // Valor por defecto
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

  // Cache service y provincia
  late GasolinerasCacheService _cacheService;
  String? _currentProvinciaId;
  bool _isLoadingFromCache = false;

  // Para carga progresiva
  bool _isLoadingProgressively = false;

  @override
  void initState() {
    super.initState();
    _cacheService = GasolinerasCacheService(app.database);
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
        oldWidget.externalGasolineras != widget.externalGasolineras ||
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

  Future<void> _cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favoritas_ids') ?? [];
    if (mounted) {
      setState(() {
        _favoritosIds = ids;
      });
    }
  }

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

      if (mounted) {
        setState(() {
          _gasStationIcon = icon;
          _favoriteGasStationIcon = favIcon;
        });
      }
    } catch (e) {
      // Manejo de errores
      print('Error cargando iconos: $e');
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

  Future<void> _cargarGasolineras(double lat, double lng,
      {bool isInitialLoad = false}) async {
    List<Gasolinera> listaGasolineras;

    if (widget.externalGasolineras != null &&
        widget.externalGasolineras!.isNotEmpty) {
      listaGasolineras = widget.externalGasolineras!;
    } else {
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
            '🔎 DEBUG Mapa: Provincia detectada para ($lat, $lng): ${provinciaInfo.nombre} (ID: $_currentProvinciaId)');

        print(
            'Mapa: Cargando gasolineras para provincia ${provinciaInfo.nombre}');

        // Cargar gasolineras de la provincia actual y vecinas
        final vecinas = ProvinciaService.getProvinciasVecinas(provinciaInfo.id);
        final provinciasToLoad = [provinciaInfo.id, ...vecinas.take(2)];

        listaGasolineras = await _cacheService.getGasolinerasMultiProvincia(
          provinciasToLoad,
          forceRefresh: false, // Usar caché para mejor rendimiento
        );

        print(
            'Mapa: Cargadas ${listaGasolineras.length} gasolineras desde cache');
      } catch (e) {
        print('Mapa: Error al cargar desde cache, usando API: $e');
        // Usar API con filtro de provincia en lugar de todas las gasolineras
        print('Mapa: Error al cargar desde cache, usando API: $e');

        // Intentar detectar provincia de nuevo para asegurar que tenemos la correcta para ESTA ubicación
        try {
          final detectedInfo =
              await ProvinciaService.getProvinciaFromCoordinates(lat, lng);
          _currentProvinciaId = detectedInfo.id;
          print(
              'Mapa: (Fallback API) Provincia detectada: ${detectedInfo.nombre} ($_currentProvinciaId)');
        } catch (e2) {
          print('Mapa: Error al re-detectar provincia en catch: $e2');
        }

        if (_currentProvinciaId != null) {
          listaGasolineras =
              await api.fetchGasolinerasByProvincia(_currentProvinciaId!);
        } else {
          print(
              'Mapa: No se pudo determinar provincia, cargando lista vacía o default');
          // Opcional: cargar todas o Madrid por defecto si falla todo
          listaGasolineras = [];
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingFromCache = false;
          });
        }
      }
    }

    listaGasolineras = _aplicarFiltros(listaGasolineras);

    print(
        '📍 Filtrando ${listaGasolineras.length} gasolineras por radio de ${widget.radiusKm} km');

    if (listaGasolineras.isNotEmpty) {
      print('🔍 DEBUG: Primeras 3 gasolineras recibidas (sin filtrar):');
      for (var i = 0;
          i < (listaGasolineras.length > 3 ? 3 : listaGasolineras.length);
          i++) {
        final g = listaGasolineras[i];
        print('   - ${g.rotulo}: ${g.lat}, ${g.lng} (Prov: ${g.provincia})');
      }
    }

    print('📍 Calculando distancias desde origen: $lat, $lng');

    // Calcular distancias y filtrar por radio
    final gasolinerasCercanas = listaGasolineras.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).where((item) {
      final distance = item['distance'] as double;
      // DEBUG: Imprimir distancia de los primeros 3 elementos antes de filtrar
      if (listaGasolineras.indexOf(item['gasolinera'] as Gasolinera) < 3) {
        print(
            '   -> Distancia a ${(item['gasolinera'] as Gasolinera).rotulo}: ${distance.toStringAsFixed(2)} metros (${(distance / 1000).toStringAsFixed(2)} km)');
      }

      // Filtrar por radio (convertir metros a km)
      final distanceKm = distance / 1000;
      return distanceKm <= widget.radiusKm;
    }).toList();

    // Ordenar por distancia
    gasolinerasCercanas.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    final gasolinerasEnRadio =
        gasolinerasCercanas.map((e) => e['gasolinera'] as Gasolinera).toList();

    print(
        'Mapa: Mostrando ${gasolinerasEnRadio.length} gasolineras en radio de ${widget.radiusKm}km');

    // Carga progresiva: SOLO en carga inicial para dar feedback rápido
    if (isInitialLoad &&
        !_isLoadingProgressively &&
        gasolinerasEnRadio.length > 10) {
      if (mounted) {
        setState(() {
          _isLoadingProgressively = true;
        });
      }

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
                    ),
                  if (gasolinera.gasoleoA > 0)
                    _buildPrecioItem(
                      'Diesel',
                      gasolinera.gasoleoA,
                      Icons.directions_car,
                      Theme.of(context).colorScheme.onSurface,
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
        _cargarGasolineras(posicion.latitude, posicion.longitude,
            isInitialLoad: true);

        if (widget.onLocationUpdate != null) {
          widget.onLocationUpdate!(posicion.latitude, posicion.longitude);
        }
      }
    } catch (e) {
      // ignore
    }

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
    // ✅ CORRECCIÓN: Soluciona el error "Maps cannot be retrieved before calling buildView!" en Flutter Web
    // En web evita llamar a dispose manual del controller.
    // if (mapController != null) {
    //   Future.delayed(Duration.zero, () {
    //     mapController!.dispose();
    //   });
    // }

    super.dispose();
  }
}
