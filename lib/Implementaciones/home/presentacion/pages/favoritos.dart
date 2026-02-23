import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/core/database/bbdd_intermedia/base_datos.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'package:my_gasolinera/main.dart' as app;

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<Gasolinera> _gasolinerasFavoritas = [];
  bool _loading = true;
  late final GasolinerasCacheService _cacheService;

  // Filtros
  // Filtros ahora se usan desde app.filterProvider
  String? _ordenSeleccionado; // 'nombre', 'precio_asc', 'precio_desc'

  @override
  void initState() {
    super.initState();
    _cacheService = GasolinerasCacheService(AppDatabase());
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      // 1. Obtener IDs de favoritos
      final prefs = await SharedPreferences.getInstance();
      final idsFavoritos = prefs.getStringList('favoritas_ids') ?? [];

      if (idsFavoritos.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      // 2. Cargar gasolineras desde DB local (Globalmente)
      _gasolinerasFavoritas =
          await _cacheService.getGasolinerasByIds(idsFavoritos);

      // 3. Intentar obtener ubicación para calcular distancias (Opcional)
      // Corregimos el error de tipo en Web usando un manejo más robusto
      try {
        Position? position;
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          position = await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.low),
          ).timeout(const Duration(seconds: 3));
        }

        if (position != null) {
          final pos = position;
          // Si tenemos posición, podemos ordenar por cercanía si no hay otro criterio
          if (_ordenSeleccionado == null) {
            _gasolinerasFavoritas.sort((a, b) {
              final distA = Geolocator.distanceBetween(
                  pos.latitude, pos.longitude, a.lat, a.lng);
              final distB = Geolocator.distanceBetween(
                  pos.latitude, pos.longitude, b.lat, b.lng);
              return distA.compareTo(distB);
            });
          }
        }
      } catch (e) {
        AppLogger.warning('Error obteniendo ubicación en favoritos: $e');
      }

      // 4. Actualizar precios en segundo plano para las provincias implicadas
      _actualizarPreciosBackground(_gasolinerasFavoritas);

      _aplicarOrden();
    } catch (e) {
      AppLogger.error('Error cargando favoritos: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Actualiza los precios de las provincias que tienen favoritos
  Future<void> _actualizarPreciosBackground(List<Gasolinera> favoritas) async {
    final provinciasIds = favoritas
        .map((g) => g.idProvincia)
        .where((id) => id.isNotEmpty)
        .toSet();

    for (final provinciaId in provinciasIds) {
      try {
        // Refrescamos caché (esto llama a la API y actualiza la DB local)
        final nuevas =
            await _cacheService.getGasolineras(provinciaId, forceRefresh: true);

        // Si la pantalla sigue abierta, actualizamos los precios en la lista actual
        if (mounted && nuevas.isNotEmpty) {
          setState(() {
            for (var i = 0; i < _gasolinerasFavoritas.length; i++) {
              final original = _gasolinerasFavoritas[i];
              if (original.idProvincia == provinciaId) {
                // Buscamos la versión actualizada
                try {
                  final actualizada =
                      nuevas.firstWhere((n) => n.id == original.id);
                  _gasolinerasFavoritas[i] = actualizada;
                } catch (_) {}
              }
            }
            _aplicarOrden();
          });
        }
      } catch (e) {
        AppLogger.warning('Error refrescando provincia $provinciaId: $e');
      }
    }
  }

  void _aplicarOrden() {
    if (_ordenSeleccionado == 'nombre') {
      _gasolinerasFavoritas.sort(
        (a, b) => a.rotulo.toLowerCase().compareTo(b.rotulo.toLowerCase()),
      );
    } else if (_ordenSeleccionado == 'precio_asc') {
      _gasolinerasFavoritas.sort(
        (a, b) => _precioPromedio(a).compareTo(_precioPromedio(b)),
      );
    } else if (_ordenSeleccionado == 'precio_desc') {
      _gasolinerasFavoritas.sort(
        (a, b) => _precioPromedio(b).compareTo(_precioPromedio(a)),
      );
    }
  }

  double _precioPromedio(Gasolinera g) {
    // Usar el tipo de combustible del proveedor global
    final tipoSeleccionado = app.filterProvider.tipoCombustibleSeleccionado;

    if (tipoSeleccionado != null) {
      switch (tipoSeleccionado) {
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

    final precios = [
      g.gasolina95,
      g.gasolina98,
      g.gasoleoA,
      g.glp,
      g.gasoleoPremium,
    ];
    final preciosValidos = precios.where((p) => p > 0).toList();
    if (preciosValidos.isEmpty) return 0.0;
    return preciosValidos.reduce((a, b) => a + b) / preciosValidos.length;
  }

  void _mostrarFiltros() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dialogBg = isDark ? const Color(0xFF212124) : const Color(0xFFFF9350);
    final cardColor = isDark ? const Color(0xFF3E3E42) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : const Color(0xFF3E2723);
    final accentColor =
        isDark ? const Color(0xFFFF8235) : const Color(0xFFFF9350);
    final borderColor = isDark ? const Color(0xFF38383A) : Colors.transparent;

    // Valores temporales para el diálogo basados en el proveedor global
    String combustibleTemp =
        app.filterProvider.tipoCombustibleSeleccionado ?? l10n.todos;
    String ordenTemp = _ordenSeleccionado == 'nombre'
        ? l10n.nombre
        : _ordenSeleccionado == 'precio_asc'
            ? l10n.precioAscendente
            : _ordenSeleccionado == 'precio_desc'
                ? l10n.precioDescendente
                : l10n.nombre;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderColor, width: isDark ? 1 : 0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.filtros,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.tipoCombustible,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown(
                        combustibleTemp,
                        [
                          l10n.todos,
                          'Gasolina 95',
                          'Gasolina 98',
                          'Diesel',
                          'Diesel Premium',
                          'Gas',
                        ],
                        (v) => setStateDialog(() => combustibleTemp = v),
                        cardColor,
                        textColor),
                    const SizedBox(height: 20),
                    Text(
                      l10n.filtrarPor,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown(
                        ordenTemp,
                        [
                          l10n.nombre,
                          l10n.precioAscendente,
                          l10n.precioDescendente,
                        ],
                        (v) => setStateDialog(() => ordenTemp = v),
                        cardColor,
                        textColor),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancelar,
                              style: const TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final nuevoCombustible =
                                (combustibleTemp == l10n.todos)
                                    ? null
                                    : combustibleTemp;

                            await app.filterProvider
                                .setTipoCombustible(nuevoCombustible);

                            setState(() {
                              if (ordenTemp == l10n.nombre) {
                                _ordenSeleccionado = 'nombre';
                              } else if (ordenTemp == l10n.precioAscendente) {
                                _ordenSeleccionado = 'precio_asc';
                              } else if (ordenTemp == l10n.precioDescendente) {
                                _ordenSeleccionado = 'precio_desc';
                              }
                              _aplicarOrden();
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(l10n.aplicar),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown(String value, List<String> items,
      Function(String) onChanged, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((it) => DropdownMenuItem(
                  value: it, child: Text(it, style: TextStyle(color: text))))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFFFF8235) : const Color(0xFFFF9350);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: HoverBackButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    l10n.gasolinerasFavoritas,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: _mostrarFiltros,
                      icon: const Icon(Icons.filter_list),
                    ),
                  ),
                ],
              ),
            ),

            // Lista
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: accentColor))
                  : _gasolinerasFavoritas.isEmpty
                      ? _buildEmptyState(l10n, isDark, accentColor)
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: _gasolinerasFavoritas.length,
                          itemBuilder: (context, index) => _buildGasolineraItem(
                              _gasolinerasFavoritas[index], l10n),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      AppLocalizations l10n, bool isDark, Color accentColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border,
              size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(l10n.noHayFavoritos,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(l10n.seleccionaGasolinerasEnMapa,
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildGasolineraItem(Gasolinera g, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFFFF8235) : const Color(0xFFFF9350);
    final cardColor = isDark ? const Color(0xFF232326) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtextColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 1,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.local_gas_station_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.rotulo,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        g.direccion,
                        style: TextStyle(
                          fontSize: 13,
                          color: subtextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final ids = prefs.getStringList('favoritas_ids') ?? [];
                    ids.remove(g.id);
                    await prefs.setStringList('favoritas_ids', ids);
                    setState(() => _gasolinerasFavoritas
                        .removeWhere((item) => item.id == g.id));
                  },
                  icon: Icon(
                    Icons.star_rounded,
                    color: accentColor,
                    size: 32,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.0),
                    accentColor.withOpacity(0.2),
                    accentColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (g.gasolina95 > 0)
                  _PricePill(
                    label: '95',
                    price: g.gasolina95,
                    color: const Color(0xFF2ECC71), // Emerald
                    isDark: isDark,
                    icon: Icons.local_gas_station_rounded,
                  ),
                if (g.gasoleoA > 0)
                  _PricePill(
                    label: 'Diesel',
                    price: g.gasoleoA,
                    color: isDark
                        ? const Color(0xFF95A5A6)
                        : const Color(0xFF34495E), // Slate
                    isDark: isDark,
                    icon: Icons.directions_car_rounded,
                  ),
                if (g.gasolina98 > 0)
                  _PricePill(
                    label: '98',
                    price: g.gasolina98,
                    color: const Color(0xFF27AE60), // Green
                    isDark: isDark,
                    icon: Icons.local_gas_station_rounded,
                  ),
                if (g.gasoleoPremium > 0)
                  _PricePill(
                    label: 'Diesel+',
                    price: g.gasoleoPremium,
                    color: const Color(0xFFF1C40F), // Gold
                    isDark: isDark,
                    icon: Icons.workspace_premium_rounded,
                  ),
                if (g.glp > 0)
                  _PricePill(
                    label: 'GLP',
                    price: g.glp,
                    color: const Color(0xFFE67E22), // Orange
                    isDark: isDark,
                    icon: Icons.local_fire_department_rounded,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final String label;
  final double price;
  final Color color;
  final bool isDark;
  final IconData icon;

  const _PricePill({
    required this.label,
    required this.price,
    required this.color,
    required this.isDark,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withOpacity(0.05) : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark ? Colors.white.withOpacity(0.1) : color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? color.withOpacity(0.9) : color,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white54 : color.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: price.toStringAsFixed(3),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : color,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    TextSpan(
                      text: '€',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white54 : color.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
