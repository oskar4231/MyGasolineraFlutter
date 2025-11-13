import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
    );
  }
}

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
    } catch (e) {}
  }

  Future<void> _cargarGasolineras(double lat, double lng) async {
    final listaGasolineras = await fetchGasolineras();

    final gasolinerasCercanas = listaGasolineras.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).toList();

    gasolinerasCercanas.sort((a, b) =>
        (a['distance'] as double).compareTo(b['distance'] as double));

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
    final precios = [
      gasolinera.gasolina95,
      gasolinera.gasoleoA,
      gasolinera.gasolina98,
      gasolinera.glp,
      gasolinera.gasoleoPremium,
    ];
    final preciosValidos = precios.where((p) => p > 0).toList();
    final avgPrice = preciosValidos.isNotEmpty
        ? preciosValidos.reduce((a, b) => a + b) / preciosValidos.length
        : 0.0;

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
      icon: _gasStationIcon ?? BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: gasolinera.rotulo,
        snippet: _buildSnippet(gasolinera),
      ),
    );
  }

  String _buildSnippet(Gasolinera g) {
    final precios = [
      if (g.gasolina95 > 0) "⛽ G95: ${formatPrecio(g.gasolina95)}",
      if (g.gasoleoA > 0) "🚚 Diésel: ${formatPrecio(g.gasoleoA)}",
      if (g.gasolina98 > 0) "⛽ G98: ${formatPrecio(g.gasolina98)}",
      if (g.glp > 0) "🔥 GLP: ${formatPrecio(g.glp)}",
      if (g.gasoleoPremium > 0) "🚚 Diésel Premium: ${formatPrecio(g.gasoleoPremium)}",
    ];
    return precios.join("\n");
  }

  String formatPrecio(double precio) {
    return precio > 0 ? "${precio.toStringAsFixed(3)} €" : "No disponible";
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
      Position posicion =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
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
    } catch (e) {}

    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 5),
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
        mapController!.animateCamera(
            CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)));
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
              controller.animateCamera(CameraUpdate.newLatLng(
                LatLng(_ubicacionActual!.latitude, _ubicacionActual!.longitude),
              ));
            }
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
    mapController?.dispose();
    super.dispose();
  }
}
