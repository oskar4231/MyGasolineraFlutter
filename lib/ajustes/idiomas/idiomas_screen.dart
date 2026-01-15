import 'package:flutter/material.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';
import 'package:my_gasolinera/services/accesibilidad_service.dart';
import 'package:my_gasolinera/main.dart'; // Para languageProvider

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
      case 'ca':
        return 'Valenciano';
      default:
        return 'Español';
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
      print('Error cargando configuración: $e');
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
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.idiomas,
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
              color: Theme.of(context).cardColor,
              child: InkWell(
                onTap: () => _mostrarPopupIdioma(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.language,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.idiomaActual,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _idiomaSeleccionado,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.8),
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
                            .withOpacity(0.5),
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
                            idioma: _idiomaSeleccionado,
                            tamanoFuente: _tamanoFuente,
                            altoContraste: _altoContraste,
                            modoOscuro: _modoOscuro,
                          );

                          setState(() {
                            _cargando = false;
                          });

                          if (exito && mounted) {
                            // Actualizar idioma globalmente
                            await languageProvider
                                .changeLanguage(_idiomaSeleccionado);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)!.idiomaGuardado,
                                ),
                                duration: const Duration(seconds: 2),
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
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Row(
            children: [
              Icon(Icons.language,
                  color: Theme.of(context).colorScheme.onSurface),
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
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;

                final selectedColor = isDarkMode
                    ? Colors.grey[700]!
                    : Theme.of(context).primaryColor;
                final selectedTextColor = isDarkMode
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimary;

                return Card(
                  elevation: esSeleccionado ? 4 : 1,
                  color: esSeleccionado
                      ? selectedColor
                      : Theme.of(context).cardColor,
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 0,
                  ),
                  child: ListTile(
                    title: Text(
                      idioma,
                      style: TextStyle(
                        color: esSeleccionado
                            ? selectedTextColor
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: esSeleccionado
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: esSeleccionado
                          ? selectedTextColor
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
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
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;

                final selectedColor =
                    isDarkMode ? Colors.grey[700]! : const Color(0xFFFF9350);
                final selectedTextColor =
                    isDarkMode ? Colors.white : Colors.black;

                return Card(
                  elevation: esSeleccionado ? 4 : 1,
                  color: esSeleccionado ? selectedColor : Colors.white,
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 0,
                  ),
                  child: ListTile(
                    title: Text(
                      variante,
                      style: TextStyle(
                        color:
                            esSeleccionado ? selectedTextColor : Colors.black,
                        fontWeight: esSeleccionado
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: esSeleccionado
                        ? Icon(Icons.check_circle, color: selectedTextColor)
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
              child: Text(AppLocalizations.of(context)!.atras,
                  style: const TextStyle(color: Colors.black)),
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
          backgroundColor: Theme.of(context).dialogBackgroundColor,
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
