import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/accesibilidad_service.dart';
import 'package:my_gasolinera/Modos/Temas/theme_manager.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.accesibilidad,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.accesibilidadConfig,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Tamaño de fuente
            Card(
              elevation: 2,
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.text_fields,
                            color: Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.tamanoFuente,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: _buildOpcionTamano(
                                    AppLocalizations.of(context)!.pequeno)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _buildOpcionTamano(
                                    AppLocalizations.of(context)!.mediano)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _buildOpcionTamano(
                                    AppLocalizations.of(context)!.grande)),
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
                            color: Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.tema,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
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
                            items: [
                              DropdownMenuItem(
                                  value: 0,
                                  child: Text(AppLocalizations.of(context)!
                                      .predeterminadoNaranja)),
                              DropdownMenuItem(
                                  value: 1,
                                  child: Text(AppLocalizations.of(context)!
                                      .modoOscuro)),
                              DropdownMenuItem(
                                  value: 2,
                                  child: Text(AppLocalizations.of(context)!
                                      .protanopia)),
                              DropdownMenuItem(
                                  value: 3,
                                  child: Text(AppLocalizations.of(context)!
                                      .deuteranopia)),
                              DropdownMenuItem(
                                  value: 4,
                                  child: Text(AppLocalizations.of(context)!
                                      .tritanopia)),
                              DropdownMenuItem(
                                  value: 5,
                                  child: Text(AppLocalizations.of(context)!
                                      .achromatopsia)),
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
                            idioma:
                                'Español', // Valor por defecto ya que idioma está en otro lado
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
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                    : Text(
                        AppLocalizations.of(context)!.guardarCambios,
                        style: const TextStyle(fontSize: 16),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final selectedColor =
        isDarkMode ? Colors.grey[700]! : Theme.of(context).primaryColor;
    final selectedTextColor =
        isDarkMode ? Colors.white : Theme.of(context).colorScheme.onPrimary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tamanoFuente = tamano;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? selectedColor : Theme.of(context).dividerColor,
            width: 2,
          ),
        ),
        child: Text(
          tamano,
          style: TextStyle(
            color: isSelected
                ? selectedTextColor
                : Theme.of(context).colorScheme.onSurface,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final selectedColor =
        isDarkMode ? Colors.grey[700]! : Theme.of(context).primaryColor;
    final selectedTextColor =
        isDarkMode ? Colors.white : Theme.of(context).colorScheme.onPrimary;

    return GestureDetector(
      onTap: () => _mostrarSliderTamanoFuente(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? selectedColor : Theme.of(context).dividerColor,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune,
              color: isSelected
                  ? selectedTextColor
                  : Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.personalizado,
              style: TextStyle(
                color: isSelected
                    ? selectedTextColor
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                '(${_tamanoFuentePersonalizado.round()}px)',
                style: TextStyle(color: selectedTextColor, fontSize: 12),
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
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              title: Row(
                children: [
                  Icon(Icons.format_size,
                      color: Theme.of(context).colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.tamanoPersonalizado,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.ejemploTexto,
                        style: TextStyle(
                          fontSize: tempTamano,
                          color: Theme.of(context).colorScheme.onSurface,
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                      Expanded(
                        child: Slider(
                          value: tempTamano,
                          min: 10.0,
                          max: 32.0,
                          divisions: 22,
                          activeColor: Theme.of(context).primaryColor,
                          inactiveColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.1),
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ],
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.tamanoLabel}: ${tempTamano.round()}px',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.cancelar,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
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
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.aplicar,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
