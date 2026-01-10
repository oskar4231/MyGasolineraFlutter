import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/accesibilidad_service.dart';
import 'package:my_gasolinera/Modos/Temas/theme_manager.dart';

class AccesibilidadScreen extends StatefulWidget {
  const AccesibilidadScreen({super.key});

  @override
  State<AccesibilidadScreen> createState() => _AccesibilidadScreenState();
}

class _AccesibilidadScreenState extends State<AccesibilidadScreen> {
  String _tamanoFuente = 'Mediano';
  bool _altoContraste = false;
  bool _modoOscuro = false;
  String _idiomaSeleccionado = 'Español';
  final _accesibilidadService = AccesibilidadService();
  bool _cargando = true;
  double _tamanoFuentePersonalizado = 16.0; // Tamaño personalizado

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  /// Carga la configuración desde el backend
  Future<void> _cargarConfiguracion() async {
    try {
      final config = await _accesibilidadService.obtenerConfiguracion();
      if (config != null && mounted) {
        setState(() {
          _tamanoFuente = config['tamanoFuente'] ?? 'Mediano';
          _altoContraste = config['altoContraste'] ?? false;
          _modoOscuro = config['modoOscuro'] ?? false;
          _idiomaSeleccionado = config['idioma'] ?? 'Español';
          _cargando = false;
        });
      } else {
        setState(() {
          _cargando = false;
        });
      }
    } catch (e) {
      print('Error cargando configuración: $e');
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF9350),
      appBar: AppBar(
        title: const Text(
          'Accesibilidad',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFFF9350),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de Accesibilidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Tamaño de fuente
            Card(
              elevation: 2,
              color: const Color(0xFFFFE8DA),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.text_fields, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Tamaño de Fuente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildOpcionTamano('Pequeño')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildOpcionTamano('Mediano')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildOpcionTamano('Grande')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildOpcionPersonalizada(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TEMA DEL PROYECTO
            Card(
              elevation: 2,
              color: Theme.of(context).cardTheme.color,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                    Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          'Tema',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                    Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                        listenable: ThemeManager(),
                        builder: (context, _) {
                          return DropdownButtonFormField<int>(
                            value: ThemeManager().currentThemeId,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              filled: true,
                              fillColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                            ),
                            dropdownColor: Theme.of(context).cardColor,
                            items: const [
                              DropdownMenuItem(
                                  value: 0,
                                  child: Text('Predeterminado (Naranja)')),
                              DropdownMenuItem(
                                  value: 1, child: Text('Modo Oscuro')),
                              DropdownMenuItem(
                                  value: 2,
                                  child: Text('Daltonismo: Protanopia')),
                              DropdownMenuItem(
                                  value: 3,
                                  child: Text('Daltonismo: Deuteranopia')),
                              DropdownMenuItem(
                                  value: 4,
                                  child: Text('Daltonismo: Tritanopia')),
                              DropdownMenuItem(
                                  value: 5,
                                  child: Text('Daltonismo: Achromatopsia')),
                            ],
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                ThemeManager().setObjectTheme(newValue);
                              }
                            },
                          );
                        }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Idioma - con popup scrollable
            Card(
              elevation: 2,
              color: const Color(0xFFFFE8DA),
              child: InkWell(
                onTap: () => _mostrarPopupIdioma(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.language, color: Colors.black, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Idioma',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _idiomaSeleccionado,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black54,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón guardar
            Center(
              child: ElevatedButton(
                onPressed: _cargando
                    ? null
                    : () async {
                        try {
                          // Mostrar indicador de carga
                          setState(() {
                            _cargando = true;
                          });

                          // Guardar en el backend
                          final exito =
                              await _accesibilidadService.guardarConfiguracion(
                            tamanoFuente: _tamanoFuente,
                            altoContraste: _altoContraste,
                            modoOscuro: _modoOscuro,
                            idioma: _idiomaSeleccionado,
                          );

                          setState(() {
                            _cargando = false;
                          });

                          if (exito && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✅ Configuración guardada correctamente',
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          setState(() {
                            _cargando = false;
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '❌ Error al guardar: ${e.toString()}',
                                ),
                                duration: const Duration(seconds: 3),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: _cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Guardar Cambios',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionTamano(String tamano) {
    final isSelected = _tamanoFuente == tamano;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tamanoFuente = tamano;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF9350) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9350) : Colors.black26,
            width: 2,
          ),
        ),
        child: Text(
          tamano,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildOpcionPersonalizada() {
    final isSelected = _tamanoFuente == 'Personalizada';
    return GestureDetector(
      onTap: () => _mostrarSliderTamanoFuente(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF9350) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9350) : Colors.black26,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune,
              color: isSelected ? Colors.white : Colors.black,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Personalizado',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                '(${_tamanoFuentePersonalizado.round()}px)',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Popup para ajustar tamaño de fuente personalizado
  void _mostrarSliderTamanoFuente() {
    double tempTamano = _tamanoFuentePersonalizado;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFE8DA),
              title: Row(
                children: const [
                  Icon(Icons.format_size, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Tamaño Personalizado',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Texto de ejemplo que cambia de tamaño
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Center(
                      child: Text(
                        'Este es un ejemplo',
                        style: TextStyle(
                          fontSize: tempTamano,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Slider
                  Row(
                    children: [
                      const Icon(
                        Icons.text_fields,
                        size: 16,
                        color: Colors.black54,
                      ),
                      Expanded(
                        child: Slider(
                          value: tempTamano,
                          min: 10.0,
                          max: 32.0,
                          divisions: 22,
                          activeColor: const Color(0xFFFF9350),
                          inactiveColor: Colors.black12,
                          label: tempTamano.round().toString(),
                          onChanged: (double value) {
                            setDialogState(() {
                              tempTamano = value;
                            });
                          },
                        ),
                      ),
                      const Icon(
                        Icons.text_fields,
                        size: 24,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  Text(
                    'Tamaño: ${tempTamano.round()}px',
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _tamanoFuente = 'Personalizada';
                      _tamanoFuentePersonalizado = tempTamano;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tamaño personalizado: ${tempTamano.round()}px',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9350),
                  ),
                  child: const Text(
                    'Aplicar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Popup para selección de idioma
  void _mostrarPopupIdioma() {
    final Map<String, List<String>> idiomasConVariantes = {
      'Español': ['Español'],
      'Português': ['Português'],
      'Deutsch': ['Deutsch'],
      'Italiano': ['Italiano'],
      'English': ['English'],
      'Valenciano': ['Valencià', 'Català'],
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFE8DA),
          title: Row(
            children: const [
              Icon(Icons.language, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Seleccionar Idioma',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: idiomasConVariantes.keys.length,
              itemBuilder: (context, index) {
                final idioma = idiomasConVariantes.keys.elementAt(index);
                final esSeleccionado = _idiomaSeleccionado.startsWith(idioma);
                return Card(
                  elevation: esSeleccionado ? 4 : 1,
                  color:
                      esSeleccionado ? const Color(0xFFFF9350) : Colors.white,
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 0,
                  ),
                  child: ListTile(
                    title: Text(
                      idioma,
                      style: TextStyle(
                        color: esSeleccionado ? Colors.white : Colors.black,
                        fontWeight: esSeleccionado
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: esSeleccionado ? Colors.white : Colors.black54,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      final variantes = idiomasConVariantes[idioma]!;

                      // Si solo tiene una variante, ir directo a confirmación
                      if (variantes.length == 1) {
                        _confirmarCambioIdioma(variantes[0]);
                      } else {
                        // Si tiene múltiples variantes, mostrar lista
                        _mostrarVariantesIdioma(idioma, variantes);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  // Popup para seleccionar variante regional del idioma
  void _mostrarVariantesIdioma(String idiomaBase, List<String> variantes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFE8DA),
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                  _mostrarPopupIdioma();
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  idiomaBase,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: variantes.length > 5 ? 400 : null,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: variantes.length,
              itemBuilder: (context, index) {
                final variante = variantes[index];
                final esSeleccionado = _idiomaSeleccionado == variante;
                return Card(
                  elevation: esSeleccionado ? 4 : 1,
                  color:
                      esSeleccionado ? const Color(0xFFFF9350) : Colors.white,
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 0,
                  ),
                  child: ListTile(
                    title: Text(
                      variante,
                      style: TextStyle(
                        color: esSeleccionado ? Colors.white : Colors.black,
                        fontWeight: esSeleccionado
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: esSeleccionado
                        ? const Icon(Icons.check_circle, color: Colors.white)
                        : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      _confirmarCambioIdioma(variante);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _mostrarPopupIdioma();
              },
              child: const Text('Atrás', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // Confirmación antes de cambiar el idioma
  void _confirmarCambioIdioma(String nuevoIdioma) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFE8DA),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.black),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Confirmar cambio',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '¿Seguro que quieres cambiar el idioma a $nuevoIdioma?',
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _idiomaSeleccionado = nuevoIdioma;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Idioma cambiado a: $nuevoIdioma'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFFFF9350),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9350),
              ),
              child: const Text('Sí', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
