import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/main.dart' as app;
import 'package:my_gasolinera/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/principal/mapa/map_widget.dart';

class MapaTiempoReal extends StatefulWidget {
  const MapaTiempoReal({super.key});

  @override
  _MapaTiempoRealState createState() => _MapaTiempoRealState();
}

class _MapaTiempoRealState extends State<MapaTiempoReal> {
  double _radiusKm = 25.0;
  Key _mapKey = UniqueKey(); // Para forzar reconstrucción si es necesario
  String _provinciaActual = 'Detectando...'; // 🆕 Provincia actual del usuario
  late GasolinerasCacheService _cacheService;

  @override
  void initState() {
    super.initState();
    _cacheService = GasolinerasCacheService(app.database);
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

  /// 🆕 Actualiza la provincia actual en el AppBar
  /// Llamado por MapWidget cuando detecta un cambio de provincia
  void _actualizarProvincia(String nombreProvincia) {
    if (mounted) {
      setState(() {
        _provinciaActual = nombreProvincia;
      });
      print('✅ AppBar: Provincia actualizada: $_provinciaActual');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '📍 $_provinciaActual', // 🆕 Muestra provincia en tiempo real
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: MapWidget(
        key: _mapKey,
        cacheService: _cacheService,
        radiusKm: _radiusKm,
        onProvinciaUpdate: (String provincia) {
          // 🆕 Callback para actualizar provincia en el AppBar
          _actualizarProvincia(provincia);
        },
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
