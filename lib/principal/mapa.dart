import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Ubicación en Tiempo Real'),
        backgroundColor: Colors.blue,
      ),
      body: const MapWidget(), 
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AjustesScreen()),
          );
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

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? mapController;
  Position? _ubicacionActual;
  StreamSubscription<Position>? _positionStreamSub;
  final Set<Marker> _markers = {};
  final Set<Marker> _gasolinerasMarkers = {};
  BitmapDescriptor? _gasStationIcon;
  Timer? _debounceTimer;
  Timer? _cameraDebounceTimer;

  static const int LIMIT_RESULTS = 50;

  @override
  void initState() {
    super.initState();
    _loadGasStationIcon();
    _iniciarSeguimiento();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si cambiaron los filtros o la lista externa, recargar gasolineras
    if (oldWidget.combustibleSeleccionado != widget.combustibleSeleccionado ||
        oldWidget.precioDesde != widget.precioDesde ||
        oldWidget.precioHasta != widget.precioHasta ||
        oldWidget.tipoAperturaSeleccionado != widget.tipoAperturaSeleccionado ||
        oldWidget.externalGasolineras != widget.externalGasolineras) {
      
      if (_ubicacionActual != null) {
        _cargarGasolineras(_ubicacionActual!.latitude, _ubicacionActual!.longitude);
      }
    }
  }

  Future<void> _loadGasStationIcon() async {
    try {
      final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/assets/location_9351238.png',
      );
      if (mounted) {
        setState(() {
          _gasStationIcon = icon;
        });
      }
    } catch (e) {
      // Manejo de errores
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

  List<Gasolinera> _aplicarFiltros(List<Gasolinera> gasolineras) {
    List<Gasolinera> resultado = gasolineras;

    // 1. Filtro de combustible y precio
    if (widget.combustibleSeleccionado != null) {
      resultado = resultado.where((g) {
        double precio = _obtenerPrecioCombustible(g, widget.combustibleSeleccionado!);
        
        if (precio == 0.0) return false; 

        if (widget.precioDesde != null && precio < widget.precioDesde!) return false;
        if (widget.precioHasta != null && precio > widget.precioHasta!) return false;

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

  Future<void> _cargarGasolineras(double lat, double lng) async {
    List<Gasolinera> listaGasolineras;

    if (widget.externalGasolineras != null && widget.externalGasolineras!.isNotEmpty) {
      listaGasolineras = widget.externalGasolineras!;
    } else {
      listaGasolineras = await fetchGasolineras();
    }

    listaGasolineras = _aplicarFiltros(listaGasolineras);

    final gasolinerasCercanas = listaGasolineras.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).toList();

    gasolinerasCercanas.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    final topGasolineras = gasolinerasCercanas
        .take(LIMIT_RESULTS)
        .map((e) => e['gasolinera'] as Gasolinera)
        .toList();

    final newMarkers = topGasolineras.map((g) => _crearMarcador(g)).toSet();

    if (mounted) {
      setState(() {
        _gasolinerasMarkers.clear();
        _gasolinerasMarkers.addAll(newMarkers);
      });
    }
  }

  Marker _crearMarcador(Gasolinera gasolinera) {
    final formatter = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '€',
      decimalDigits: 3,
    );

    double precioParaColor = 0.0;
    if (widget.combustibleSeleccionado != null) {
       precioParaColor = _obtenerPrecioCombustible(gasolinera, widget.combustibleSeleccionado!);
    } else {
      final precios = [
        gasolinera.gasolina95,
        gasolinera.gasoleoA,
        gasolinera.gasolina98,
        gasolinera.glp,
        gasolinera.gasoleoPremium,
      ];
      final preciosValidos = precios.where((p) => p > 0).toList();
      precioParaColor = preciosValidos.isNotEmpty
          ? preciosValidos.reduce((a, b) => a + b) / preciosValidos.length
          : 0.0;
    }

    final double hue;
    if (precioParaColor == 0.0) {
      hue = BitmapDescriptor.hueViolet;
    } else if (precioParaColor <= 1.50) {
      hue = BitmapDescriptor.hueGreen;
    } else if (precioParaColor <= 1.70) {
      hue = BitmapDescriptor.hueOrange;
    } else {
      hue = BitmapDescriptor.hueRed;
    }

    return Marker(
      markerId: MarkerId('eess_${gasolinera.id}'),
      position: gasolinera.position,
      icon: _gasStationIcon ?? BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: gasolinera.rotulo,
        snippet: _buildSnippet(gasolinera, formatter),
      ),
    );
  }

  String _buildSnippet(Gasolinera g, NumberFormat formatter) {
    String horarioInfo = g.es24Horas ? "🕒 24H" : (g.estaAbiertaAhora ? "🕒 Abierto" : "🕒 Cerrado");
    
    final precios = [
      horarioInfo,
      if (g.gasolina95 > 0) "⛽ G95: ${formatter.format(g.gasolina95)}",
      if (g.gasoleoA > 0) "🚚 Diésel: ${formatter.format(g.gasoleoA)}",
      if (g.gasolina98 > 0) "⛽ G98: ${formatter.format(g.gasolina98)}",
      if (g.glp > 0) "🔥 GLP: ${formatter.format(g.glp)}",
    ];
    return precios.join("\n");
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
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          );
        });
        _cargarGasolineras(posicion.latitude, posicion.longitude);

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
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
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
                CameraUpdate.newLatLng(LatLng(_ubicacionActual!.latitude, _ubicacionActual!.longitude)),
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
                    final centerLat = (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2;
                    final centerLng = (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2;
                    await _cargarGasolineras(centerLat, centerLng);
                  } catch (e) {}
                }
              },
            );
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(_ubicacionActual!.latitude, _ubicacionActual!.longitude),
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