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

  bool _isDialogOpen = false;

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
      onTap: () => _mostrarDialogoPrecios(gasolinera),  
    );
  }

  void _mostrarDialogoPrecios(Gasolinera gasolinera) {
    if (_isDialogOpen) return;

    final precio95 = formatPrecio(gasolinera.gasolina95);
    final precio95E10 = formatPrecio(gasolinera.gasolina95E10);
    final precio98 = formatPrecio(gasolinera.gasolina98);
    final precioDiesel = formatPrecio(gasolinera.gasoleoA);
    final precioDieselPremium = formatPrecio(gasolinera.gasoleoPremium);
    final precioGLP = formatPrecio(gasolinera.glp);
    final precioBiodiesel = formatPrecio(gasolinera.biodiesel);
    final precioBioetanol = formatPrecio(gasolinera.bioetanol);
    final precioEsterMetilico = formatPrecio(gasolinera.esterMetilico);
    final precioHidrogeno = formatPrecio(gasolinera.hidrogeno);

    _isDialogOpen = true;  

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(gasolinera.rotulo),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Precios:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (precio95 != 'No disponible') Text('- ⛽ G95: $precio95'),
                if (precio95E10 != 'No disponible') Text('- ⛽ G95 E10: $precio95E10'),
                if (precio98 != 'No disponible') Text('- ⛽ G98: $precio98'),
                if (precioDiesel != 'No disponible') Text('- 🚚 Diésel: $precioDiesel'),
                if (precioDieselPremium != 'No disponible') Text('- 🚚 Diésel Premium: $precioDieselPremium'),
                if (precioGLP != 'No disponible') Text('- 🔥 GLP: $precioGLP'),
                if (precioBiodiesel != 'No disponible') Text('- 🌱 Biodiésel: $precioBiodiesel'),
                if (precioBioetanol != 'No disponible') Text('- 🍃 Bioetanol: $precioBioetanol'),
                if (precioEsterMetilico != 'No disponible') Text('- 🧪 Éster metílico: $precioEsterMetilico'),
                if (precioHidrogeno != 'No disponible') Text('- ⚡ Hidrógeno: $precioHidrogeno'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _isDialogOpen = false;  
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  String formatPrecio(double precio) {
    return precio > 0 ? "${precio.toStringAsFixed(3)} €" : "No disponible";
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

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: SizedBox(
      height: 300,
      child: Stack(
        children: [
          GoogleMap(
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
          if (_isDialogOpen)
            const ModalBarrier(
              dismissible: false,
              color: Colors.black26,
            ),
        ],
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