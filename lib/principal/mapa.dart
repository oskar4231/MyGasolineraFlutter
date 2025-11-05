import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapaTiempoReal extends StatefulWidget {
  @override
  _MapaTiempoRealState createState() => _MapaTiempoRealState();
}

class _MapaTiempoRealState extends State<MapaTiempoReal> {
  GoogleMapController? mapController;
  Position? _ubicacionActual;
  StreamSubscription<Position>? _positionStreamSub;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _iniciarSeguimiento();
  }

  Future<void> _iniciarSeguimiento() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Servicio deshabilitado
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

    // Obtener posición inicial
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
      }
    } catch (e) {
      // ignore errors for initial position
    }

    // Iniciar stream para actualizaciones en tiempo real
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

      // Mover la cámara si el controlador ya está listo
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Ubicación en Tiempo Real'),
        backgroundColor: Colors.blue,
      ),
      body: _ubicacionActual == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
                // Si ya tenemos ubicación, centrar la cámara
                if (_ubicacionActual != null) {
                  controller.animateCamera(CameraUpdate.newLatLng(LatLng(_ubicacionActual!.latitude, _ubicacionActual!.longitude)));
                }
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _ubicacionActual!.latitude,
                  _ubicacionActual!.longitude,
                ),
                zoom: 17,
              ),
              markers: _markers,
              myLocationEnabled: true, // Muestra el botón de ubicación
              myLocationButtonEnabled: true,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moverACurrent,
        child: const Icon(Icons.gps_fixed),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _moverACurrent() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo obtener la ubicación')));
      }
    }
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    mapController?.dispose();
    super.dispose();
  }
}