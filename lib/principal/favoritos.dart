import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';
import 'package:my_gasolinera/principal/gasolineras/api_gasolinera.dart';
import 'package:intl/intl.dart';

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
      _todasLasGasolineras = await fetchGasolineras();
      final prefs = await SharedPreferences.getInstance();
      final idsFavoritos = prefs.getStringList('favoritas_ids') ?? [];

      _gasolinerasFavoritas = _todasLasGasolineras
          .where((g) => idsFavoritos.contains(g.id))
          .toList();

      _aplicarOrden();
    } catch (e) {
      debugPrint('Error cargando favoritos: $e');
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
    String combustibleTemp = _tipoCombustibleSeleccionado ?? 'Todos';
    String ordenTemp = _ordenSeleccionado == 'nombre'
        ? 'Nombre'
        : _ordenSeleccionado == 'precio_asc'
            ? 'Precio Ascendente'
            : _ordenSeleccionado == 'precio_desc'
                ? 'Precio Descendente'
                : 'Nombre';

    // Colores dinámicos para el diálogo
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = Theme.of(context).primaryColor;
    final textColor = Colors.white;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: dialogBg, // Dinámico
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
                        'Filtros',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor, // Blanco siempre en este diálogo
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'TIPO DE COMBUSTIBLE',
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: combustibleTemp,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFFFF9350),
                              size: 28,
                            ),
                            style: const TextStyle(
                              color: Colors.black, // Texto dentro del dropdown siempre negro
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (String? nuevoValor) {
                              setStateDialog(() {
                                combustibleTemp = nuevoValor!;
                              });
                            },
                            items: [
                              'Todos',
                              'Gasolina 95',
                              'Gasolina 98',
                              'Diesel',
                              'Diesel Premium',
                              'Gas',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'FILTRAR POR',
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: ordenTemp,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFFFF9350),
                              size: 28,
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (String? nuevoValor) {
                              setStateDialog(() {
                                ordenTemp = nuevoValor!;
                              });
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'Nombre',
                                child: Text('Nombre'),
                              ),
                              DropdownMenuItem(
                                value: 'Precio Ascendente',
                                child: Text('Precio Ascendente'),
                              ),
                              DropdownMenuItem(
                                value: 'Precio Descendente',
                                child: Text('Precio Descendente'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                              'Cancelar',
                              style: TextStyle(
                                color: textColor,
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
                                    (combustibleTemp == 'Todos')
                                        ? null
                                        : combustibleTemp;

                                if (ordenTemp == 'Nombre') {
                                  _ordenSeleccionado = 'nombre';
                                } else if (ordenTemp == 'Precio Ascendente') {
                                  _ordenSeleccionado = 'precio_asc';
                                } else if (ordenTemp == 'Precio Descendente') {
                                  _ordenSeleccionado = 'precio_desc';
                                }

                                _aplicarOrden();
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFFF9350),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Aplicar',
                              style: TextStyle(
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

  Widget _buildGasolineraItem(Gasolinera gasolinera) {
    final formatter = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '€',
      decimalDigits: 3,
    );

    // --- Colores Dinámicos para la Tarjeta ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Fondo de la tarjeta: Blanco degradado en claro, Gris oscuro en dark
    final cardDecoration = isDark
        ? BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFFFF5EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF492714).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          );

    final textColor = isDark ? Colors.white : const Color(0xFF492714);
    final subtitleColor = isDark ? Colors.white70 : Colors.grey[600];
    final iconBgColor = isDark ? Colors.white10 : const Color(0xFFFF9350);
    final iconColor = isDark ? Colors.white : Colors.white; // Icono siempre blanco si el fondo es naranja, pero en dark el fondo es transparente

    // Contenedor de precios (parte inferior)
    final pricesContainerColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFF0E6);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: cardDecoration,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFFFF9350) : const Color(0xFFFF9350), // Mantenemos el acento naranja
                    borderRadius: BorderRadius.circular(16),
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
                          color: subtitleColor,
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
                            '${gasolinera.rotulo} eliminado de favoritos',
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.star_rounded,
                    color: isDark ? Colors.amber : const Color(0xFFFF9350), // Ámbar destaca mejor en dark
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pricesContainerColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildPreciosPremium(gasolinera, formatter, isDark),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPreciosPremium(Gasolinera g, NumberFormat formatter, bool isDark) {
    final preciosWidgets = <Widget>[];
    // Texto de las etiquetas (G95, Diesel...)
    final labelColor = isDark ? Colors.white70 : Colors.grey[700];

    Widget buildPrice(String label, double price, Color color) {
      // Ajustamos el color del precio en modo oscuro para que sea legible
      // Si el color original es negro (diesel), lo pasamos a blanco
      final displayColor = (isDark && color == const Color(0xFF000000)) 
          ? Colors.white 
          : color;

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
              color: displayColor,
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
    // --- VARIABLES DE TEMA ---
    final primaryColor = Theme.of(context).primaryColor;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Iconos de la AppBar (Blanco en dark, Negro en light)
    final appBarIconColor = isDark ? Colors.white : Colors.black;
    final appBarTextColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor, // Dinámico
      appBar: AppBar(
        title: Text(
          'Gasolineras favoritas',
          style: TextStyle(
            color: appBarTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryColor, // Dinámico
        centerTitle: true,
        iconTheme: IconThemeData(color: appBarIconColor), // Para la flecha de volver
        actions: [
          IconButton(
            onPressed: _mostrarFiltros,
            icon: Icon(Icons.filter_list, color: appBarIconColor, size: 28),
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : _gasolinerasFavoritas.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_border, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 20),
                        const Text(
                          'No hay gasolineras favoritas en tu lista',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Selecciona gasolineras en el mapa para añadirlas aquí',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Ver mapa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                    if (_tipoCombustibleSeleccionado != null || _ordenSeleccionado != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white, // Fondo de la barra de filtros
                        child: Row(
                          children: [
                            if (_tipoCombustibleSeleccionado != null)
                              Chip(
                                label: Text(
                                  _tipoCombustibleSeleccionado!,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                ),
                                backgroundColor: isDark 
                                    ? Colors.white24 
                                    : const Color(0xFFFF9350).withOpacity(0.2),
                                deleteIconColor: isDark ? Colors.white70 : Colors.black54,
                                onDeleted: () {
                                  setState(() {
                                    _tipoCombustibleSeleccionado = null;
                                    _aplicarOrden();
                                  });
                                },
                              ),
                            if (_ordenSeleccionado != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Chip(
                                  label: Text(
                                    _ordenSeleccionado == 'nombre'
                                        ? 'Orden: Nombre'
                                        : _ordenSeleccionado == 'precio_asc'
                                            ? 'Orden: Precio ↑'
                                            : 'Orden: Precio ↓',
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                  ),
                                  backgroundColor: isDark 
                                      ? Colors.white24 
                                      : const Color(0xFFFF9350).withOpacity(0.2),
                                  deleteIconColor: isDark ? Colors.white70 : Colors.black54,
                                  onDeleted: () {
                                    setState(() {
                                      _ordenSeleccionado = null;
                                      _aplicarOrden();
                                    });
                                  },
                                ),
                              ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _gasolinerasFavoritas.length,
                        itemBuilder: (context, index) {
                          return _buildGasolineraItem(_gasolinerasFavoritas[index]);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}