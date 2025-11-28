import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_gasolinera/principal/gasolineras/api_gasolinera.dart';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';
import 'package:my_gasolinera/principal/lista.dart';
import 'mapa.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/coches/coches.dart';

class Layouthome extends StatefulWidget {
  const Layouthome({super.key});

  @override
  State<Layouthome> createState() => _LayouthomeState();
}

class _LayouthomeState extends State<Layouthome> {
  bool _showMap = true;
  List<Gasolinera> _allGasolineras = [];
  List<Gasolinera> _gasolinerasCercanas = [];
  bool _loading = false;
  Position? _currentPosition;
  DateTime _lastUpdateTime = DateTime.now();
  static const Duration MIN_UPDATE_INTERVAL = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _initLocationAndGasolineras();
  }

  Future<void> _initLocationAndGasolineras() async {
    setState(() {
      _loading = true;
    });

    try {
      // 1. Obtener ubicación
      await _getCurrentLocation();

      // 2. Cargar todas las gasolineras
      final lista = await fetchGasolineras();

      if (mounted) {
        setState(() {
          _allGasolineras = lista;
        });
      }

      // 3. Calcular las 15 más cercanas
      if (_currentPosition != null) {
        _calcularGasolinerasCercanas();
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Servicio de ubicación deshabilitado');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permiso de ubicación denegado');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permiso de ubicación denegado permanentemente');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
      print('Ubicación obtenida: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _calcularGasolinerasCercanas() {
    if (_currentPosition == null || _allGasolineras.isEmpty) {
      print('No hay ubicación o gasolineras para calcular');
      return;
    }

    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;

    print('Calculando gasolineras cercanas para: $lat, $lng');
    print('Total gasolineras disponibles: ${_allGasolineras.length}');

    // Calcular distancia para cada gasolinera
    final gasolinerasConDistancia = _allGasolineras.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).toList();

    // Ordenar por distancia y tomar las 15 más cercanas
    gasolinerasConDistancia.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    final top15 = gasolinerasConDistancia
        .take(15)
        .map((e) => e['gasolinera'] as Gasolinera)
        .toList();

    if (mounted) {
      setState(() {
        _gasolinerasCercanas = top15;
      });
    }

    // Debug
    print(
      '[Layouthome] Gasolineras cercanas calculadas: ${_gasolinerasCercanas.length}',
    );
    for (var g in _gasolinerasCercanas) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      print('  - ${g.rotulo} (${(distance / 1000).toStringAsFixed(1)} km)');
    }
  }

  // Callback simplificado - solo recalcular gasolineras cercanas
  void _onLocationUpdated(double lat, double lng) {
    final now = DateTime.now();
    final timeSinceLastUpdate = now.difference(_lastUpdateTime);

    // Solo procesar si ha pasado el tiempo mínimo
    if (timeSinceLastUpdate < MIN_UPDATE_INTERVAL) {
      print(
        '📍 Actualización ignorada - demasiado pronto: ${timeSinceLastUpdate.inSeconds}s',
      );
      return;
    }

    print('Ubicación actualizada desde mapa: $lat, $lng');

    _lastUpdateTime = now;

    if (mounted) {
      // No necesitamos crear un Position manualmente
      // Simplemente recalculamos las gasolineras cercanas con las nuevas coordenadas
      _recalcularConNuevaUbicacion(lat, lng);
    }
  }

  void _recalcularConNuevaUbicacion(double lat, double lng) {
    if (_allGasolineras.isEmpty) return;

    print('Recalculando gasolineras para nueva ubicación: $lat, $lng');

    // Calcular distancia para cada gasolinera con las nuevas coordenadas
    final gasolinerasConDistancia = _allGasolineras.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).toList();

    // Ordenar por distancia y tomar las 15 más cercanas
    gasolinerasConDistancia.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    final top15 = gasolinerasConDistancia
        .take(15)
        .map((e) => e['gasolinera'] as Gasolinera)
        .toList();

    if (mounted) {
      setState(() {
        _gasolinerasCercanas = top15;
      });
    }

    print(
      '[Layouthome] Gasolineras recalculadas: ${_gasolinerasCercanas.length}',
    );
  }

  // Método para forzar recarga
  void _recargarDatos() {
    setState(() {
      _gasolinerasCercanas = [];
    });
    _initLocationAndGasolineras();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFFFE2CE),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            SizedBox(
              height: 60,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFFFF9350)),
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(16),
                child: Text(
                  'Filtros',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
            ListTile(title: Text('Opción 1')),
            ListTile(title: Text('Opción 2')),
            ListTile(title: Text('Opción 3')),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9350),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "MyGasolinera",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9350),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ToggleButtons(
                            isSelected: [_showMap, !_showMap],
                            onPressed: (index) {
                              setState(() {
                                _showMap = index == 0;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            selectedColor: Colors.black,
                            color: Colors.white,
                            fillColor: Colors.white70,
                            constraints: const BoxConstraints(
                              minHeight: 36,
                              minWidth: 100,
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Mapa',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Lista',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.stars,
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                      Icon(
                        Icons.arrow_upward,
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          size: MediaQuery.of(context).size.width * 0.07,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _showMap
                      ? MapWidget(
                          externalGasolineras: _allGasolineras,
                          onLocationUpdate: _onLocationUpdated,
                        )
                      : _buildListContent(),
                ),
              ),
            ),
            // ✅ BARRA INFERIOR MEJORADA CON BOTONES FUNCIONALES
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9350),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // ✅ Botón coche funcional
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CochesScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.directions_car,
                      size: MediaQuery.of(context).size.width * 0.09,
                    ),
                  ),

                  // ✅ Botón pin funcional
                  IconButton(
                    onPressed: () {
                      // Acción para el botón del pin
                    },
                    icon: Icon(
                      Icons.pin_drop,
                      size: MediaQuery.of(context).size.width * 0.09,
                    ),
                  ),

                  // ✅ BOTÓN AJUSTES FUNCIONAL (MEJORA DEL SEGUNDO CÓDIGO)
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AjustesScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.settings,
                      size: MediaQuery.of(context).size.width * 0.09,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_gasolinerasCercanas.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            'No hay gasolineras cercanas',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _recargarDatos,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    return GasolineraListWidget(gasolineras: _gasolinerasCercanas);
  }
}
