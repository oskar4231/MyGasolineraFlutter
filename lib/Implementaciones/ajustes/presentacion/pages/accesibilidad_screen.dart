import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/data/services/accesibilidad_service.dart';
import 'package:my_gasolinera/main.dart' as app;
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/theme_manager.dart';

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
    // Aspecto condicional: Si es Dark Mode, usamos los colores específicos de ModoOscuroAccesibilidad
    // Si no, usamos los del tema global (para que funcione en Light, Daltonismo, etc.)
    final backgroundColor = isDark
        ? const Color(0xFF151517) // ModoOscuroAccesibilidad.fondoPrincipal
        : theme.scaffoldBackgroundColor;

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

    final appBarColor = isDark
        ? const Color(0xFF151517) // ModoOscuroAccesibilidad.fondoPrincipal
        : theme.appBarTheme.backgroundColor;

    final appBarContentColor = isDark
        ? primaryColor
        : (theme.appBarTheme.foregroundColor ?? Colors.black);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        shape: isDark
            ? null
            : const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: appBarContentColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Accesibilidad',
          style: TextStyle(
            color: appBarContentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: appBarContentColor),
      ),
      body: SingleChildScrollView(
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
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
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
                            : Colors.transparent,
                        border: Border.all(
                            color: _tamanoFuente == 'Personalizada'
                                ? primaryColor
                                : borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () => _mostrarSliderTamanoFuente(),
                        hoverColor: Colors.white.withOpacity(0.08),
                        splashColor: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        mouseCursor: SystemMouseCursors.click,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.tune,
                                  color: _tamanoFuente == 'Personalizada'
                                      ? (isDark
                                          ? Colors.black
                                          : theme.colorScheme.onPrimary)
                                      : textColor,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Personalizado${_tamanoFuente == 'Personalizada' ? ' (${_tamanoFuentePersonalizado.round()}px)' : ''}',
                                style: TextStyle(
                                  color: _tamanoFuente == 'Personalizada'
                                      ? (isDark
                                          ? Colors.black
                                          : theme.colorScheme.onPrimary)
                                      : textColor,
                                  fontWeight: _tamanoFuente == 'Personalizada'
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
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
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
                        return Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              hoverColor: Colors.white.withOpacity(0.08),
                              splashColor: Colors.white.withOpacity(0.1),
                              mouseCursor: SystemMouseCursors.click,
                              onTap:
                                  () {}, // Necesario para que el InkWell detecte el hover
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: ThemeManager().currentThemeId,
                                    isExpanded: true,
                                    dropdownColor: cardColor,
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: textColor),
                                    style: TextStyle(color: textColor),
                                    items: [
                                      _buildDropdownItem(
                                          0,
                                          'Predeterminado (Naranja)',
                                          textColor),
                                      _buildDropdownItem(
                                          1, 'Modo Oscuro', textColor),
                                      _buildDropdownItem(
                                          2, 'Protanopia', textColor),
                                      _buildDropdownItem(
                                          3, 'Deuteranopia', textColor),
                                      _buildDropdownItem(
                                          4, 'Tritanopia', textColor),
                                      _buildDropdownItem(
                                          5, 'Achromatopsia', textColor),
                                    ],
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        ThemeManager().setObjectTheme(newValue);
                                      }
                                    },
                                  ),
                                ),
                              ),
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
                          final messenger = ScaffoldMessenger.of(context);
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
                    foregroundColor:
                        isDark ? Colors.black : theme.colorScheme.onPrimary,
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

    final hoverColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);

    final splashColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.transparent,
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
    final cardColor = theme.cardTheme.color ?? theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final primaryColor = theme.primaryColor;
    final borderColor = theme.dividerColor;
    final isDark = theme.brightness == Brightness.dark;

    final activeTextColor = isDark ? Colors.black : theme.colorScheme.onPrimary;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
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
                  Slider(
                    value: tempTamano,
                    min: 12.0,
                    max: 24.0,
                    divisions: 12,
                    activeColor: primaryColor,
                    inactiveColor: borderColor,
                    label: tempTamano.round().toString(),
                    onChanged: (double value) {
                      setDialogState(() {
                        tempTamano = value;
                      });
                    },
                  ),
                  Text(
                    '${tempTamano.round()}px',
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar', style: TextStyle(color: textColor)),
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
