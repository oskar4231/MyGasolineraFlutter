import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- Importamos Provider
import 'package:my_gasolinera/services/accesibilidad_service.dart';
import 'package:my_gasolinera/services/theme_service.dart'; // <--- Importamos tu servicio de tema

class AccesibilidadScreen extends StatefulWidget {
  const AccesibilidadScreen({super.key});

  @override
  State<AccesibilidadScreen> createState() => _AccesibilidadScreenState();
}

class _AccesibilidadScreenState extends State<AccesibilidadScreen> {
  String _tamanoFuente = 'Mediano';
  bool _altoContraste = false;
  // Mantenemos esta variable local para enviarla al backend al guardar
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

        // Opcional: Si quieres que al cargar del backend se active visualmente:
        // if (_modoOscuro) {
        //    Provider.of<ThemeProvider>(context, listen: false).toggleTheme(true);
        // }
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
    // 1. OBTENER EL ESTADO DEL TEMA
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // 2. DEFINIR COLORES DINÁMICOS
    // Si es oscuro: Fondo casi negro, Tarjetas gris oscuro, Textos blancos.
    // Si es claro: Tus colores originales (Naranja/Crema).
    final Color backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFF9350);
    final Color cardColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFE8DA);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color iconColor = isDark ? Colors.white : Colors.black;
    final Color subtitleColor = isDark ? Colors.grey[400]! : Colors.black87;
    const Color activeColor = Color(0xFFFF9350); // El naranja se mantiene como acento

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Accesibilidad',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor, // Mismo color que el fondo para que se funda
        iconTheme: IconThemeData(color: iconColor),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración de Accesibilidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Tamaño de fuente
            Card(
              elevation: 2,
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.text_fields, color: iconColor),
                        const SizedBox(width: 8),
                        Text(
                          'Tamaño de Fuente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildOpcionTamano('Pequeño', activeColor, cardColor, textColor, isDark)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildOpcionTamano('Mediano', activeColor, cardColor, textColor, isDark)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildOpcionTamano('Grande', activeColor, cardColor, textColor, isDark)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildOpcionPersonalizada(activeColor, cardColor, textColor, isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Alto contraste
            Card(
              elevation: 2,
              color: cardColor,
              child: SwitchListTile(
                secondary: Icon(Icons.contrast, color: iconColor),
                title: Text(
                  'Alto Contraste',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  'Mejora la visibilidad de los elementos',
                  style: TextStyle(color: subtitleColor, fontSize: 12),
                ),
                value: _altoContraste,
                activeThumbColor: activeColor,
                onChanged: (bool value) {
                  setState(() {
                    _altoContraste = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Modo Oscuro (INTEGRACIÓN PRINCIPAL)
            Card(
              elevation: 2,
              color: cardColor,
              child: SwitchListTile(
                secondary: Icon(Icons.dark_mode, color: iconColor),
                title: Text(
                  'Modo Oscuro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  'Reduce el brillo y mejora la visibilidad nocturna',
                  style: TextStyle(color: subtitleColor, fontSize: 12),
                ),
                // Usamos el valor del Provider para el estado visual del switch
                value: isDark, 
                activeThumbColor: activeColor,
                onChanged: (bool value) {
                  // 1. Cambiamos el tema visualmente al instante
                  themeProvider.toggleTheme(value);
                  
                  // 2. Actualizamos la variable local para guardar en backend después
                  setState(() {
                    _modoOscuro = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Idioma - con popup scrollable
            Card(
              elevation: 2,
              color: cardColor,
              child: InkWell(
                onTap: () => _mostrarPopupIdioma(cardColor, textColor, iconColor, isDark),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.language, color: iconColor, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Idioma',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _idiomaSeleccionado,
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: isDark ? Colors.white54 : Colors.black54,
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
                          final exito = await _accesibilidadService
                              .guardarConfiguracion(
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
                  backgroundColor: isDark ? Colors.white : Colors.black, // Invertido para contraste
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: _cargando
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.black : Colors.white,
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

  // --- MÉTODOS AUXILIARES ACTUALIZADOS PARA RECIBIR COLORES ---

  Widget _buildOpcionTamano(String tamano, Color activeColor, Color cardColor, Color textColor, bool isDark) {
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
          // Si está seleccionado: naranja. Si no: blanco (light) o gris oscuro (dark)
          color: isSelected ? activeColor : (isDark ? Colors.black12 : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : (isDark ? Colors.white24 : Colors.black26),
            width: 2,
          ),
        ),
        child: Text(
          tamano,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildOpcionPersonalizada(Color activeColor, Color cardColor, Color textColor, bool isDark) {
    final isSelected = _tamanoFuente == 'Personalizada';
    return GestureDetector(
      onTap: () => _mostrarSliderTamanoFuente(cardColor, textColor, isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : (isDark ? Colors.black12 : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : (isDark ? Colors.white24 : Colors.black26),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune,
              color: isSelected ? Colors.white : textColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Personalizado',
              style: TextStyle(
                color: isSelected ? Colors.white : textColor,
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
  void _mostrarSliderTamanoFuente(Color bg, Color textColor, bool isDark) {
    double tempTamano = _tamanoFuentePersonalizado;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: bg, // Color dinámico
              title: Row(
                children: [
                  Icon(Icons.format_size, color: textColor),
                  const SizedBox(width: 8),
                  Text(
                    'Tamaño Personalizado',
                    style: TextStyle(
                      color: textColor,
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
                      color: isDark ? Colors.black38 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Center(
                      child: Text(
                        'Este es un ejemplo',
                        style: TextStyle(
                          fontSize: tempTamano,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Slider
                  Row(
                    children: [
                      Icon(
                        Icons.text_fields,
                        size: 16,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      Expanded(
                        child: Slider(
                          value: tempTamano,
                          min: 10.0,
                          max: 32.0,
                          divisions: 22,
                          activeColor: const Color(0xFFFF9350),
                          inactiveColor: isDark ? Colors.white24 : Colors.black12,
                          label: tempTamano.round().toString(),
                          onChanged: (double value) {
                            setDialogState(() {
                              tempTamano = value;
                            });
                          },
                        ),
                      ),
                      Icon(
                        Icons.text_fields,
                        size: 24,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ],
                  ),
                  Text(
                    'Tamaño: ${tempTamano.round()}px',
                    style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: textColor),
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
  void _mostrarPopupIdioma(Color bg, Color textColor, Color iconColor, bool isDark) {
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
          backgroundColor: bg,
          title: Row(
            children: [
              Icon(Icons.language, color: iconColor),
              const SizedBox(width: 8),
              Text(
                'Seleccionar Idioma',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
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
                  color: esSeleccionado
                      ? const Color(0xFFFF9350)
                      : (isDark ? Colors.black26 : Colors.white),
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 0,
                  ),
                  child: ListTile(
                    title: Text(
                      idioma,
                      style: TextStyle(
                        color: esSeleccionado ? Colors.white : textColor,
                        fontWeight: esSeleccionado
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: esSeleccionado ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      final variantes = idiomasConVariantes[idioma]!;

                      // Si solo tiene una variante, ir directo a confirmación
                      if (variantes.length == 1) {
                        _confirmarCambioIdioma(variantes[0], bg, textColor);
                      } else {
                        // Si tiene múltiples variantes, mostrar lista
                        _mostrarVariantesIdioma(idioma, variantes, bg, textColor, isDark);
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
              child: Text(
                'Cancelar',
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        );
      },
    );
  }

  // Popup para seleccionar variante regional del idioma
  void _mostrarVariantesIdioma(String idiomaBase, List<String> variantes, Color bg, Color textColor, bool isDark) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bg,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: textColor),
                onPressed: () {
                  Navigator.of(context).pop();
                  _mostrarPopupIdioma(bg, textColor, textColor, isDark);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  idiomaBase,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
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
                  color: esSeleccionado
                      ? const Color(0xFFFF9350)
                      : (isDark ? Colors.black26 : Colors.white),
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 0,
                  ),
                  child: ListTile(
                    title: Text(
                      variante,
                      style: TextStyle(
                        color: esSeleccionado ? Colors.white : textColor,
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
                      _confirmarCambioIdioma(variante, bg, textColor);
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
                _mostrarPopupIdioma(bg, textColor, textColor, isDark);
              },
              child: Text('Atrás', style: TextStyle(color: textColor)),
            ),
          ],
        );
      },
    );
  }

  // Confirmación antes de cambiar el idioma
  void _confirmarCambioIdioma(String nuevoIdioma, Color bg, Color textColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bg,
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Confirmar cambio',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '¿Seguro que quieres cambiar el idioma a $nuevoIdioma?',
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No', style: TextStyle(color: textColor)),
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