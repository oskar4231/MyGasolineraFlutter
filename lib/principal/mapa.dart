import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/principal/gasolineras/api_gasolinera.dart';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';

class MapaTiempoReal extends StatefulWidget {
  const MapaTiempoReal({super.key});

  @override
  _MapaTiempoRealState createState() => _MapaTiempoRealState();
}

class _MapaTiempoRealState extends State<MapaTiempoReal> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa de Gasolineras',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: const MapWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AjustesScreen()),
          );
        },
        backgroundColor: primaryColor,
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
  final String? combustibleSeleccionado;
  final double? precioDesde;
  final double? precioHasta;
  final String? tipoAperturaSeleccionado;

  const MapWidget({
    super.key,
    this.externalGasolineras,
    this.onLocationUpdate,
    this.combustibleSeleccionado,
    this.precioDesde,
    this.precioHasta,
    this.tipoAperturaSeleccionado,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with AutomaticKeepAliveClientMixin {
  GoogleMapController? mapController;
  Position? _ubicacionActual;
  StreamSubscription<Position>? _positionStreamSub;
  
  // --- MEMORIA PERSISTENTE ---
  // Esta variable estática sobrevive al cambio de tema (reconstrucción del widget)
  // Así evitamos que el mapa vuelva a Madrid al cambiar a modo oscuro
  static Position? _memoriaUbicacion; 

  final Set<Marker> _markers = {};
  final Set<Marker> _gasolinerasMarkers = {};
  BitmapDescriptor? _gasStationIcon;
  BitmapDescriptor? _favoriteGasStationIcon;
  List<String> _favoritosIds = [];
  bool _isBottomSheetOpen = false;
  
  Timer? _debounceTimer;

  // Ubicación por defecto (Madrid) - Solo se usa si no hay NADA en memoria
  final LatLng _defaultPos = const LatLng(40.416775, -3.703790); 
  bool _isLocating = true;

  static const int LIMIT_RESULTS = 50;

  final String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#746855"}]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [{"color": "#263c3f"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#6b9a76"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#38414e"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#212a37"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9ca5b3"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#746855"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#1f2835"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#f3d19c"}]
    },
    {
      "featureType": "transit",
      "elementType": "geometry",
      "stylers": [{"color": "#2f3948"}]
    },
    {
      "featureType": "transit.station",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#17263c"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#515c6d"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#17263c"}]
    }
  ]
  ''';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    // 1. CARGA INMEDIATA DE MEMORIA (Para evitar el salto a Madrid)
    if (_memoriaUbicacion != null) {
      _ubicacionActual = _memoriaUbicacion;
      _isLocating = false;
      // Actualizamos marcadores inmediatamente con la memoria
      _actualizarMarcadorUsuario(_ubicacionActual!.latitude, _ubicacionActual!.longitude);
    }

    _loadGasStationIcon();
    _cargarFavoritos();
    _iniciarSeguimiento();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.combustibleSeleccionado != widget.combustibleSeleccionado ||
        oldWidget.precioDesde != widget.precioDesde ||
        oldWidget.precioHasta != widget.precioHasta ||
        oldWidget.tipoAperturaSeleccionado != widget.tipoAperturaSeleccionado ||
        oldWidget.externalGasolineras != widget.externalGasolineras) {
      if (_ubicacionActual != null) {
        _cargarGasolineras(_ubicacionActual!.latitude, _ubicacionActual!.longitude);
      } else {
        _cargarGasolineras(_defaultPos.latitude, _defaultPos.longitude);
      }
    }
  }

  Future<void> _cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favoritas_ids') ?? [];
    if (mounted) setState(() => _favoritosIds = ids);
  }

  Future<void> _loadGasStationIcon() async {
    try {
      final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)), 'lib/assets/location_9351238.png');
      final favIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)), 'lib/assets/localizacion_favs.png');
      if (mounted) setState(() { _gasStationIcon = icon; _favoriteGasStationIcon = favIcon; });
    } catch (e) {}
  }

  Future<void> _iniciarSeguimiento() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (_ubicacionActual == null) _usarUbicacionPorDefecto();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (_ubicacionActual == null) _usarUbicacionPorDefecto();
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (_ubicacionActual == null) _usarUbicacionPorDefecto();
      return;
    }

    // Si no tenemos ni memoria ni ubicación actual, intentamos Caché del sistema
    if (_ubicacionActual == null) {
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null && mounted) {
          _actualizarPosicion(lastPosition, animar: true);
        }
      } catch (e) {
        print(e);
      }
    }

    // Buscamos ubicación precisa
    try {
      Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, 
        timeLimit: const Duration(seconds: 10),
      );
      if (mounted) {
        _actualizarPosicion(posicion, animar: true);
      }
    } catch (e) {
      // Si falla GPS pero tenemos memoria o caché, NO hacemos nada (nos quedamos ahí).
      // Solo si es null total vamos a Madrid.
      if (_ubicacionActual == null) {
        _usarUbicacionPorDefecto();
      } else {
        if (mounted) setState(() => _isLocating = false);
      }
    }

    // Stream para cambios
    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high, 
        distanceFilter: 20, 
      ),
    ).listen((Position pos) {
      if (mounted) {
        _actualizarPosicion(pos, animar: false);
      }
    });
  }

  void _actualizarPosicion(Position pos, {bool animar = true}) {
    // GUARDAMOS EN MEMORIA ESTÁTICA
    _memoriaUbicacion = pos;

    setState(() {
      _ubicacionActual = pos;
      _isLocating = false;
      _actualizarMarcadorUsuario(pos.latitude, pos.longitude);
    });
    
    if (animar) {
      mapController?.animateCamera(CameraUpdate.newLatLng(
        LatLng(pos.latitude, pos.longitude)
      ));
    }
    _cargarGasolineras(pos.latitude, pos.longitude);
    
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
        widget.onLocationUpdate?.call(pos.latitude, pos.longitude);
    });
  }

  void _usarUbicacionPorDefecto() {
    if (!mounted) return;
    
    // Si ya tenemos una ubicación válida en memoria, NO usamos Madrid
    if (_memoriaUbicacion != null) return;

    final defaultPosition = Position(
      latitude: _defaultPos.latitude,
      longitude: _defaultPos.longitude,
      timestamp: DateTime.now(),
      accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0
    );

    setState(() {
      _ubicacionActual = defaultPosition;
      _isLocating = false;
      _actualizarMarcadorUsuario(_defaultPos.latitude, _defaultPos.longitude);
    });

    _cargarGasolineras(_defaultPos.latitude, _defaultPos.longitude);
    mapController?.moveCamera(CameraUpdate.newLatLng(_defaultPos));
  }

  void _actualizarMarcadorUsuario(double lat, double lng) {
    _markers.removeWhere((m) => m.markerId.value == 'yo');
    _markers.add(
      Marker(
        markerId: const MarkerId('yo'),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarker,
        zIndex: 2.0,
        infoWindow: const InfoWindow(title: "Mi Ubicación"),
      ),
    );
  }

  Future<void> _cargarGasolineras(double lat, double lng) async {
    List<Gasolinera> listaGasolineras = (widget.externalGasolineras != null && widget.externalGasolineras!.isNotEmpty)
        ? widget.externalGasolineras!
        : await fetchGasolineras();

    listaGasolineras = _aplicarFiltros(listaGasolineras);

    final gasolinerasCercanas = listaGasolineras.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).toList();

    gasolinerasCercanas.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    final topGasolineras = gasolinerasCercanas.take(LIMIT_RESULTS).map((e) => e['gasolinera'] as Gasolinera).toList();
    final newMarkers = topGasolineras.map((g) => _crearMarcador(g)).toSet();

    if (mounted) {
      setState(() {
        _gasolinerasMarkers.clear();
        _gasolinerasMarkers.addAll(newMarkers);
      });
    }
  }

  double _obtenerPrecioCombustible(Gasolinera g, String tipoCombustible) {
    switch (tipoCombustible) {
      case 'Gasolina 95': return g.gasolina95;
      case 'Gasolina 98': return g.gasolina98;
      case 'Diesel': return g.gasoleoA;
      case 'Diesel Premium': return g.gasoleoPremium;
      case 'Gas': return g.glp;
      default: return 0.0;
    }
  }

  List<Gasolinera> _aplicarFiltros(List<Gasolinera> lista) {
    List<Gasolinera> res = lista;
    if (widget.combustibleSeleccionado != null) {
      res = res.where((g) {
        double p = _obtenerPrecioCombustible(g, widget.combustibleSeleccionado!);
        if (p == 0.0) return false;
        if (widget.precioDesde != null && p < widget.precioDesde!) return false;
        if (widget.precioHasta != null && p > widget.precioHasta!) return false;
        return true;
      }).toList();
    }
    if (widget.tipoAperturaSeleccionado != null) {
      res = res.where((g) {
        switch (widget.tipoAperturaSeleccionado) {
          case '24 Horas': return g.es24Horas;
          case 'Gasolineras atendidas por personal': return !g.es24Horas;
          case 'Gasolineras abiertas ahora': return g.estaAbiertaAhora;
          case 'Todas': return true;
          default: return true;
        }
      }).toList();
    }
    return res;
  }

  Marker _crearMarcador(Gasolinera g) {
    bool fav = _favoritosIds.contains(g.id);
    BitmapDescriptor icon;
    if (fav && _favoriteGasStationIcon != null) icon = _favoriteGasStationIcon!;
    else if (_gasStationIcon != null) icon = _gasStationIcon!;
    else icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

    return Marker(
      markerId: MarkerId('eess_${g.id}'),
      position: g.position,
      icon: icon,
      zIndex: 1.0,
      onTap: () => _mostrarInfoGasolinera(g, fav),
    );
  }

  Future<void> _mostrarInfoGasolinera(Gasolinera gasolinera, bool esFavorita) async {
    if (_isBottomSheetOpen) return;
    setState(() => _isBottomSheetOpen = true);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey[600];

    await showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gasolinera.rotulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 10),
              Text(gasolinera.direccion, style: TextStyle(color: subtitleColor)),
              const SizedBox(height: 20),
              if (gasolinera.gasolina95 > 0) _buildPrecioItem("Gasolina 95", gasolinera.gasolina95, Icons.local_gas_station, Colors.green, textColor, subtitleColor!),
              if (gasolinera.gasoleoA > 0) _buildPrecioItem("Diesel", gasolinera.gasoleoA, Icons.directions_car, Colors.black, textColor, subtitleColor!),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _toggleFavorito(gasolinera.id);
                    Navigator.pop(context);
                  },
                  icon: Icon(esFavorita ? Icons.star : Icons.star_border, color: Colors.white),
                  label: Text(esFavorita ? 'Eliminar de favoritos' : 'Añadir a favoritos', style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: esFavorita ? Colors.red : (isDark ? Colors.grey[800] : const Color(0xFFFF9350)),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (mounted) setState(() => _isBottomSheetOpen = false);
  }

  Future<void> _toggleFavorito(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favoritas_ids') ?? [];
    if (ids.contains(id)) ids.remove(id); else ids.add(id);
    await prefs.setStringList('favoritas_ids', ids);
    if (mounted) setState(() => _favoritosIds = ids);
  }

  Widget _buildPrecioItem(String n, double p, IconData i, Color ic, Color tc, Color sc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(i, size: 20, color: ic),
        const SizedBox(width: 8),
        Text('$n: ', style: TextStyle(fontSize: 16, color: sc)),
        const Spacer(),
        Text('${p.toStringAsFixed(3)}€', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tc)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (mapController != null) {
      mapController!.setMapStyle(isDark ? _darkMapStyle : "[]");
    }

    // AQUÍ ESTÁ EL TRUCO: Si tenemos memoria, usamos memoria. Si no, default.
    final LatLng targetPosition = _ubicacionActual != null
        ? LatLng(_ubicacionActual!.latitude, _ubicacionActual!.longitude)
        : _defaultPos;

    final allMarkers = _markers.union(_gasolinerasMarkers);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (c) {
                mapController = c;
                c.setMapStyle(isDark ? _darkMapStyle : "[]");
                
                // Si tenemos ubicación (de memoria o GPS), vamos a ella directo
                if (_ubicacionActual != null) {
                  c.moveCamera(CameraUpdate.newLatLng(targetPosition));
                }
              },
              initialCameraPosition: CameraPosition(
                target: targetPosition,
                zoom: 15,
              ),
              markers: allMarkers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
            
            // Solo mostramos loader si NO tenemos ubicación NI en memoria
            if (_isLocating && _ubicacionActual == null)
              Positioned(
                bottom: 20, left: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: const [
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    SizedBox(width: 10),
                    Text("Buscando GPS...", style: TextStyle(color: Colors.white))
                  ]),
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}