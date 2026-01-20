import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_gasolinera/principal/mapa/map_widget.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/coches/coches.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';
import 'favoritos.dart';
import 'package:my_gasolinera/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/main.dart' as app;

class Layouthome extends StatefulWidget {
  const Layouthome({super.key});

  @override
  State<Layouthome> createState() => _LayouthomeState();
}

class _LayouthomeState extends State<Layouthome> {
  bool _showMap = true;
  late GasolinerasCacheService _cacheService;

  // Filtros
  double? _precioDesde;
  double? _precioHasta;
  String? _tipoCombustibleSeleccionado;
  String? _tipoAperturaSeleccionado;

  // Estado para controlar si hay filtros abiertos (para bloquear el mapa)
  bool _areFiltersOpen = false;

  @override
  void initState() {
    super.initState();
    _cacheService = GasolinerasCacheService(app.database);
  }

  void _recargarDatos() {
    // Ya no es necesario recargar aquí, MapWidget se encarga de todo
    if (mounted) {
      setState(() {
        // Forzar rebuild para que MapWidget recargue si es necesario
      });
    }
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
        color: Colors.white.withValues(alpha: 0.2),
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

  Future<void> _mostrarDialogoFiltro({
    required String titulo,
    required Map<String, String> opciones, // Key -> Label
    required String? valorActual,
    required Function(String?) onAplicar,
  }) async {
    String? valorTemporal = valorActual;

    setState(() {
      _areFiltersOpen = true;
    });

    await showDialog(
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
                ...opciones.entries.map(
                  (entry) => _buildCheckboxOption(
                    entry.value, // Label
                    entry.key, // Value (Internal)
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
                      child: Text(
                        AppLocalizations.of(context)!.cancelar,
                        style: const TextStyle(color: Colors.white),
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
                      child: Text(
                        AppLocalizations.of(context)!.aplicar,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _areFiltersOpen = false;
        });
      }
    });
  }

  void _mostrarFiltroApertura() {
    final l10n = AppLocalizations.of(context)!;
    _mostrarDialogoFiltro(
      titulo: l10n.apertura,
      opciones: {
        '24 Horas': l10n.veinticuatroHoras,
        'Gasolineras atendidas por personal': l10n.atendidasPersonal,
        'Gasolineras abiertas ahora': l10n.abiertasAhora,
        'Todas': l10n.todas,
      },
      valorActual: _tipoAperturaSeleccionado,
      onAplicar: (valor) {
        setState(() => _tipoAperturaSeleccionado = valor);
        // MapWidget se actualizará automáticamente con el nuevo filtro
      },
    );
  }

  void _mostrarFiltroCombustible() {
    final l10n = AppLocalizations.of(context)!;
    _mostrarDialogoFiltro(
      titulo: l10n.tiposCombustible,
      opciones: {
        'Gasolina 95': '${l10n.gasolina} 95',
        'Gasolina 98': '${l10n.gasolina} 98',
        'Diesel': l10n.diesel,
        'Diesel Premium': '${l10n.diesel} Premium',
        'Gas': 'Gas (GLP)', // Or localized 'Gas' if available
      },
      valorActual: _tipoCombustibleSeleccionado,
      onAplicar: (valor) {
        setState(() {
          _tipoCombustibleSeleccionado = valor;
          if (valor != _tipoCombustibleSeleccionado) {
            _precioDesde = null;
            _precioHasta = null;
          }
        });
        // MapWidget se actualizará automáticamente con el nuevo filtro
      },
    );
  }

  void _mostrarFiltroPrecio() {
    final l10n = AppLocalizations.of(context)!;
    if (_tipoCombustibleSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.seleccioneCombustibleAlert,
            textAlign: TextAlign.center,
            style: const TextStyle(
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

    setState(() {
      _areFiltersOpen = true;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
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
                Text(
                  l10n.filtrarPrecio,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.desde,
                  style: const TextStyle(
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
                    hintText: l10n.ejemploPrecio,
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
                Text(
                  l10n.hasta,
                  style: const TextStyle(
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
                    hintText: l10n.ejemploPrecio,
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
                      child: Text(
                        l10n.cancelar,
                        style: const TextStyle(color: Colors.white),
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
                        // MapWidget se actualizará automáticamente con los nuevos filtros
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF9350),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        l10n.aplicar,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _areFiltersOpen = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;

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
                  l10n.filtros,
                  style: TextStyle(
                      fontSize: 20, color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
            ListTile(
              title: Text(l10n.precio,
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {
                Navigator.of(context).pop();
                _mostrarFiltroPrecio();
              },
            ),
            ListTile(
              title: Text(l10n.combustible,
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {
                Navigator.of(context).pop();
                _mostrarFiltroCombustible();
              },
            ),
            ListTile(
              title: Text(l10n.apertura,
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
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {}, // Captura eventos para que no lleguen al mapa
              child: Container(
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
                              color: theme.colorScheme.onPrimary
                                  .withValues(alpha: 0.7),
                              fillColor: theme.colorScheme.onPrimary
                                  .withValues(alpha: 0.2),
                              constraints: const BoxConstraints(
                                minHeight: 32,
                                minWidth: 85,
                              ),
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    l10n.mapa,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    l10n.lista,
                                    style: const TextStyle(
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
            ),

            // Contenido principal (Mapa o Lista)
            // ✅ OPTIMIZACIÓN: MapWidget maneja sus propios datos
            Expanded(
              child: Container(
                margin: _showMap
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                decoration: _showMap
                    ? null
                    : BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                child: Padding(
                  padding:
                      _showMap ? EdgeInsets.zero : const EdgeInsets.all(8.0),
                  child: _showMap
                      ? MapWidget(
                          cacheService: _cacheService,
                          combustibleSeleccionado: _tipoCombustibleSeleccionado,
                          precioDesde: _precioDesde,
                          precioHasta: _precioHasta,
                          tipoAperturaSeleccionado: _tipoAperturaSeleccionado,
                        )
                      : Center(
                          child: Text(
                            'Vista de lista - Por implementar',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CochesScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.directions_car,
                        size: 40,
                        color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.5)), // No seleccionado - apagado
                  ),

                  // Botón de Ubicación (Pin) - Seleccionado
                  IconButton(
                    onPressed: null, // Ya estamos en Mapa
                    icon: Icon(Icons.pin_drop,
                        size: 40,
                        color: theme
                            .colorScheme.onPrimary), // Seleccionado - claro
                  ),

                  // Botón de Ajustes
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AjustesScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.settings,
                        size: 40,
                        color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.5)), // No seleccionado - apagado
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
