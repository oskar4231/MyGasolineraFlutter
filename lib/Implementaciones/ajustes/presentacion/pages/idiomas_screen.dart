import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/data/services/accesibilidad_service.dart';
import 'package:my_gasolinera/main.dart'; // Para languageProvider
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/predeterminado.dart';

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
        return 'Valencià';
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
        return 'CUSTOM_VALENCIA';
      case 'Català':
        return '🇪🇸';
      default:
        return '🌐';
    }
  }

  // Widget para mostrar bandera (emoji o imagen)
  Widget _buildFlagWidget(String languageName, {double size = 28}) {
    final flag = _getFlagForLanguage(languageName);

    if (flag == 'CUSTOM_VALENCIA') {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores adaptativos (patrón Accesibilidad/Facturas)
    final primaryColor = isDark ? const Color(0xFFFF8235) : const Color(0xFFFF8200);

    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;

    final lighterCardColor = isDark
        ? const Color(0xFF3E3E42)
        : Color.lerp(
            theme.cardTheme.color ?? theme.cardColor, Colors.white, 0.25);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header plano estilo Accesibilidad/Facturas
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
                    AppLocalizations.of(context)!.idiomas,
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
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tarjeta idioma actual
                    Container(
                      decoration: BoxDecoration(
                        color: lighterCardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : const Color(0x1A2D1509),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _mostrarPopupIdioma(),
                          borderRadius: BorderRadius.circular(12),
                          hoverColor: primaryColor.withValues(alpha: 0.1),
                          splashColor: primaryColor.withValues(alpha: 0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                _buildFlagWidget(_idiomaSeleccionado, size: 28),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .idiomaActual,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _idiomaSeleccionado,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              textColor.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: textColor.withValues(alpha: 0.5),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botón guardar
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
                                  final localizations =
                                      AppLocalizations.of(context)!;

                                  try {
                                    setState(() {
                                      _cargando = true;
                                    });

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

                                      await languageProvider
                                          .changeLanguage(_idiomaSeleccionado);

                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            localizations.idiomaGuardado,
                                          ),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: MyGasolineraColors.success,
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
                                          backgroundColor: MyGasolineraColors.error,
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
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        isDark ? Colors.black : Colors.white),
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.guardarCambios,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF212124)
        : (theme.cardTheme.color ?? theme.cardColor);

    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;

    final primaryColor = isDark ? const Color(0xFFFF8235) : const Color(0xFFFF8200);

    final borderColor = isDark ? const Color(0xFF38383A) : theme.dividerColor;

    final Map<String, List<String>> idiomasConVariantes = {
      'Español': ['Español'],
      'Português': ['Português'],
      'Deutsch': ['Deutsch'],
      'Italiano': ['Italiano'],
      'English': ['English'],
      'Français': ['Français'],
      'Valencià': ['Valencià', 'Català'],
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor, width: 1),
          ),
          title: Row(
            children: [
              const Text('🌐', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.seleccionarIdioma,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              itemCount: idiomasConVariantes.keys.length,
              separatorBuilder: (context, index) => Divider(
                color: borderColor.withValues(alpha: 0.3),
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final idioma = idiomasConVariantes.keys.elementAt(index);
                final esSeleccionado = _idiomaSeleccionado.startsWith(idioma);

                final backgroundColor =
                    esSeleccionado ? primaryColor.withValues(alpha: 0.15) : Colors.transparent;
                final itemTextColor = esSeleccionado ? primaryColor : textColor;

                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    final variantes = idiomasConVariantes[idioma]!;

                    if (variantes.length == 1) {
                      _confirmarCambioIdioma(variantes[0]);
                    } else {
                      _mostrarVariantesIdioma(idioma, variantes);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4),
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
                          color: itemTextColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: esSeleccionado
                            ? primaryColor
                            : textColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? Colors.black : theme.colorScheme.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.cancelar,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Popup para seleccionar variante regional del idioma
  void _mostrarVariantesIdioma(String idiomaBase, List<String> variantes) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF212124)
        : (theme.cardTheme.color ?? theme.cardColor);

    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;

    final primaryColor = isDark ? const Color(0xFFFF8235) : const Color(0xFFFF8200);

    final borderColor = isDark ? const Color(0xFF38383A) : theme.dividerColor;

    final lighterCardColor = isDark
        ? const Color(0xFF3E3E42)
        : Color.lerp(
            theme.cardTheme.color ?? theme.cardColor, Colors.white, 0.25);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor, width: 1),
          ),
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: textColor),
                hoverColor:
                    isDark ? null : primaryColor.withValues(alpha: 0.25),
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
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: variantes.length,
              itemBuilder: (context, index) {
                final variante = variantes[index];
                final esSeleccionado = _idiomaSeleccionado == variante;

                final backgroundColor =
                    esSeleccionado ? primaryColor : lighterCardColor;
                final itemTextColor = esSeleccionado
                    ? (isDark ? Colors.black : theme.colorScheme.onPrimary)
                    : textColor;

                return Card(
                  elevation: 0,
                  color: backgroundColor,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: esSeleccionado
                        ? BorderSide(color: primaryColor, width: 2)
                        : BorderSide(color: borderColor, width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: Icon(
                      esSeleccionado
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: esSeleccionado
                          ? (isDark
                              ? Colors.black
                              : theme.colorScheme.onPrimary)
                          : textColor.withValues(alpha: 0.5),
                    ),
                    title: Text(
                      variante,
                      style: TextStyle(
                        fontWeight: esSeleccionado
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: itemTextColor,
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
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _mostrarPopupIdioma();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? Colors.black : theme.colorScheme.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.atras,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Confirmación antes de cambiar el idioma
  void _confirmarCambioIdioma(String nuevoIdioma) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF212124)
        : (theme.cardTheme.color ?? theme.cardColor);

    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;

    final primaryColor = isDark ? const Color(0xFFFF8235) : const Color(0xFFFF8200);

    final borderColor = isDark ? const Color(0xFF38383A) : theme.dividerColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor, width: 1),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: isDark ? Colors.white : primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.confirmarCambio,
                  style: TextStyle(
                    color: isDark ? Colors.white : primaryColor,
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
                color: textColor.withValues(alpha: 0.8), fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.no,
                  style: TextStyle(color: textColor)),
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
                    backgroundColor: primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor:
                    isDark ? Colors.black : theme.colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.si),
            ),
          ],
        );
      },
    );
  }
}
