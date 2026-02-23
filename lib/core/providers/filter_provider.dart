import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class FilterProvider extends ChangeNotifier {
  double? _precioDesde;
  double? _precioHasta;
  String? _tipoCombustibleSeleccionado;
  String? _tipoAperturaSeleccionado;
  String? _ordenPrecio; // 'asc', 'desc', 'distance', null

  double? get precioDesde => _precioDesde;
  double? get precioHasta => _precioHasta;
  String? get tipoCombustibleSeleccionado => _tipoCombustibleSeleccionado;
  String? get tipoAperturaSeleccionado => _tipoAperturaSeleccionado;
  String? get ordenPrecio => _ordenPrecio;

  /// Actualiza los filtros de precio
  Future<void> setPrecioFiltros(double? desde, double? hasta) async {
    _precioDesde = desde;
    _precioHasta = hasta;
    await _saveFilters();
    notifyListeners();
  }

  /// Actualiza el tipo de combustible
  Future<void> setTipoCombustible(String? tipo) async {
    if (_tipoCombustibleSeleccionado != tipo) {
      _tipoCombustibleSeleccionado = tipo;
      // Si cambia el combustible, solemos limpiar los precios (según lógica de Layouthome)
      _precioDesde = null;
      _precioHasta = null;
      await _saveFilters();
      notifyListeners();
    }
  }

  /// Actualiza el tipo de apertura
  Future<void> setTipoApertura(String? tipo) async {
    _tipoAperturaSeleccionado = tipo;
    await _saveFilters();
    notifyListeners();
  }

  /// Actualiza el orden por precio
  Future<void> setOrdenPrecio(String? orden) async {
    _ordenPrecio = orden;
    await _saveFilters();
    notifyListeners();
  }

  /// Limpia todos los filtros
  Future<void> clearFilters() async {
    _precioDesde = null;
    _precioHasta = null;
    _tipoCombustibleSeleccionado = null;
    _tipoAperturaSeleccionado = null;
    _ordenPrecio = null;
    await _saveFilters();
    notifyListeners();
  }

  /// Carga los filtros iniciales desde SharedPreferences
  Future<void> loadInitialFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _precioDesde = prefs.getDouble('filter_precio_desde');
      _precioHasta = prefs.getDouble('filter_precio_hasta');
      _tipoCombustibleSeleccionado = prefs.getString('filter_combustible');
      _tipoAperturaSeleccionado = prefs.getString('filter_apertura');
      _ordenPrecio = prefs.getString('filter_orden_precio');

      AppLogger.info('Filtros cargados desde SharedPreferences',
          tag: 'FilterProvider');
      notifyListeners();
    } catch (e) {
      AppLogger.warning('Error cargando filtros iniciales',
          tag: 'FilterProvider', error: e);
    }
  }

  /// Guarda los filtros en SharedPreferences
  Future<void> _saveFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_precioDesde != null) {
        await prefs.setDouble('filter_precio_desde', _precioDesde!);
      } else {
        await prefs.remove('filter_precio_desde');
      }

      if (_precioHasta != null) {
        await prefs.setDouble('filter_precio_hasta', _precioHasta!);
      } else {
        await prefs.remove('filter_precio_hasta');
      }

      if (_tipoCombustibleSeleccionado != null) {
        await prefs.setString(
            'filter_combustible', _tipoCombustibleSeleccionado!);
      } else {
        await prefs.remove('filter_combustible');
      }

      if (_tipoAperturaSeleccionado != null) {
        await prefs.setString('filter_apertura', _tipoAperturaSeleccionado!);
      } else {
        await prefs.remove('filter_apertura');
      }

      if (_ordenPrecio != null) {
        await prefs.setString('filter_orden_precio', _ordenPrecio!);
      } else {
        await prefs.remove('filter_orden_precio');
      }

      AppLogger.debug('Filtros guardados en SharedPreferences',
          tag: 'FilterProvider');
    } catch (e) {
      AppLogger.error('Error guardando filtros en SharedPreferences',
          tag: 'FilterProvider', error: e);
    }
  }
}
