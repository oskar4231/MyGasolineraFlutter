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
      // 1. Cargar todas las gasolineras
      _todasLasGasolineras = await fetchGasolineras();
      
      // 2. Cargar IDs de favoritos desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final idsFavoritos = prefs.getStringList('favoritas_ids') ?? [];
      
      // 3. Filtrar gasolineras favoritas
      _gasolinerasFavoritas = _todasLasGasolineras
          .where((g) => idsFavoritos.contains(g.id))
          .toList();
          
      // 4. Aplicar orden inicial
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
      _gasolinerasFavoritas.sort((a, b) => 
          a.rotulo.toLowerCase().compareTo(b.rotulo.toLowerCase()));
    } else if (_ordenSeleccionado == 'precio_asc') {
      _gasolinerasFavoritas.sort((a, b) => 
          _precioPromedio(a).compareTo(_precioPromedio(b)));
    } else if (_ordenSeleccionado == 'precio_desc') {
      _gasolinerasFavoritas.sort((a, b) => 
          _precioPromedio(b).compareTo(_precioPromedio(a)));
    }
  }
  
  double _precioPromedio(Gasolinera g) {
    if (_tipoCombustibleSeleccionado != null) {
      switch (_tipoCombustibleSeleccionado) {
        case 'Gasolina 95': return g.gasolina95;
        case 'Gasolina 98': return g.gasolina98;
        case 'Diesel': return g.gasoleoA;
        case 'Diesel Premium': return g.gasoleoPremium;
        case 'Gas': return g.glp;
        default: return 0.0;
      }
    }
    
    // Si no hay tipo seleccionado, usar promedio de todos los combustibles
    final precios = [g.gasolina95, g.gasolina98, g.gasoleoA, g.glp, g.gasoleoPremium];
    final preciosValidos = precios.where((p) => p > 0).toList();
    if (preciosValidos.isEmpty) return 0.0;
    return preciosValidos.reduce((a, b) => a + b) / preciosValidos.length;
  }
  
  void _mostrarFiltros() {
  // Valores temporales para el diálogo
  String combustibleTemp = _tipoCombustibleSeleccionado ?? 'Todos';
  String ordenTemp = _ordenSeleccionado == 'nombre' 
      ? 'Nombre'
      : _ordenSeleccionado == 'precio_asc'
        ? 'Precio Ascendente'
        : _ordenSeleccionado == 'precio_desc'
          ? 'Precio Descendente'
          : 'Nombre';
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: const Color(0xFFFF9350),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título "Filtros" en negro
                    const Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tipo de Combustible
                    const Text(
                      'TIPO DE COMBUSTIBLE',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12), // 🔧 Más redondeado
                        boxShadow: [ // 🔧 Añadida sombra sutil
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // 🔧 Padding añadido
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: combustibleTemp,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded, // 🔧 Icono más moderno
                            color: Color(0xFFFF9350),
                            size: 28,
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500, // 🔧 Más peso
                          ),
                          dropdownColor: Colors.white, // 🔧 Fondo del menú
                          borderRadius: BorderRadius.circular(12), // 🔧 Menú redondeado
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
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Colors.black,
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
                    const Text(
                      'FILTRAR POR',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12), // 🔧 Más redondeado
                        boxShadow: [ // 🔧 Añadida sombra sutil
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // 🔧 Padding añadido
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ordenTemp,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded, // 🔧 Icono más moderno
                            color: Color(0xFFFF9350),
                            size: 28,
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500, // 🔧 Más peso
                          ),
                          dropdownColor: Colors.white, // 🔧 Fondo del menú
                          borderRadius: BorderRadius.circular(12), // 🔧 Menú redondeado
                          onChanged: (String? nuevoValor) {
                            setStateDialog(() {
                              ordenTemp = nuevoValor!;
                            });
                          },
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'Nombre',
                              child: Text(
                                'Nombre',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Precio Ascendente',
                              child: Text(
                                'Precio Ascendente',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Precio Descendente',
                              child: Text(
                                'Precio Descendente',
                                style: TextStyle(
                                  color: Colors.black,
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
                        // Botón Cancelar en negro 🔧
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
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botón Aplicar
                        ElevatedButton(
                          onPressed: () {
                            // Aplicar filtros
                            setState(() {
                              _tipoCombustibleSeleccionado = 
                                  (combustibleTemp == 'Todos') ? null : combustibleTemp;
                              
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
                            elevation: 2, // 🔧 Añadida elevación
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // 🔧 Más redondeado
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
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9350).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.local_gas_station,
            color: Color(0xFFFF9350),
            size: 30,
          ),
        ),
        title: Text(
          gasolinera.rotulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              gasolinera.direccion,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildPrecios(gasolinera, formatter),
          ],
        ),
        trailing: IconButton(
          onPressed: () async {
            // Eliminar de favoritos
            final prefs = await SharedPreferences.getInstance();
            final idsFavoritos = prefs.getStringList('favoritas_ids') ?? [];
            idsFavoritos.remove(gasolinera.id);
            await prefs.setStringList('favoritas_ids', idsFavoritos);
            
            // Actualizar lista
            setState(() {
              _gasolinerasFavoritas.removeWhere((g) => g.id == gasolinera.id);
            });
          },
          icon: const Icon(
            Icons.star,
            color: Colors.amber,
            size: 28,
          ),
        ),
      ),
    );
  }
  
  Widget _buildPrecios(Gasolinera g, NumberFormat formatter) {
    final preciosDisponibles = <Widget>[];
    
    if (g.gasolina95 > 0) {
      preciosDisponibles.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '95:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(width: 2),
            Text(
              '${g.gasolina95.toStringAsFixed(3)}€',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      );
    }
    
    if (g.gasoleoA > 0) {
      preciosDisponibles.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Diesel:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(width: 2),
            Text(
              '${g.gasoleoA.toStringAsFixed(3)}€',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }
    
    if (g.gasolina98 > 0 && preciosDisponibles.length < 2) {
      preciosDisponibles.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
            const Text(
              '98:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(width: 2),
            Text(
              '${g.gasolina98.toStringAsFixed(3)}€',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: preciosDisponibles,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE2CE),
      appBar: AppBar(
        title: const Text(
          'Gasolineras favoritas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFFF9350),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _mostrarFiltros,
            icon: const Icon(
              Icons.filter_list,
              color: Colors.black,
              size: 28,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF9350),
              ),
            )
          : _gasolinerasFavoritas.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 80,
                          color: Colors.grey[400],
                        ),
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Ver mapa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9350),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Colors.white,
                        child: Row(
                          children: [
                            if (_tipoCombustibleSeleccionado != null)
                              Chip(
                                label: Text(_tipoCombustibleSeleccionado!),
                                backgroundColor: const Color(0xFFFF9350).withOpacity(0.2),
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
                                  ),
                                  backgroundColor: const Color(0xFFFF9350).withOpacity(0.2),
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