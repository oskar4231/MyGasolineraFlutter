import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/data/services/accesibilidad_service.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/theme_manager.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/main.dart' as app;
import 'package:my_gasolinera/core/utils/app_logger.dart';

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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: theme.colorScheme.onPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.accesibilidad,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.accesibilidadConfig,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tamaño de fuente
                    Card(
                      elevation: 2,
                      color: theme.cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.text_fields,
                                    color: theme.colorScheme.onSurface),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.tamanoFuente,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
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
                                        child:
                                            _buildOpcionTamano(l10n.pequeno)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child:
                                            _buildOpcionTamano(l10n.mediano)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: _buildOpcionTamano(l10n.grande)),
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
                      color: theme.cardTheme.color,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.palette,
                                    color: theme.colorScheme.onSurface),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.tema,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ListenableBuilder(
                                listenable: ThemeManager(),
                                builder: (context, _) {
                                  return DropdownButtonFormField<int>(
                                    initialValue: ThemeManager().currentThemeId,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                      filled: true,
                                      fillColor: theme.scaffoldBackgroundColor,
                                    ),
                                    dropdownColor: theme.cardColor,
                                    items: [
                                      DropdownMenuItem(
                                          value: 0,
                                          child:
                                              Text(l10n.predeterminadoNaranja)),
                                      DropdownMenuItem(
                                          value: 1,
                                          child: Text(l10n.modoOscuro)),
                                      DropdownMenuItem(
                                          value: 2,
                                          child: Text(l10n.protanopia)),
                                      DropdownMenuItem(
                                          value: 3,
                                          child: Text(l10n.deuteranopia)),
                                      DropdownMenuItem(
                                          value: 4,
                                          child: Text(l10n.tritanopia)),
                                      DropdownMenuItem(
                                          value: 5,
                                          child: Text(l10n.achromatopsia)),
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
                                final messenger = ScaffoldMessenger.of(context);
                                final navigator = Navigator.of(context);
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
                                          '✅ Configuración guardada correctamente',
                                        ),
                                        duration: Duration(seconds: 2),
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
                          backgroundColor: theme.primaryColor,
                          foregroundColor: theme.colorScheme.onPrimary,
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
                                l10n.guardarCambios,
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
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
        // Aplicar inmediatamente el cambio
        app.fontSizeProvider.changeFontSizeByPreset(tamano);
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
              backgroundColor: Theme.of(context).dialogTheme.backgroundColor ??
                  Theme.of(context).colorScheme.surface,
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
                            .withValues(alpha: 0.5),
                      ),
                      Expanded(
                        child: Slider(
                          value: tempTamano,
                          min: 12.0,
                          max: 24.0,
                          divisions: 12,
                          activeColor: Theme.of(context).primaryColor,
                          inactiveColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.1),
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
                            .withValues(alpha: 0.5),
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
                    // Aplicar inmediatamente el cambio
                    app.fontSizeProvider.changeFontSizeCustom(tempTamano);
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
