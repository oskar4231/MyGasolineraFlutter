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
          width: 24,  // Ajusta el tamaño según necesites
          height: 24,
          color: Colors.white,  // Opcional: para cambiar el color
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// El resto del código de MapWidget se mantiene igual...
class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

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
  static const int LIMIT_RESULTS = 10;

  @override
  void initState() {
    super.initState();
    _loadGasStationIcon();
    _iniciarSeguimiento();
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
      // Si no existe o falla, dejamos el fallback por defecto.
    }
  }

Future<void> _cargarGasolineras(double lat, double lng) async {
    final listaGasolineras = await fetchGasolineras(); 

    final gasolinerasCercanas = listaGasolineras.map((g) {
      final distance = Geolocator.distanceBetween(
        lat, 
        lng, 
        g.lat, 
        g.lng
      );
      return {'gasolinera': g, 'distance': distance};
    })
    .toList();

    gasolinerasCercanas.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    final top20Gasolineras = gasolinerasCercanas.take(LIMIT_RESULTS).map((e) => e['gasolinera'] as Gasolinera).toList();

    final newMarkers = top20Gasolineras.map((g) => _crearMarcador(g)).toSet();

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

    final price95Val = gasolinera.precioGasolina95;
    final priceDieselVal = gasolinera.precioGasoleoA;

    final precio95Str = price95Val > 0 ? formatter.format(price95Val) : 'N/A';
    final precioDieselStr = priceDieselVal > 0 ? formatter.format(priceDieselVal) : 'N/A';

    final snippetText = '⛽ G95: $precio95Str\n'
        '🚚 Diésel: $precioDieselStr';

    double avgPrice = 0.0;
    int count = 0;
    if (price95Val > 0) {
      avgPrice += price95Val;
      count++;
    }
    if (priceDieselVal > 0) {
      avgPrice += priceDieselVal;
      count++;
    }
    avgPrice = count > 0 ? avgPrice / count : 0.0;

    final double hue;
    if (avgPrice == 0.0) {
      hue = BitmapDescriptor.hueViolet;
    } else if (avgPrice <= 1.50) {
      hue = BitmapDescriptor.hueGreen;
    } else if (avgPrice <= 1.90) {
      hue = BitmapDescriptor.hueOrange;
    } else {
      hue = BitmapDescriptor.hueRed;
    }

    return Marker(
      markerId: MarkerId('eess_${gasolinera.id}'),
      position: gasolinera.position,
      infoWindow: InfoWindow(
        title: gasolinera.rotulo,
        snippet: snippetText,
      ),
      icon: _gasStationIcon ?? BitmapDescriptor.defaultMarkerWithHue(hue),
    );
  }

  Future<void> _iniciarSeguimiento() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicio de ubicación deshabilitado')));
      }
      return;
    }
  

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso de ubicación denegado')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso de ubicación denegado permanentemente')));
      }
      return;
    }

    try {
      Position posicion = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (mounted) {
        setState(() {
          _ubicacionActual = posicion;
          _markers.clear();
          _markers.add(Marker(
            markerId: const MarkerId('yo'),
            position: LatLng(posicion.latitude, posicion.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ));
        });
        _cargarGasolineras(posicion.latitude, posicion.longitude);
      }
    } catch (e) {
      // ignore
    }

    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 5),
    ).listen((Position pos) {
      if (!mounted) return;
      setState(() {
        _ubicacionActual = pos;
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('yo'),
          position: LatLng(pos.latitude, pos.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
      });

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ubicacionActual == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final allMarkers = _markers.union(_gasolinerasMarkers);

    return GoogleMap(
      onMapCreated: (controller) {
        mapController = controller;
        if (_ubicacionActual != null) {
          controller.animateCamera(CameraUpdate.newLatLng(LatLng(_ubicacionActual!.latitude, _ubicacionActual!.longitude)));
        }
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(_ubicacionActual!.latitude, _ubicacionActual!.longitude),
        zoom: 15,
      ),
      markers: allMarkers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
    );
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    mapController?.dispose();
    super.dispose();
  }
}