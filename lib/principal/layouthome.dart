import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_gasolinera/principal/gasolineras/api_gasolinera.dart';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';
import 'package:my_gasolinera/principal/lista.dart';
import 'mapa.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/coches/coches.dart';
import 'favoritos.dart'; // Importar la nueva pantalla de favoritos

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

  // Filtros
  double? _precioDesde;
  double? _precioHasta;
  String? _tipoCombustibleSeleccionado;
  String? _tipoAperturaSeleccionado;

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
      await _getCurrentLocation();
      final lista = await fetchGasolineras();

      if (mounted) {
        setState(() {
          _allGasolineras = lista;
        });
      }

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
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _calcularGasolinerasCercanas() {
    if (_currentPosition == null || _allGasolineras.isEmpty) return;

    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;

    List<Gasolinera> gasolinerasFiltradas = _aplicarFiltros(_allGasolineras);

    final gasolinerasConDistancia = gasolinerasFiltradas.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).toList();

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
  }

  void _onLocationUpdated(double lat, double lng) {
    final now = DateTime.now();
    final timeSinceLastUpdate = now.difference(_lastUpdateTime);

    if (timeSinceLastUpdate < MIN_UPDATE_INTERVAL) return;

    _lastUpdateTime = now;

    if (mounted) {
      _recalcularConNuevaUbicacion(lat, lng);
    }
  }

  void _recalcularConNuevaUbicacion(double lat, double lng) {
    if (_allGasolineras.isEmpty) return;

    List<Gasolinera> gasolinerasFiltradas = _aplicarFiltros(_allGasolineras);

    final gasolinerasConDistancia = gasolinerasFiltradas.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).toList();

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
  }

  List<Gasolinera> _aplicarFiltros(List<Gasolinera> gasolineras) {
    List<Gasolinera> resultado = gasolineras;

    // Filtro de combustible y precio
    if (_tipoCombustibleSeleccionado != null) {
      resultado = resultado.where((g) {
        double precio = _obtenerPrecioCombustible(
          g,
          _tipoCombustibleSeleccionado!,
        );

        if (precio == 0.0) return false;

        if (_precioDesde != null && precio < _precioDesde!) return false;
        if (_precioHasta != null && precio > _precioHasta!) return false;

        return true;
      }).toList();
    }

    // ✅ FILTRO DE APERTURA IMPLEMENTADO
    if (_tipoAperturaSeleccionado != null) {
      resultado = resultado.where((g) {
        switch (_tipoAperturaSeleccionado) {
          case '24 Horas':
            return g.es24Horas;
          case 'Gasolineras atendidas por personal':
            // Definición del usuario: Las que NO son 24 horas
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

  void _recargarDatos() {
    setState(() {
      _gasolinerasCercanas = [];
    });
    _initLocationAndGasolineras();
  }

  Widget _buildCheckboxOption(
    String title,
    String value,
    String? currentValue,
    Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        value: currentValue == value,
        onChanged: (bool? checked) => onChanged(checked == true ? value : null),
        activeColor: Colors.white,
        checkColor: const Color(0xFFFF9350),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  void _mostrarDialogoFiltro({
    required String titulo,
    required List<String> opciones,
    required String? valorActual,
    required Function(String?) onAplicar,
  }) {
    String? valorTemporal = valorActual;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          backgroundColor: const Color(0xFFFF9350),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ...opciones.map(
                  (opcion) => _buildCheckboxOption(
                    opcion,
                    opcion,
                    valorTemporal,
                    (valor) => setStateDialog(() => valorTemporal = valor),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        onAplicar(valorTemporal);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF9350),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarFiltroApertura() {
    _mostrarDialogoFiltro(
      titulo: 'Apertura',
      opciones: [
        '24 Horas',
        'Gasolineras atendidas por personal',
        'Gasolineras abiertas ahora',
        'Todas',
      ],
      valorActual: _tipoAperturaSeleccionado,
      onAplicar: (valor) {
        setState(() => _tipoAperturaSeleccionado = valor);
        _calcularGasolinerasCercanas(); // Actualizar lista
      },
    );
  }

  void _mostrarFiltroCombustible() {
    _mostrarDialogoFiltro(
      titulo: 'Tipos de Combustible',
      opciones: [
        'Gasolina 95',
        'Gasolina 98',
        'Diesel',
        'Diesel Premium',
        'Gas',
      ],
      valorActual: _tipoCombustibleSeleccionado,
      onAplicar: (valor) {
        setState(() {
          _tipoCombustibleSeleccionado = valor;
          if (valor != _tipoCombustibleSeleccionado) {
            _precioDesde = null;
            _precioHasta = null;
          }
        });
        _calcularGasolinerasCercanas();
      },
    );
  }

  void _mostrarFiltroPrecio() {
    if (_tipoCombustibleSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, antes de filtrar por precio seleccione un tipo de combustible',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFF9350),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: MediaQuery.of(context).size.height * 0.4,
          ),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final desdeController = TextEditingController(
      text: _precioDesde?.toString().replaceAll('.', ',') ?? '',
    );
    final hastaController = TextEditingController(
      text: _precioHasta?.toString().replaceAll('.', ',') ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFFF9350),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrar por Precio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Desde (€)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: desdeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*[,.]?\d{0,3}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Ej: 1,50',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hasta (€)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: hastaController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*[,.]?\d{0,3}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Ej: 2,00',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final desdeText = desdeController.text.replaceAll(
                          ',',
                          '.',
                        );
                        final hastaText = hastaController.text.replaceAll(
                          ',',
                          '.',
                        );
                        setState(() {
                          _precioDesde = desdeText.isNotEmpty
                              ? double.tryParse(desdeText)
                              : null;
                          _precioHasta = hastaText.isNotEmpty
                              ? double.tryParse(hastaText)
                              : null;
                        });
                        _calcularGasolinerasCercanas();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF9350),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final theme = Theme.of(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 60,
              child: DrawerHeader(
                decoration: BoxDecoration(color: theme.colorScheme.primary),
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Filtros',
                  style: TextStyle(
                      fontSize: 20, color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
            ListTile(
              title: Text('Precio',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {
                Navigator.of(context).pop();
                _mostrarFiltroPrecio();
              },
            ),
            ListTile(
              title: Text('Combustible',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {
                Navigator.of(context).pop();
                _mostrarFiltroCombustible();
              },
            ),
            ListTile(
              title: Text('Apertura',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {
                Navigator.of(context).pop();
                _mostrarFiltroApertura();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header con logo y botones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MyGasolinera",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
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
                            selectedColor: theme.colorScheme.onPrimary,
                            color: theme.colorScheme.onPrimary.withOpacity(0.7),
                            fillColor:
                                theme.colorScheme.onPrimary.withOpacity(0.2),
                            constraints: const BoxConstraints(
                              minHeight: 32,
                              minWidth: 85,
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  'Mapa',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  'Lista',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Botón de Favoritos (Estrella)
                      IconButton(
                        icon: Icon(Icons.stars,
                            size: 40, color: theme.colorScheme.onPrimary),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FavoritosScreen(),
                            ),
                          );
                        },
                      ),

                      // Botón de filtro de precio (flecha arriba)
                      IconButton(
                        icon: Icon(Icons.arrow_upward,
                            size: 40, color: theme.colorScheme.onPrimary),
                        onPressed: _mostrarFiltroPrecio,
                      ),

                      // Botón para abrir el drawer de filtros (+)
                      IconButton(
                        icon: Icon(Icons.add,
                            size: 40, color: theme.colorScheme.onPrimary),
                        onPressed: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Contenido principal (Mapa o Lista)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _showMap
                      ? MapWidget(
                          externalGasolineras: _allGasolineras,
                          onLocationUpdate: _onLocationUpdated,
                          combustibleSeleccionado: _tipoCombustibleSeleccionado,
                          precioDesde: _precioDesde,
                          precioHasta: _precioHasta,
                          tipoAperturaSeleccionado: _tipoAperturaSeleccionado,
                        )
                      : _buildListContent(),
                ),
              ),
            ),

            // Barra inferior con botones
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Botón de Coches
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CochesScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.directions_car,
                        size: 40, color: theme.colorScheme.onPrimary),
                  ),

                  // Botón de Ubicación (Pin)
                  IconButton(
                    onPressed: () {
                      // Acción para centrar en ubicación actual
                      // Podrías añadir funcionalidad aquí si lo necesitas
                    },
                    icon: Icon(Icons.pin_drop,
                        size: 40, color: theme.colorScheme.onPrimary),
                  ),

                  // Botón de Ajustes
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AjustesScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.settings,
                        size: 40, color: theme.colorScheme.onPrimary),
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
            'No hay gasolineras cercanas con estos filtros',
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
