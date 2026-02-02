import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/api_gasolinera.dart' as api;
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/provincia_service.dart';

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
    double radiusKm = 25.0,
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

        print(
            '🔎 DEBUG GasolineraLogic: Provincia detectada para ($lat, $lng): ${provinciaInfo.nombre} (ID: $_currentProvinciaId)');

        print(
            'GasolineraLogic: Cargando gasolineras para provincia ${provinciaInfo.nombre}');

        // Cargar gasolineras de la provincia actual y vecinas
        final vecinas = ProvinciaService.getProvinciasVecinas(provinciaInfo.id);
        final provinciasToLoad = [provinciaInfo.id, ...vecinas.take(5)];

        listaGasolineras = await _cacheService.getGasolinerasMultiProvincia(
          provinciasToLoad,
          forceRefresh: false, // Usar caché para mejor rendimiento
        );

        print(
            'GasolineraLogic: Cargadas ${listaGasolineras.length} gasolineras desde cache');
      } catch (e) {
        print('GasolineraLogic: Error al cargar desde cache, usando API: $e');

        // Intentar detectar provincia de nuevo para asegurar que tenemos la correcta para ESTA ubicación
        try {
          final detectedInfo =
              await ProvinciaService.getProvinciaFromCoordinates(lat, lng);
          _currentProvinciaId = detectedInfo.id;
          print(
              'GasolineraLogic: (Fallback API) Provincia detectada: ${detectedInfo.nombre} ($_currentProvinciaId)');
        } catch (e2) {
          print(
              'GasolineraLogic: Error al re-detectar provincia en catch: $e2');
        }

        if (_currentProvinciaId != null) {
          listaGasolineras =
              await api.fetchGasolinerasByProvincia(_currentProvinciaId!);
        } else {
          print(
              'GasolineraLogic: No se pudo determinar provincia, cargando lista vacía o default');
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

    print(
        '📍 Filtrando ${listaGasolineras.length} gasolineras por radio de $radiusKm km');

    if (listaGasolineras.isNotEmpty) {
      print('🔍 DEBUG: Primeras 3 gasolineras recibidas (sin filtrar):');
      for (var i = 0;
          i < (listaGasolineras.length > 3 ? 3 : listaGasolineras.length);
          i++) {
        final g = listaGasolineras[i];
        print('   - ${g.rotulo}: ${g.lat}, ${g.lng} (Prov: ${g.provincia})');
      }
    }

    print('📍 Calculando distancias desde origen: $lat, $lng');

    // Calcular distancias y filtrar por radio
    final gasolinerasCercanas = listaGasolineras.map((g) {
      final distance = Geolocator.distanceBetween(lat, lng, g.lat, g.lng);
      return {'gasolinera': g, 'distance': distance};
    }).where((item) {
      final distance = item['distance'] as double;
      // DEBUG: Imprimir distancia de los primeros 3 elementos antes de filtrar
      if (listaGasolineras.indexOf(item['gasolinera'] as Gasolinera) < 3) {
        print(
            '   -> Distancia a ${(item['gasolinera'] as Gasolinera).rotulo}: ${distance.toStringAsFixed(2)} metros (${(distance / 1000).toStringAsFixed(2)} km)');
      }

      // Filtrar por radio (convertir metros a km)
      final distanceKm = distance / 1000;
      return distanceKm <= radiusKm;
    }).toList();

    // Ordenar por distancia
    gasolinerasCercanas.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    final gasolinerasEnRadio =
        gasolinerasCercanas.map((e) => e['gasolinera'] as Gasolinera).toList();

    print(
        'GasolineraLogic: Mostrando ${gasolinerasEnRadio.length} gasolineras en radio de ${radiusKm}km');

    return gasolinerasEnRadio;
  }

  /// Indica si se está cargando progresivamente
  void setLoadingProgressively(bool value) {
    _isLoadingProgressively = value;
  }
}
