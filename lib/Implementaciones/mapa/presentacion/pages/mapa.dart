import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/mapa/presentacion/widgets/map_widget.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/pages/ajustes.dart';
import 'package:my_gasolinera/main.dart' as app;
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class MapaTiempoReal extends StatefulWidget {
  const MapaTiempoReal({super.key});

  @override
  State<MapaTiempoReal> createState() => _MapaTiempoRealState();
}

class _MapaTiempoRealState extends State<MapaTiempoReal> {
  final Key _mapKey = UniqueKey(); // Para forzar reconstrucción si es necesario
  String _provinciaActual = 'Detectando...'; // 🆕 Provincia actual del usuario
  late GasolinerasCacheService _cacheService;

  @override
  void initState() {
    super.initState();
    _cacheService = app.gasolineraCacheService;
  }

  /// 🆕 Actualiza la provincia actual en el AppBar
  /// Llamado por MapWidget cuando detecta un cambio de provincia
  void _actualizarProvincia(String nombreProvincia) {
    if (mounted) {
      setState(() {
        _provinciaActual = nombreProvincia;
      });
      AppLogger.info('AppBar: Provincia actualizada: $_provinciaActual',
          tag: 'MapaTiempoReal');
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
          );
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
