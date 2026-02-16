import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/api_gasolinera.dart'
    as api;
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/provincia_service.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Clase que maneja toda la lógica de negocio relacionada con gasolineras
class GasolineraLogic {
  final GasolinerasCacheService _cacheService;
  List<String> _favoritosIds = [];
  String? _currentProvinciaId;
  bool _isLoadingFromCache = false;
  bool _isLoadingProgressively = false;

  GasolineraLogic(this._cacheService);

  List<String> get favoritosIds => _favoritosIds;
  bool get isLoadingFromCache => _isLoadingFromCache;
  bool get isLoadingProgressively => _isLoadingProgressively;

  /// Carga la lista de IDs de gasolineras favoritas desde SharedPreferences
  Future<void> cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favoritas_ids') ?? [];
    _favoritosIds = ids;
  }

  /// Alterna el estado de favorito de una gasolinera
  Future<void> toggleFavorito(String gasolineraId) async {
    final prefs = await SharedPreferences.getInstance();
    final idsFavoritos = prefs.getStringList('favoritas_ids') ?? [];

    if (idsFavoritos.contains(gasolineraId)) {
      idsFavoritos.remove(gasolineraId);
    } else {
      idsFavoritos.add(gasolineraId);
    }

    await prefs.setStringList('favoritas_ids', idsFavoritos);
    _favoritosIds = idsFavoritos;
  }

  /// Obtiene el precio de un tipo específico de combustible
  double obtenerPrecioCombustible(Gasolinera g, String tipoCombustible) {
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

  /// Aplica filtros a la lista de gasolineras
  List<Gasolinera> aplicarFiltros(
    List<Gasolinera> gasolineras, {
    String? combustibleSeleccionado,
    double? precioDesde,
    double? precioHasta,
    String? tipoAperturaSeleccionado,
  }) {
    List<Gasolinera> resultado = gasolineras;

    // 1. Filtro de combustible y precio
    if (combustibleSeleccionado != null) {
      resultado = resultado.where((g) {
        double precio = obtenerPrecioCombustible(
          g,
          combustibleSeleccionado,
        );

        if (precio == 0.0) return false;

        if (precioDesde != null && precio < precioDesde) {
          return false;
        }
        if (precioHasta != null && precio > precioHasta) {
          return false;
        }

        return true;
      }).toList();
    }

    // 2. Filtro de Apertura (Horario)
    if (tipoAperturaSeleccionado != null) {
      resultado = resultado.where((g) {
        switch (tipoAperturaSeleccionado) {
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

  /// Carga gasolineras cercanas a una ubicación
  Future<List<Gasolinera>> cargarGasolineras(
    double lat,
    double lng, {
    List<Gasolinera>? externalGasolineras,
    String? combustibleSeleccionado,
    double? precioDesde,
    double? precioHasta,
    String? tipoAperturaSeleccionado,
    bool isInitialLoad = false,
    Function(bool)? onLoadingStateChange,
  }) async {
    List<Gasolinera> listaGasolineras;

    if (externalGasolineras != null && externalGasolineras.isNotEmpty) {
      listaGasolineras = externalGasolineras;
    } else {
      // Usar cache service con detección de provincia
      _isLoadingFromCache = true;
      onLoadingStateChange?.call(true);

      try {
        // Detectar provincia actual
        final provinciaInfo =
            await ProvinciaService.getProvinciaFromCoordinates(lat, lng);
        _currentProvinciaId = provinciaInfo.id;

        AppLogger.debug(
          'DEBUG GasolineraLogic: Provincia detectada para ($lat, $lng): ${provinciaInfo.nombre} (ID: $_currentProvinciaId)',
          tag: 'GasolineraLogic',
        );

        AppLogger.info(
          'Cargando gasolineras para provincia ${provinciaInfo.nombre}',
          tag: 'GasolineraLogic',
        );

        // Cargar gasolineras de la provincia actual y vecinas
        final vecinas = ProvinciaService.getProvinciasVecinas(provinciaInfo.id);
        final provinciasToLoad = [provinciaInfo.id, ...vecinas.take(5)];

        listaGasolineras = await _cacheService.getGasolinerasMultiProvincia(
          provinciasToLoad,
          forceRefresh: false, // Usar caché para mejor rendimiento
        );

        AppLogger.info(
          'Cargadas ${listaGasolineras.length} gasolineras desde cache',
          tag: 'GasolineraLogic',
        );
      } catch (e) {
        AppLogger.warning('Error al cargar desde cache, usando API',
            tag: 'GasolineraLogic', error: e);

        // Intentar detectar provincia de nuevo para asegurar que tenemos la correcta para ESTA ubicación
        try {
          final detectedInfo =
              await ProvinciaService.getProvinciaFromCoordinates(lat, lng);
          _currentProvinciaId = detectedInfo.id;
          AppLogger.info(
            '(Fallback API) Provincia detectada: ${detectedInfo.nombre} ($_currentProvinciaId)',
            tag: 'GasolineraLogic',
          );
        } catch (e2) {
          AppLogger.error(
            'Error al re-detectar provincia en catch',
            tag: 'GasolineraLogic',
            error: e2,
          );
        }

        if (_currentProvinciaId != null) {
          listaGasolineras =
              await api.fetchGasolinerasByProvincia(_currentProvinciaId!);
        } else {
          AppLogger.warning(
            'No se pudo determinar provincia, cargando lista vacía o default',
            tag: 'GasolineraLogic',
          );
          listaGasolineras = [];
        }
      } finally {
        _isLoadingFromCache = false;
        onLoadingStateChange?.call(false);
      }
    }

    listaGasolineras = aplicarFiltros(
      listaGasolineras,
      combustibleSeleccionado: combustibleSeleccionado,
      precioDesde: precioDesde,
      precioHasta: precioHasta,
      tipoAperturaSeleccionado: tipoAperturaSeleccionado,
    );

    AppLogger.debug(
      'Procesando ${listaGasolineras.length} gasolineras de la provincia',
      tag: 'GasolineraLogic',
    );

    if (listaGasolineras.isNotEmpty) {
      AppLogger.debug('DEBUG: Primeras 3 gasolineras recibidas (sin filtrar):',
          tag: 'GasolineraLogic');
      for (var i = 0;
          i < (listaGasolineras.length > 3 ? 3 : listaGasolineras.length);
          i++) {
        final g = listaGasolineras[i];
        AppLogger.debug(
            '   - ${g.rotulo}: ${g.lat}, ${g.lng} (Prov: ${g.provincia})',
            tag: 'GasolineraLogic');
      }
    }

    AppLogger.debug('Calculando distancias desde origen: $lat, $lng',
        tag: 'GasolineraLogic');

    // Calcular distancias (sin filtrar por radio)
    final gasolinerasConDistancia = listaGasolineras.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).toList();

    // Ordenar por distancia (más cercanas primero)
    gasolinerasConDistancia.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    final gasolinerasOrdenadas = gasolinerasConDistancia
        .map((e) => e['gasolinera'] as Gasolinera)
        .toList();

    AppLogger.info(
      'Mostrando ${gasolinerasOrdenadas.length} gasolineras de la provincia ordenadas por distancia',
      tag: 'GasolineraLogic',
    );

    return gasolinerasOrdenadas;
  }

  /// Indica si se está cargando progresivamente
  void setLoadingProgressively(bool value) {
    _isLoadingProgressively = value;
  }

  /// Carga gasolineras dentro de un bounding box (región visible del mapa)
  Future<List<Gasolinera>> cargarGasolinerasPorBounds({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    String? combustibleSeleccionado,
    double? precioDesde,
    double? precioHasta,
    String? tipoAperturaSeleccionado,
    Function(bool)? onLoadingStateChange,
  }) async {
    onLoadingStateChange?.call(true);

    try {
      AppLogger.info(
        'Cargando gasolineras por bounding box: SW($swLat, $swLng) - NE($neLat, $neLng)',
        tag: 'GasolineraLogic',
      );

      // Llamar a la API con el bounding box
      List<Gasolinera> listaGasolineras = await api.fetchGasolinerasByBounds(
        swLat: swLat,
        swLng: swLng,
        neLat: neLat,
        neLng: neLng,
      );

      AppLogger.debug(
        'Recibidas ${listaGasolineras.length} gasolineras desde API',
        tag: 'GasolineraLogic',
      );

      // Aplicar filtros
      listaGasolineras = aplicarFiltros(
        listaGasolineras,
        combustibleSeleccionado: combustibleSeleccionado,
        precioDesde: precioDesde,
        precioHasta: precioHasta,
        tipoAperturaSeleccionado: tipoAperturaSeleccionado,
      );

      AppLogger.debug(
        'Después de filtros: ${listaGasolineras.length} gasolineras',
        tag: 'GasolineraLogic',
      );

      // Calcular centro del bounding box para ordenar por distancia
      final centerLat = (swLat + neLat) / 2;
      final centerLng = (swLng + neLng) / 2;

      // Ordenar por distancia desde el centro
      final gasolinerasConDistancia = listaGasolineras.map((g) {
        final distance =
            Geolocator.distanceBetween(centerLat, centerLng, g.lat, g.lng);
        return {'gasolinera': g, 'distance': distance};
      }).toList();

      gasolinerasConDistancia.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
      );

      final gasolinerasOrdenadas = gasolinerasConDistancia
          .map((e) => e['gasolinera'] as Gasolinera)
          .toList();

      AppLogger.info(
        'Retornando ${gasolinerasOrdenadas.length} gasolineras ordenadas por distancia',
        tag: 'GasolineraLogic',
      );

      return gasolinerasOrdenadas;
    } catch (e) {
      AppLogger.error(
        'Error cargando gasolineras por bounding box',
        tag: 'GasolineraLogic',
        error: e,
      );
      return [];
    } finally {
      onLoadingStateChange?.call(false);
    }
  }
}
