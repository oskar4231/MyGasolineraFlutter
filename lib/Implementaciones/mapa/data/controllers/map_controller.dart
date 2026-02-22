import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/gasolinera_logic.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/map_helpers.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Controlador que gestiona el GPS, la carga de gasolineras y los favoritos.
/// Extiende [ChangeNotifier] para que el widget pueda escuchar cambios de estado.
class MapController extends ChangeNotifier {
  final GasolinerasCacheService cacheService;

  late final GasolineraLogic _gasolineraLogic;

  Position? ubicacionActual;
  bool isLoading = false;
  List<Gasolinera> gasolinerasCargadas = [];

  StreamSubscription<Position>? _positionStreamSub;
  Timer? _debounceTimer;

  // Callbacks hacia el widget
  final void Function(List<Gasolinera>)? onGasolinerasLoaded;
  final void Function(String provincia)? onProvinciaUpdate;
  final void Function(Position pos)? onPositionChanged;

  MapController({
    required this.cacheService,
    this.onGasolinerasLoaded,
    this.onProvinciaUpdate,
    this.onPositionChanged,
  }) {
    _gasolineraLogic = GasolineraLogic(cacheService);
  }

  List<String> get favoritosIds => _gasolineraLogic.favoritosIds;

  // ── Inicialización ─────────────────────────────────────────────────────────

  Future<void> initialize(MarkerHelper markerHelper) async {
    await markerHelper.loadGasStationIcons();
    AppLogger.info('Iconos de marcadores cargados', tag: 'MapController');

    await _gasolineraLogic.cargarFavoritos();
    AppLogger.info(
      'Favoritos cargados (${_gasolineraLogic.favoritosIds.length})',
      tag: 'MapController',
    );

    notifyListeners();
    await iniciarSeguimiento();
  }

  // ── GPS ────────────────────────────────────────────────────────────────────

  Future<void> iniciarSeguimiento() async {
    AppLogger.info('Iniciando seguimiento GPS...', tag: 'MapController');

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger.warning('Servicio de ubicación deshabilitado', tag: 'MapController');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.warning('Permisos de ubicación denegados', tag: 'MapController');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      AppLogger.warning('Permisos denegados permanentemente', tag: 'MapController');
      return;
    }

    // 1. Última ubicación conocida (rápido)
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        AppLogger.info(
          'Última ubicación conocida: ${lastKnown.latitude}, ${lastKnown.longitude}',
          tag: 'MapController',
        );
        _setPosition(lastKnown);
        await cargarGasolineras(lastKnown.latitude, lastKnown.longitude,
            isInitialLoad: true);
        await _actualizarProvincia(lastKnown.latitude, lastKnown.longitude);
      }
    } catch (e) {
      AppLogger.warning('Error obteniendo última ubicación conocida',
          tag: 'MapController', error: e);
    }

    // 2. Ubicación precisa (lento, timeout 5s)
    try {
      AppLogger.debug('Solicitando ubicación precisa...', tag: 'MapController');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('GPS timeout'),
      );

      AppLogger.info(
        'Ubicación precisa: ${position.latitude}, ${position.longitude}',
        tag: 'MapController',
      );
      _setPosition(position);
      await cargarGasolineras(position.latitude, position.longitude,
          isInitialLoad: true);
      await _actualizarProvincia(position.latitude, position.longitude);
    } catch (e) {
      AppLogger.warning('Error obteniendo ubicación precisa o timeout',
          tag: 'MapController', error: e);

      // Fallback: Valencia centro
      if (ubicacionActual == null) {
        final defaultPos = Position(
          latitude: 39.4699,
          longitude: -0.3763,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        _setPosition(defaultPos);
        await cargarGasolineras(defaultPos.latitude, defaultPos.longitude,
            isInitialLoad: true);
      }
    }

    // 3. Stream continuo de posición
    AppLogger.info('Iniciando stream GPS...', tag: 'MapController');
    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      _setPosition(pos);
      onPositionChanged?.call(pos);
      _actualizarProvincia(pos.latitude, pos.longitude);
    });
  }

  void _setPosition(Position pos) {
    ubicacionActual = pos;
    notifyListeners();
  }

  // ── Carga de gasolineras ───────────────────────────────────────────────────

  Future<void> cargarGasolineras(
    double lat,
    double lng, {
    bool isInitialLoad = false,
    String? combustibleSeleccionado,
    double? precioDesde,
    double? precioHasta,
    String? tipoAperturaSeleccionado,
  }) async {
    final gasolineras = await _gasolineraLogic.cargarGasolineras(
      lat,
      lng,
      combustibleSeleccionado: combustibleSeleccionado,
      precioDesde: precioDesde,
      precioHasta: precioHasta,
      tipoAperturaSeleccionado: tipoAperturaSeleccionado,
      isInitialLoad: isInitialLoad,
      onLoadingStateChange: (loading) {
        isLoading = loading;
        notifyListeners();
      },
    );
    gasolinerasCargadas = gasolineras;
    onGasolinerasLoaded?.call(gasolineras);
    notifyListeners();
  }

  Future<void> cargarGasolinerasPorBounds({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    String? combustibleSeleccionado,
    double? precioDesde,
    double? precioHasta,
    String? tipoAperturaSeleccionado,
  }) async {
    final gasolineras = await _gasolineraLogic.cargarGasolinerasPorBounds(
      swLat: swLat,
      swLng: swLng,
      neLat: neLat,
      neLng: neLng,
      combustibleSeleccionado: combustibleSeleccionado,
      precioDesde: precioDesde,
      precioHasta: precioHasta,
      tipoAperturaSeleccionado: tipoAperturaSeleccionado,
      onLoadingStateChange: (loading) {
        isLoading = loading;
        notifyListeners();
      },
    );
    // 🔴 No actualizar si está vacío (error de API) pero ya hay gasolineras previas
    if (gasolineras.isNotEmpty || gasolinerasCargadas.isEmpty) {
      gasolinerasCargadas = gasolineras;
      onGasolinerasLoaded?.call(gasolineras);
      notifyListeners();
    } else {
      AppLogger.warning(
        'Búsqueda por bounds retornó 0 resultados, manteniendo gasolineras previas',
        tag: 'MapController',
      );
    }
  }

  // ── Favoritos ──────────────────────────────────────────────────────────────

  Future<void> toggleFavorito(String id) async {
    await _gasolineraLogic.toggleFavorito(id);
    notifyListeners();
  }

  // ── Provincia ──────────────────────────────────────────────────────────────

  Future<void> _actualizarProvincia(double lat, double lng) async {
    final provincia = await ProvinciaHelper.actualizarProvincia(lat, lng);
    onProvinciaUpdate?.call(provincia);
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
