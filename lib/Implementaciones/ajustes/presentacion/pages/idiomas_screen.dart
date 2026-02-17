import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/data/services/accesibilidad_service.dart';
import 'package:my_gasolinera/main.dart'; // Para languageProvider
import 'package:my_gasolinera/core/utils/app_logger.dart';

class IdiomasScreen extends StatefulWidget {
  const IdiomasScreen({super.key});

  @override
  State<IdiomasScreen> createState() => _IdiomasScreenState();
}

class _IdiomasScreenState extends State<IdiomasScreen> {
  String _idiomaSeleccionado = 'Español';
  String _tamanoFuente = 'Mediano';
  bool _altoContraste = false;
  bool _modoOscuro = false;
  final _accesibilidadService = AccesibilidadService();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  // Mapeo inverso: de código ISO a nombre completo
  String _getLanguageNameFromCode(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'pt':
        return 'Português';
      case 'it':
        return 'Italiano';
      case 'fr':
        return 'Français';
      case 'ca':
        return 'Valencià'; // Cambiado para coincidir con las variantes del popup
      default:
        return 'Español';
    }
  }

  // Mapeo de idioma a bandera
  String _getFlagForLanguage(String languageName) {
    switch (languageName) {
      case 'Español':
        return '🇪🇸';
      case 'English':
        return '🇬🇧';
      case 'Deutsch':
        return '🇩🇪';
      case 'Português':
        return '🇵🇹';
      case 'Italiano':
        return '🇮🇹';
      case 'Français':
        return '🇫🇷';
      case 'Valencià':
        return 'CUSTOM_VALENCIA'; // Marcador especial para imagen personalizada
      case 'Català':
        return '🇪🇸'; // Cataluña
      default:
        return '🌐';
    }
  }

  // Widget para mostrar bandera (emoji o imagen)
  Widget _buildFlagWidget(String languageName, {double size = 28}) {
    final flag = _getFlagForLanguage(languageName);

    if (flag == 'CUSTOM_VALENCIA') {
      // Mantener tamaño de 50px
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          'assets/images/iconoValencia.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Text(
        flag,
        style: TextStyle(fontSize: size),
      );
    }
  }

  /// Carga la configuración desde el backend
  Future<void> _cargarConfiguracion() async {
    try {
      // PRIMERO: Cargar idioma actual desde LanguageProvider (es la verdad)
      final currentLanguageCode = languageProvider.languageCode;
      final languageName = _getLanguageNameFromCode(currentLanguageCode);

      // SEGUNDO: Cargar otras configuraciones desde backend
      final config = await _accesibilidadService.obtenerConfiguracion();
      if (config != null && mounted) {
        setState(() {
          _idiomaSeleccionado =
              languageName; // Usar el del provider, NO del backend
          _tamanoFuente = config['tamanoFuente'] ?? 'Mediano';
          _altoContraste = config['altoContraste'] ?? false;
          _modoOscuro = config['modoOscuro'] ?? false;
          _cargando = false;
        });
      } else {
        setState(() {
          _idiomaSeleccionado =
              languageName; // Asegurar que se usa el del provider
          _cargando = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error cargando configuración',
          tag: 'IdiomasScreen', error: e);
      if (mounted) {
        // Fallback al idioma del provider
        final currentLanguageCode = languageProvider.languageCode;
        final languageName = _getLanguageNameFromCode(currentLanguageCode);
        setState(() {
          _idiomaSeleccionado = languageName;
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header (naranja como Accesibilidad)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.idiomas,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                      AppLocalizations.of(context)!.configuracionIdioma,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Idioma - con popup scrollable
                    Card(
                      elevation: 2,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2C2C2C)
                          : Theme.of(context).cardColor,
                      child: InkWell(
                        onTap: () => _mostrarPopupIdioma(),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              _buildFlagWidget(_idiomaSeleccionado, size: 28),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .idiomaActual,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _idiomaSeleccionado,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
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
                                final messenger = ScaffoldMessenger.of(context);
                                final navigator = Navigator.of(context);
                                final localizations =
                                    AppLocalizations.of(context)!;

                                try {
                                  // Mostrar indicador de carga
                                  setState(() {
                                    _cargando = true;
                                  });

                                  // Guardar en el backend
                                  final exito = await _accesibilidadService
                                      .guardarConfiguracion(
                                    idioma: _idiomaSeleccionado,
                                    tamanoFuente: _tamanoFuente,
                                    altoContraste: _altoContraste,
                                    modoOscuro: _modoOscuro,
                                  );
                                  if (exito) {
                                    if (mounted) {
                                      setState(() {
                                        _cargando = false;
                                      });
                                    }

                                    // Actualizar idioma globalmente
                                    await languageProvider
                                        .changeLanguage(_idiomaSeleccionado);

                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localizations.idiomaGuardado,
                                        ),
                                        duration: const Duration(seconds: 2),
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
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
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
            ),
          ],
        ),
      ),
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
      'Français': ['Français'],
      'Valencià': [
        'Valencià',
        'Català'
      ], // Cambiado de 'Valenciano' a 'Valencià'
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Theme.of(context).dialogTheme.backgroundColor ??
                  Theme.of(context).colorScheme.surface,
          title: Row(
            children: [
              const Text('🌐', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.seleccionarIdioma,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
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

                // Colores consistentes con el resto de la app en modo oscuro
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final backgroundColor = esSeleccionado
                    ? (isDarkMode
                        ? const Color(0xFF2C2C2C)
                        : Theme.of(context).colorScheme.primary)
                    : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white);
                final textColor = esSeleccionado
                    ? (isDarkMode
                        ? Colors.white
                        : Theme.of(context).colorScheme.onPrimary)
                    : (isDarkMode ? Colors.white70 : Colors.black87);

                return Card(
                  elevation: esSeleccionado ? 4 : 1,
                  color: backgroundColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: esSeleccionado
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.only(
                      left: idioma == 'Valencià' ? 8 : 16,
                      right: 16,
                      top: 0,
                      bottom: 0,
                    ),
                    leading: _buildFlagWidget(idioma,
                        size: idioma == 'Valencià' ? 50 : 32),
                    title: Text(
                      idioma,
                      style: TextStyle(
                        fontWeight: esSeleccionado
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: textColor,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: esSeleccionado
                          ? Theme.of(context).colorScheme.primary
                          : (isDarkMode ? Colors.white70 : Colors.black54),
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
              child: Text(
                AppLocalizations.of(context)!.cancelar,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Theme.of(context).dialogTheme.backgroundColor ??
                  Theme.of(context).colorScheme.surface,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  Navigator.of(context).pop();
                  _mostrarPopupIdioma();
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  idiomaBase,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
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

                // Colores consistentes con el resto de la app en modo oscuro
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final backgroundColor = esSeleccionado
                    ? (isDarkMode
                        ? const Color(0xFF2C2C2C)
                        : Theme.of(context).colorScheme.primary)
                    : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white);
                final textColor = esSeleccionado
                    ? (isDarkMode
                        ? Colors.white
                        : Theme.of(context).colorScheme.onPrimary)
                    : (isDarkMode ? Colors.white70 : Colors.black87);

                return Card(
                  elevation: esSeleccionado ? 4 : 1,
                  color: backgroundColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: esSeleccionado
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: esSeleccionado
                          ? Theme.of(context).colorScheme.primary
                          : (isDarkMode ? Colors.white70 : Colors.black54),
                    ),
                    title: Text(
                      variante,
                      style: TextStyle(
                        fontWeight: esSeleccionado
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: textColor,
                      ),
                    ),
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
              child: Text(AppLocalizations.of(context)!.atras,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
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
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor ??
              Theme.of(context).colorScheme.surface,
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.confirmarCambio,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.seguroCambiarIdioma(nuevoIdioma),
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
                fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.no,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _idiomaSeleccionado = nuevoIdioma;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!
                        .idiomaCambiado(nuevoIdioma)),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(AppLocalizations.of(context)!.si,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary)),
            ),
          ],
        );
      },
    );
  }
}
