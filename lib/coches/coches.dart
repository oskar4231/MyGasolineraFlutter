import 'package:flutter/material.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/principal/layouthome.dart';

import 'package:my_gasolinera/services/coche_service.dart';
import 'package:my_gasolinera/services/vehiculo_service.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';
import 'package:my_gasolinera/models/coche.dart';
import 'package:my_gasolinera/coches/widgets/coche_card.dart';
import 'package:my_gasolinera/metodos/dialog_helper.dart';

class CochesScreen extends StatefulWidget {
  const CochesScreen({super.key});

  @override
  State<CochesScreen> createState() => _CochesScreenState();
}

class _CochesScreenState extends State<CochesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController =
      TextEditingController(); // Keeps the text for validation
  final _modeloController = TextEditingController();
  final _versionController =
      TextEditingController(); // New controller for version/motor
  final _kilometrajeInicialController = TextEditingController();
  final _capacidadTanqueController = TextEditingController();
  final _consumoTeoricoController = TextEditingController();
  final _fechaUltimoCambioAceiteController = TextEditingController();
  final _kmUltimoCambioAceiteController = TextEditingController();
  final _intervaloKmController = TextEditingController(text: '15000');
  final _intervaloMesesController = TextEditingController(text: '12');

  final List<Coche> _coches = [];
  bool _isLoading = false;
  bool _isDownloadingData = false;

  // Internal keys for mapping
  final Map<String, bool> _tiposCombustible = {
    'gasolina95': false,
    'gasolina98': false,
    'diesel': false,
    'dieselPremium': false,
    'glp': false,
    'hibrido': false,
  };

  String _getLocalizedFuelName(String key, AppLocalizations l10n) {
    switch (key) {
      case 'gasolina95':
        return l10n.gasolina95;
      case 'gasolina98':
        return l10n.gasolina98;
      case 'diesel':
        return l10n.diesel;
      case 'dieselPremium':
        return l10n.dieselPremium;
      case 'glp':
        return l10n.glp;
      case 'hibrido':
        return l10n.hibrido;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarCoches();
    _initVehicleData();
  }

  Future<void> _initVehicleData() async {
    setState(() {
      _isDownloadingData = true;
    });
    try {
      await VehicleService.initializeData();
    } catch (e) {
      print('Error initializing vehicle data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingData = false;
        });
      }
    }
  }

  Future<void> _cargarCoches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cochesJson = await CocheService.obtenerCoches();
      final List<Map<String, dynamic>> cochesList =
          List<Map<String, dynamic>>.from(cochesJson);

      setState(() {
        _coches.clear();
        _coches.addAll(
          cochesList.map((json) => Coche.fromJson(json)).toList(),
        );
      });
      print('✅ ${_coches.length} coches cargados');
    } catch (error) {
      print('Error al cargar coches: $error');
      if (mounted) {
        DialogHelper.showErrorSnackbar(
            context,
            AppLocalizations.of(context)!
                .errorCargarCochesDetalle(error.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _crearCoche() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final l10n = AppLocalizations.of(context)!;
      final combustiblesSeleccionados = _tiposCombustible.entries
          .where((entry) => entry.value)
          .map((entry) => _getLocalizedFuelName(entry.key, l10n))
          .toList();

      // Append version if selected to give more info (cylinders etc)
      String modelToSave = _modeloController.text;
      if (_versionController.text.isNotEmpty) {
        modelToSave = '$modelToSave ${_versionController.text}';
      }

      await CocheService.crearCoche(
        marca: _marcaController.text,
        modelo: modelToSave, // Save model + version
        tiposCombustible: combustiblesSeleccionados,
        kilometrajeInicial: _kilometrajeInicialController.text.isNotEmpty
            ? int.tryParse(_kilometrajeInicialController.text)
            : null,
        capacidadTanque: _capacidadTanqueController.text.isNotEmpty
            ? double.tryParse(_capacidadTanqueController.text)
            : null,
        consumoTeorico: _consumoTeoricoController.text.isNotEmpty
            ? double.tryParse(_consumoTeoricoController.text)
            : null,
        fechaUltimoCambioAceite:
            _fechaUltimoCambioAceiteController.text.isNotEmpty
                ? _fechaUltimoCambioAceiteController.text
                : null,
        kmUltimoCambioAceite: _kmUltimoCambioAceiteController.text.isNotEmpty
            ? int.tryParse(_kmUltimoCambioAceiteController.text)
            : null,
        intervaloCambioAceiteKm:
            int.tryParse(_intervaloKmController.text) ?? 15000,
        intervaloCambioAceiteMeses:
            int.tryParse(_intervaloMesesController.text) ?? 12,
      );

      if (mounted) {
        DialogHelper.showSuccessSnackbar(
          context,
          AppLocalizations.of(context)!
              .cocheCreadoExito(_marcaController.text, modelToSave),
        );
        await _cargarCoches();
      }
    } catch (error) {
      print('Error al crear coche: $error');
      if (mounted) {
        DialogHelper.showErrorSnackbar(context,
            AppLocalizations.of(context)!.errorCrearCoche(error.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _versionController.dispose();
    _kilometrajeInicialController.dispose();
    _capacidadTanqueController.dispose();
    _consumoTeoricoController.dispose();
    _fechaUltimoCambioAceiteController.dispose();
    _kmUltimoCambioAceiteController.dispose();
    _intervaloKmController.dispose();
    _intervaloMesesController.dispose();
    super.dispose();
  }

  void _mostrarModalFormulario() {
    final l10n = AppLocalizations.of(context)!;

    // Clear all controllers
    _marcaController.clear();
    _modeloController.clear();
    _versionController.clear();
    _tiposCombustible.updateAll((key, value) => false);
    _kilometrajeInicialController.clear();
    _capacidadTanqueController.clear();
    _consumoTeoricoController.clear();
    _fechaUltimoCambioAceiteController.clear();
    _kmUltimoCambioAceiteController.clear();
    _intervaloKmController.text = '15000';
    _intervaloMesesController.text = '12';

    // Temporary variables for autocomplete state
    List<String> marcasDisponibles = VehicleService.getMakes();
    List<String> modelosDisponibles = [];
    List<Map<String, dynamic>> versionesDisponibles = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                l10n.anadirCoche,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: _isDownloadingData
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (marcasDisponibles.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  "Descargando base de datos de coches...",
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                            // MARCA AUTOCOMPLETE
                            Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<String>.empty();
                                }
                                return marcasDisponibles.where((String option) {
                                  return option.toLowerCase().contains(
                                        textEditingValue.text.toLowerCase(),
                                      );
                                });
                              },
                              onSelected: (String selection) {
                                setDialogState(() {
                                  _marcaController.text = selection;
                                  _modeloController.clear();
                                  _versionController.clear();
                                  modelosDisponibles =
                                      VehicleService.getModels(selection);
                                });
                              },
                              fieldViewBuilder: (context, textEditingController,
                                  focusNode, onFieldSubmitted) {
                                // Sync with our main controller if needed, but usually Autocomplete uses its own
                                // We prefer to update _marcaController on selection or manual edit
                                textEditingController.text =
                                    _marcaController.text;
                                textEditingController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: _marcaController.text.length));

                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                      labelText: l10n.marca,
                                      hintText: "Ej: Honda",
                                      border: const OutlineInputBorder(),
                                      prefixIcon:
                                          const Icon(Icons.directions_car),
                                      suffixIcon: _marcaController
                                              .text.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(Icons.clear),
                                              onPressed: () {
                                                setDialogState(() {
                                                  _marcaController.clear();
                                                  textEditingController.clear();
                                                  modelosDisponibles = [];
                                                });
                                              },
                                            )
                                          : null),
                                  onChanged: (val) {
                                    _marcaController.text = val;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.ingresaMarca;
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // MODELO AUTOCOMPLETE
                            Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                // Show all if empty to help discovery
                                if (modelosDisponibles.isEmpty)
                                  return const Iterable<String>.empty();
                                if (textEditingValue.text == '')
                                  return modelosDisponibles;

                                return modelosDisponibles
                                    .where((String option) {
                                  return option.toLowerCase().contains(
                                        textEditingValue.text.toLowerCase(),
                                      );
                                });
                              },
                              onSelected: (String selection) {
                                setDialogState(() {
                                  _modeloController.text = selection;
                                  _versionController.clear();
                                  // Fetch Versions
                                  versionesDisponibles =
                                      VehicleService.getVersions(
                                          _marcaController.text, selection);
                                });
                              },
                              fieldViewBuilder: (context, textEditingController,
                                  focusNode, onFieldSubmitted) {
                                textEditingController.text =
                                    _modeloController.text;
                                textEditingController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: _modeloController.text.length));

                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  enabled: _marcaController.text.isNotEmpty,
                                  decoration: InputDecoration(
                                    labelText: l10n.modelo,
                                    hintText: "Ej: Civic",
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.car_crash),
                                  ),
                                  onChanged: (val) {
                                    _modeloController.text = val;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.ingresaModelo;
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // VERSION (MOTOR/CILINDROS) DROPDOWN
                            // Using a DropdownButtonFormField for versions as they are detailed strings and selection is key
                            // If empty or custom, user can't easily type a new version, but for now let's use Dropdown for the data
                            if (versionesDisponibles.isNotEmpty)
                              DropdownButtonFormField<Map<String, dynamic>>(
                                decoration: InputDecoration(
                                  labelText: "Version / Motor",
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(
                                      Icons.settings_input_component),
                                ),
                                isExpanded: true,
                                items: versionesDisponibles.map((versionMap) {
                                  String displayText =
                                      "${versionMap['engine'] ?? ''} - ${versionMap['year'] ?? ''}";
                                  if (versionMap['cylinders'] != null) {
                                    displayText +=
                                        " (${versionMap['cylinders']} cil)";
                                  }
                                  return DropdownMenuItem(
                                    value: versionMap,
                                    child: Text(displayText,
                                        overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged:
                                    (Map<String, dynamic>? selectedVersion) {
                                  if (selectedVersion == null) return;
                                  setDialogState(() {
                                    String displayText =
                                        "${selectedVersion['engine'] ?? ''} ${selectedVersion['year'] ?? ''}";
                                    if (selectedVersion['cylinders'] != null) {
                                      displayText +=
                                          " (${selectedVersion['cylinders']} cil)";
                                    }
                                    _versionController.text = displayText;

                                    // Auto-fill known fields if available
                                    if (selectedVersion['fuel_type'] != null) {
                                      // Reset first
                                      _tiposCombustible
                                          .updateAll((key, value) => false);

                                      String fuel = selectedVersion['fuel_type']
                                          .toString()
                                          .toLowerCase();
                                      if (fuel.contains('premium') ||
                                          fuel.contains('98'))
                                        _tiposCombustible['gasolina98'] = true;
                                      else if (fuel.contains('gasoline') ||
                                          fuel.contains('petrol'))
                                        _tiposCombustible['gasolina95'] = true;
                                      else if (fuel.contains('diesel'))
                                        _tiposCombustible['diesel'] = true;
                                      else if (fuel.contains('hybrid'))
                                        _tiposCombustible['hibrido'] = true;
                                      else if (fuel.contains('lpg') ||
                                          fuel.contains('glp'))
                                        _tiposCombustible['glp'] = true;
                                    }

                                    // If DB had tank/consumption we would use it, but ilyasozkurt json might not have consumption in standard L/100km
                                    // We leave those manual unless we find a specific field
                                  });
                                },
                              ),
                            if (versionesDisponibles.isNotEmpty)
                              const SizedBox(height: 16),

                            Text(
                              l10n.tiposCombustibleLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._tiposCombustible.keys.map((key) {
                              return CheckboxListTile(
                                title: Text(_getLocalizedFuelName(key, l10n)),
                                value: _tiposCombustible[key],
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    _tiposCombustible[key] = value ?? false;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                dense: true,
                              );
                            }),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _kilometrajeInicialController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.kilometrajeInicial,
                                hintText: l10n.ejemploKilometraje,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _capacidadTanqueController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.capacidadTanque,
                                hintText: l10n.ejemploTanque,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _consumoTeoricoController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.consumoTeorico,
                                hintText: l10n.ejemploConsumo,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancelar),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            bool alMenosUnoCombustible =
                                _tiposCombustible.values.any((v) => v);

                            if (!alMenosUnoCombustible) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.seleccionaCombustibleError,
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            Navigator.of(context).pop();
                            await _crearCoche();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9350),
                    foregroundColor: const Color(0xFF3E2723),
                  ),
                  child: _isLoading
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
                      : Text(l10n.guardar),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Función para eliminar un coche usando el servicio
  Future<void> _eliminarCoche(int index) async {
    final coche = _coches[index];

    if (coche.idCoche == null) {
      if (mounted) {
        DialogHelper.showErrorSnackbar(
            context, AppLocalizations.of(context)!.errorCocheSinId);
      }
      return;
    }

    // Using specialized modular dialog
    DialogHelper.showConfirmationDialog(
      context: context,
      title: AppLocalizations.of(context)!.confirmarEliminacion,
      content: AppLocalizations.of(context)!
          .confirmarEliminarCoche(coche.marca, coche.modelo),
      confirmText: AppLocalizations.of(context)!.eliminar,
      cancelText: AppLocalizations.of(context)!.cancelar,
      isDestructive: true,
      onConfirm: () async {
        setState(() {
          _isLoading = true;
        });

        try {
          await CocheService.eliminarCoche(coche.idCoche!);

          if (mounted) {
            DialogHelper.showSuccessSnackbar(
                context,
                AppLocalizations.of(context)!
                    .cocheEliminado(coche.marca, coche.modelo));

            await _cargarCoches();
          }
        } catch (error) {
          print('Error al eliminar coche: $error');
          if (mounted) {
            DialogHelper.showErrorSnackbar(
                context,
                AppLocalizations.of(context)!
                    .errorEliminarCoche(error.toString()));
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Using Scaffold with SAFEAREA and custom containers for Header/Footer
    // to match "Image 2" style (Orange Header/Footer with rounded corners)
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      // No AppBar, using custom body header
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header matching Layouthome style
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: theme.colorScheme.onPrimary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        l10n.cochesTitulo,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      // Spacer for balance if needed, or empty SizedBox
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),

            // Body Content
            Expanded(
              child: _coches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car_outlined,
                            size: 80,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noHayCoches,
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.pulsaAnadirCoche,
                            style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _coches.length,
                      itemBuilder: (context, index) {
                        return CocheCard(
                          coche: _coches[index],
                          onDelete: () => _eliminarCoche(index),
                        );
                      },
                    ),
            ),

            // Footer matching Layouthome style
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: null, // Ya estamos en Coches
                    icon: Icon(
                      Icons.directions_car,
                      size: 40,
                      color:
                          theme.colorScheme.onPrimary, // Seleccionado - claro
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const Layouthome(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.pin_drop,
                      size: 40,
                      color: theme.colorScheme.onPrimary
                          .withValues(alpha: 0.5), // No seleccionado - apagado
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const AjustesScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.settings,
                      size: 40,
                      color: theme.colorScheme.onPrimary
                          .withValues(alpha: 0.5), // No seleccionado - apagado
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 80), // Subir el FAB para no eclipsar el footer
        child: FloatingActionButton(
          onPressed: _mostrarModalFormulario,
          backgroundColor: theme.primaryColor,
          child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
