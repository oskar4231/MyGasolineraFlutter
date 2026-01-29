class FilterState {
  final double? precioDesde;
  final double? precioHasta;
  final String? tipoCombustible;
  final String? tipoApertura;

  const FilterState({
    this.precioDesde,
    this.precioHasta,
    this.tipoCombustible,
    this.tipoApertura,
  });

  FilterState copyWith({
    double? precioDesde,
    double? precioHasta,
    String? tipoCombustible,
    String? tipoApertura,
    bool clearPrecioDesde = false,
    bool clearPrecioHasta = false,
    bool clearTipoCombustible = false,
    bool clearTipoApertura = false,
  }) {
    return FilterState(
      precioDesde: clearPrecioDesde ? null : (precioDesde ?? this.precioDesde),
      precioHasta: clearPrecioHasta ? null : (precioHasta ?? this.precioHasta),
      tipoCombustible: clearTipoCombustible
          ? null
          : (tipoCombustible ?? this.tipoCombustible),
      tipoApertura:
          clearTipoApertura ? null : (tipoApertura ?? this.tipoApertura),
    );
  }

  bool get hasActiveFilters =>
      precioDesde != null ||
      precioHasta != null ||
      tipoCombustible != null ||
      tipoApertura != null;
}
