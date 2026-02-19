import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/data/services/accesibilidad_service.dart';
import 'package:my_gasolinera/main.dart' as app;
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/theme_manager.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';

class AccesibilidadScreen extends StatefulWidget {
  const AccesibilidadScreen({super.key});

  @override
  State<AccesibilidadScreen> createState() => _AccesibilidadScreenState();
}

class _AccesibilidadScreenState extends State<AccesibilidadScreen> {
  String _tamanoFuente = 'Mediano';
  bool _altoContraste = false;
  bool _modoOscuro = false;
  final _accesibilidadService = AccesibilidadService();
  bool _cargando = true;
  double _tamanoFuentePersonalizado = 16.0; // Tamaño personalizado
  bool _isDropdownHovered = false; // Estado para hover manual del dropdown

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

          if (config['tamanoFuentePersonalizado'] != null) {
            final val = config['tamanoFuentePersonalizado'];
            if (val is num) {
              _tamanoFuentePersonalizado = val.toDouble();
            } else if (val is String) {
              _tamanoFuentePersonalizado = double.tryParse(val) ?? 16.0;
            }
            // Si hay un valor personalizado, forzamos la selección a "Personalizada"
            _tamanoFuente = 'Personalizada';
          }

          _cargando = false;
        });
      } else {
        setState(() {
          _cargando = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error cargando configuración',
          tag: 'AccesibilidadScreen', error: e);
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tema actual
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores base adaptables
    // Colores base adaptables

    final cardColor = isDark
        ? const Color(0xFF212124) // ModoOscuroAccesibilidad.fondoTarjeta
        : (theme.cardTheme.color ?? theme.cardColor);

    final primaryColor = isDark
        ? const Color(0xFFFF8235) // ModoOscuroAccesibilidad.colorAcento
        : theme.primaryColor;

    final borderColor = isDark
        ? const Color(0xFF38383A) // ModoOscuroAccesibilidad.colorBorde
        : theme.dividerColor;

    final textColor = isDark
        ? const Color(0xFFEBEBEB) // ModoOscuroAccesibilidad.textoPrimario
        : theme.colorScheme.onSurface;

    // Color más claro para los contenedores (sutilmente más claro que el fondo de tarjeta)
    final lighterCardColor = isDark
        ? const Color(0xFF3E3E42)
        : Color.lerp(theme.cardTheme.color ?? theme.cardColor, Colors.white,
            0.25); // Solo 25% más claro para evitar que parezca blanco

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header matching Ajustes
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
                    'Accesibilidad',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuración de Accesibilidad',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tarjeta 1: Tamaño de Fuente
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lighterCardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.text_fields, color: textColor),
                              const SizedBox(width: 12),
                              Text(
                                'Tamaño de Fuente',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Botones de Tamaño
                          Row(
                            children: [
                              _buildSizeOption('Pequeño'),
                              const SizedBox(width: 12),
                              _buildSizeOption('Mediano'),
                              const SizedBox(width: 12),
                              _buildSizeOption('Grande'),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Botón Personalizado
                          Material(
                            color: Colors.transparent,
                            child: Ink(
                              decoration: BoxDecoration(
                                color: _tamanoFuente == 'Personalizada'
                                    ? primaryColor
                                    : (isDark
                                        ? const Color(0xFF4A4A4C)
                                        : Colors.transparent),
                                border: Border.all(
                                    color: _tamanoFuente == 'Personalizada'
                                        ? primaryColor
                                        : borderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                onTap: () => _mostrarSliderTamanoFuente(),
                                hoverColor: primaryColor.withOpacity(0.1),
                                splashColor: primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                mouseCursor: SystemMouseCursors.click,
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.tune,
                                          color: _tamanoFuente ==
                                                  'Personalizada'
                                              ? (isDark
                                                  ? Colors.black
                                                  : theme.colorScheme.onPrimary)
                                              : textColor,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Personalizado${_tamanoFuente == 'Personalizada' ? ' (${_tamanoFuentePersonalizado.round()}px)' : ''}',
                                        style: TextStyle(
                                          color: _tamanoFuente ==
                                                  'Personalizada'
                                              ? (isDark
                                                  ? Colors.black
                                                  : theme.colorScheme.onPrimary)
                                              : textColor,
                                          fontWeight:
                                              _tamanoFuente == 'Personalizada'
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tarjeta 2: Tema
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lighterCardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.palette, color: textColor),
                              const SizedBox(width: 12),
                              Text(
                                'Tema',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Dropdown Funcional Adaptado
                          ListenableBuilder(
                              listenable: ThemeManager(),
                              builder: (context, _) {
                                /* Fixed: Stack para replicar exactamente la pila de InkWell: Fondo + Overlay Hover (Naranja suave) */
                                return MouseRegion(
                                  onEnter: (_) =>
                                      setState(() => _isDropdownHovered = true),
                                  onExit: (_) => setState(
                                      () => _isDropdownHovered = false),
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // Fondo base siempre gris
                                      color: isDark
                                          ? const Color(0xFF4A4A4C)
                                          : Colors.transparent,
                                      border: Border.all(color: borderColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Capa Overlay Hover (animada para suavidad similar a InkWell)
                                        Positioned.fill(
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            decoration: BoxDecoration(
                                              color: _isDropdownHovered
                                                  ? primaryColor
                                                      .withOpacity(0.1)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        // Contenido del Dropdown (Transparente para dejar ver el fondo y el hover)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<int>(
                                              value:
                                                  ThemeManager().currentThemeId,
                                              isExpanded: true,
                                              // Fondo del MENÚ desplegable (no del botón)
                                              dropdownColor: isDark
                                                  ? const Color(0xFF4A4A4C)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              icon: Icon(Icons.arrow_drop_down,
                                                  color: textColor),
                                              style:
                                                  TextStyle(color: textColor),
                                              focusColor: Colors.transparent,
                                              items: [
                                                _buildDropdownItem(
                                                    0,
                                                    'Predeterminado (Naranja)',
                                                    textColor),
                                                _buildDropdownItem(1,
                                                    'Modo Oscuro', textColor),
                                                _buildDropdownItem(
                                                    2, 'Protanopia', textColor),
                                                _buildDropdownItem(3,
                                                    'Deuteranopia', textColor),
                                                _buildDropdownItem(
                                                    4, 'Tritanopia', textColor),
                                                _buildDropdownItem(5,
                                                    'Achromatopsia', textColor),
                                              ],
                                              onChanged: (int? newValue) {
                                                if (newValue != null) {
                                                  ThemeManager()
                                                      .setObjectTheme(newValue);
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Botón Guardar
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: _cargando
                              ? null
                              : () async {
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  final navigator = Navigator.of(context);
                                  try {
                                    setState(() {
                                      _cargando = true;
                                    });

                                    final exito = await _accesibilidadService
                                        .guardarConfiguracion(
                                      tamanoFuente: _tamanoFuente,
                                      altoContraste: _altoContraste,
                                      modoOscuro: _modoOscuro,
                                      idioma: 'Español',
                                      tamanoFuentePersonalizado:
                                          _tamanoFuente == 'Personalizada'
                                              ? _tamanoFuentePersonalizado
                                              : null,
                                    );

                                    if (mounted) {
                                      setState(() {
                                        _cargando = false;
                                      });
                                    }

                                    if (exito) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              '✅ Configuración guardada correctamente'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      navigator.pop();
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      setState(() {
                                        _cargando = false;
                                      });
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '❌ Error al guardar: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: isDark
                                ? Colors.black
                                : theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: _cargando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black),
                                  ),
                                )
                              : const Text(
                                  'Guardar Cambios',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ), // Center
                  ], // Inner children
                ), // Inner Column
              ), // SingleChildScrollView
            ), // Expanded
          ], // outer Column children
        ), // outer Column
      ), // SafeArea
    ); // Scaffold
  }

  Widget _buildSizeOption(String text) {
    final theme = Theme.of(context);
    final isActive = _tamanoFuente == text;
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark
        ? const Color(0xFFFF8235) // ModoOscuroAccesibilidad.colorAcento
        : theme.primaryColor;

    final borderColor = isDark
        ? const Color(0xFF38383A) // ModoOscuroAccesibilidad.colorBorde
        : theme.dividerColor;

    final textColor = isDark
        ? const Color(0xFFEBEBEB) // ModoOscuroAccesibilidad.textoPrimario
        : theme.colorScheme.onSurface;

    final activeTextColor = isDark ? Colors.black : theme.colorScheme.onPrimary;

    final hoverColor = primaryColor.withOpacity(0.1);

    final splashColor = primaryColor.withOpacity(0.2);

    // Color gris medio para destacar sobre el fondo 0xFF3E3E42
    final unselectedBgColor =
        isDark ? const Color(0xFF4A4A4C) : Colors.transparent;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            // Fondo Ajustes para no seleccionado, Primary para seleccionado
            color: isActive ? primaryColor : unselectedBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? primaryColor : borderColor,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _tamanoFuente = text;
              });
              app.fontSizeProvider.changeFontSizeByPreset(text);
            },
            hoverColor: hoverColor,
            splashColor: splashColor,
            borderRadius: BorderRadius.circular(8),
            mouseCursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isActive ? activeTextColor : textColor,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<int> _buildDropdownItem(
      int value, String text, Color textColor) {
    return DropdownMenuItem<int>(
      value: value,
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }

  // Popup para ajustar tamaño de fuente personalizado
  void _mostrarSliderTamanoFuente() {
    double tempTamano = _tamanoFuentePersonalizado;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF212124) // ModoOscuroAccesibilidad.fondoTarjeta
        : (theme.cardTheme.color ?? theme.cardColor);

    final textColor = isDark
        ? const Color(0xFFEBEBEB) // ModoOscuroAccesibilidad.textoPrimario
        : theme.colorScheme.onSurface;

    final primaryColor = isDark
        ? const Color(0xFFFF8235) // ModoOscuroAccesibilidad.colorAcento
        : theme.primaryColor;

    final borderColor = isDark
        ? const Color(0xFF38383A) // ModoOscuroAccesibilidad.colorBorde
        : theme.dividerColor;

    final backgroundColor = isDark
        ? const Color(0xFF151517) // ModoOscuroAccesibilidad.fondoPrincipal
        : theme.scaffoldBackgroundColor;

    final activeTextColor = isDark ? Colors.black : theme.colorScheme.onPrimary;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderColor, width: 1),
              ),
              title: Row(
                children: [
                  Icon(Icons.format_size,
                      color: isDark ? Colors.white : primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Tamaño Personalizado',
                    style: TextStyle(
                      color: isDark ? Colors.white : primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Text(
                        'Ejemplo de texto',
                        style: TextStyle(
                          fontSize: tempTamano,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: isDark
                          ? const Color(0xFF38383A)
                          : borderColor, // Mejor contraste en pista inactiva
                      thumbColor: primaryColor,
                      overlayColor: primaryColor.withOpacity(0.2),
                      valueIndicatorColor: primaryColor,
                      valueIndicatorTextStyle: TextStyle(
                        color: activeTextColor,
                      ),
                    ),
                    child: Slider(
                      value: tempTamano,
                      min: 12.0,
                      max: 24.0,
                      divisions: 12,
                      label: tempTamano.round().toString(),
                      onChanged: (double value) {
                        setDialogState(() {
                          tempTamano = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    '${tempTamano.round()}px',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
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
                    app.fontSizeProvider.changeFontSizeCustom(tempTamano);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: activeTextColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
