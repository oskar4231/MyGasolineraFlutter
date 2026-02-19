import 'package:flutter/material.dart';
import 'dart:async'; // Para TimeoutException
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/api_gasolinera.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/provincia_service.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<Gasolinera> _gasolinerasFavoritas = [];
  List<Gasolinera> _todasLasGasolineras = [];
  bool _loading = true;

  // Filtros
  String? _tipoCombustibleSeleccionado;
  String? _ordenSeleccionado; // 'nombre', 'precio_asc', 'precio_desc'

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _loading = true;
    });

    try {
      // 1. Obtener ubicación actual
      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission != LocationPermission.denied &&
              permission != LocationPermission.deniedForever) {
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.best,
              ),
            ).timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                debugPrint('⏱️ Timeout obteniendo ubicación');
                throw TimeoutException('Location timeout');
              },
            );
          }
        }
      } catch (e) {
        debugPrint('Error obteniendo ubicación: $e');
      }

      // 2. Detectar provincia (o usar Madrid por defecto)
      String provinciaId = '28'; // Madrid por defecto
      if (position != null) {
        try {
          final provinciaInfo =
              await ProvinciaService.getProvinciaFromCoordinates(
            position.latitude,
            position.longitude,
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('⏱️ Timeout detectando provincia, usando Madrid');
              throw TimeoutException('Province detection timeout');
            },
          );
          provinciaId = provinciaInfo.id;
          debugPrint(
              'Provincia detectada: ${provinciaInfo.nombre} ($provinciaId)');
        } catch (e) {
          debugPrint(
              'Error detectando provincia: $e, usando Madrid por defecto');
        }
      }

      // 3. Cargar gasolineras de la provincia detectada con timeout
      _todasLasGasolineras =
          await fetchGasolinerasByProvincia(provinciaId).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏱️ Timeout cargando gasolineras');
          return <Gasolinera>[];
        },
      );

      // 4. Cargar IDs de favoritos desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final idsFavoritos = prefs.getStringList('favoritas_ids') ?? [];

      // 5. Filtrar gasolineras favoritas
      _gasolinerasFavoritas = _todasLasGasolineras
          .where((g) => idsFavoritos.contains(g.id))
          .toList();

      // 6. Aplicar orden inicial
      _aplicarOrden();
    } catch (e) {
      debugPrint('Error cargando favoritos: $e');
      if (_gasolinerasFavoritas.isEmpty) {
        _gasolinerasFavoritas = [];
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
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
    if (_tipoCombustibleSeleccionado != null) {
      switch (_tipoCombustibleSeleccionado) {
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

    String combustibleTemp = _tipoCombustibleSeleccionado ?? l10n.todos;
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
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: SingleChildScrollView(
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
                          color: isDark ? Colors.white : textColor,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tipo de Combustible
                      Text(
                        l10n.tipoCombustible.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: combustibleTemp,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: accentColor,
                              size: 28,
                            ),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            dropdownColor: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (String? nuevoValor) {
                              setStateDialog(() {
                                combustibleTemp = nuevoValor!;
                              });
                            },
                            items: [
                              l10n.todos,
                              'Gasolina 95',
                              'Gasolina 98',
                              'Diesel',
                              'Diesel Premium',
                              'Gas',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Filtrar Por
                      Text(
                        l10n.filtrarPor.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: ordenTemp,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: accentColor,
                              size: 28,
                            ),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            dropdownColor: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (String? nuevoValor) {
                              setStateDialog(() {
                                ordenTemp = nuevoValor!;
                              });
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: l10n.nombre,
                                child: Text(
                                  l10n.nombre,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: l10n.precioAscendente,
                                child: Text(
                                  l10n.precioAscendente,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: l10n.precioDescendente,
                                child: Text(
                                  l10n.precioDescendente,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              l10n.cancelar,
                              style: TextStyle(
                                color: isDark ? textColor : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _tipoCombustibleSeleccionado =
                                    (combustibleTemp == l10n.todos)
                                        ? null
                                        : combustibleTemp;

                                if (ordenTemp == l10n.nombre) {
                                  _ordenSeleccionado = 'nombre';
                                } else if (ordenTemp == l10n.precioAscendente) {
                                  _ordenSeleccionado = 'precio_asc';
                                } else if (ordenTemp ==
                                    l10n.precioDescendente) {
                                  _ordenSeleccionado = 'precio_desc';
                                }

                                _aplicarOrden();
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDark ? accentColor : Colors.white,
                              foregroundColor:
                                  isDark ? Colors.black : accentColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              l10n.aplicar,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGasolineraItem(Gasolinera gasolinera, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final formatter = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '€',
      decimalDigits: 3,
    );

    final lighterCardColor = isDark ? const Color(0xFF3E3E42) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : const Color(0xFF492714);
    final subtextColor = isDark
        ? const Color(0xFFEBEBEB).withValues(alpha: 0.7)
        : Colors.grey[600]!;
    final accentColor =
        isDark ? const Color(0xFFFF8235) : const Color(0xFFFF9350);
    final priceBgColor =
        isDark ? const Color(0xFF2D2D32) : const Color(0xFFFFF0E6);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: lighterCardColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.local_gas_station_rounded,
                    color: isDark ? Colors.black : Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gasolinera.rotulo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gasolinera.direccion,
                        style: TextStyle(
                          fontSize: 14,
                          color: subtextColor,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final idsFavoritos =
                        prefs.getStringList('favoritas_ids') ?? [];
                    idsFavoritos.remove(gasolinera.id);
                    await prefs.setStringList('favoritas_ids', idsFavoritos);

                    if (mounted) {
                      setState(() {
                        _gasolinerasFavoritas.removeWhere(
                          (g) => g.id == gasolinera.id,
                        );
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${gasolinera.rotulo} ${l10n.eliminadoDeFavoritos}',
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.star_rounded,
                    color: accentColor,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: priceBgColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildPreciosPremium(gasolinera, formatter),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPreciosPremium(Gasolinera g, NumberFormat formatter) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final preciosWidgets = <Widget>[];

    Widget buildPrice(String label, double price, Color lightColor) {
      final labelColor = isDark
          ? const Color(0xFFEBEBEB).withValues(alpha: 0.7)
          : Colors.grey[700]!;
      final priceColor = isDark ? const Color(0xFFEBEBEB) : lightColor;

      return Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${price.toStringAsFixed(3)}€',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: priceColor,
            ),
          ),
        ],
      );
    }

    if (g.gasolina95 > 0) {
      preciosWidgets.add(
        buildPrice('G95', g.gasolina95, const Color(0xFF00A650)),
      );
    }

    if (g.gasoleoA > 0) {
      preciosWidgets.add(
        buildPrice('Diesel', g.gasoleoA, const Color(0xFF000000)),
      );
    }

    if (g.gasolina98 > 0 && preciosWidgets.length < 3) {
      preciosWidgets.add(
        buildPrice('G98', g.gasolina98, const Color(0xFF008030)),
      );
    }

    if (preciosWidgets.length < 3 && g.glp > 0) {
      preciosWidgets.add(buildPrice('GLP', g.glp, const Color(0xFFFF5722)));
    }

    return preciosWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accentColor =
        isDark ? const Color(0xFFFF8235) : const Color(0xFFFF9350);
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;
    final lighterCardColor = isDark ? const Color(0xFF3E3E42) : Colors.white;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header plano estilo Accesibilidad/Facturas
            Container(
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
                      fontFamily: 'Roboto',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: _mostrarFiltros,
                      icon: Icon(
                        Icons.filter_list,
                        color:
                            isDark ? Colors.white : theme.colorScheme.onSurface,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(color: accentColor),
                    )
                  : _gasolinerasFavoritas.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star_border,
                                    size: 80,
                                    color: textColor.withValues(alpha: 0.4)),
                                const SizedBox(height: 20),
                                Text(
                                  l10n.noHayFavoritos,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: textColor.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.seleccionaGasolinerasEnMapa,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.map,
                                      color:
                                          isDark ? Colors.black : Colors.white),
                                  label: Text(l10n.verMapa),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,
                                    foregroundColor:
                                        isDark ? Colors.black : Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            // FILA DE FILTROS ACTIVOS
                            if (_tipoCombustibleSeleccionado != null ||
                                _ordenSeleccionado != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                color: lighterCardColor,
                                child: Row(
                                  children: [
                                    if (_tipoCombustibleSeleccionado != null)
                                      Chip(
                                        label: Text(
                                          _tipoCombustibleSeleccionado!,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.black
                                                : accentColor,
                                          ),
                                        ),
                                        backgroundColor: accentColor.withValues(
                                            alpha: isDark ? 0.8 : 0.2),
                                        onDeleted: () {
                                          setState(() {
                                            _tipoCombustibleSeleccionado = null;
                                            _aplicarOrden();
                                          });
                                        },
                                        deleteIconColor:
                                            isDark ? Colors.black : accentColor,
                                      ),
                                    if (_ordenSeleccionado != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Chip(
                                          label: Text(
                                            _ordenSeleccionado == 'nombre'
                                                ? l10n.ordenNombre
                                                : _ordenSeleccionado ==
                                                        'precio_asc'
                                                    ? l10n.ordenPrecioAsc
                                                    : l10n.ordenPrecioDesc,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.black
                                                  : accentColor,
                                            ),
                                          ),
                                          backgroundColor:
                                              accentColor.withValues(
                                                  alpha: isDark ? 0.8 : 0.2),
                                          onDeleted: () {
                                            setState(() {
                                              _ordenSeleccionado = null;
                                              _aplicarOrden();
                                            });
                                          },
                                          deleteIconColor: isDark
                                              ? Colors.black
                                              : accentColor,
                                        ),
                                      ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemCount: _gasolinerasFavoritas.length,
                                itemBuilder: (context, index) {
                                  return _buildGasolineraItem(
                                      _gasolinerasFavoritas[index], l10n);
                                },
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
}
