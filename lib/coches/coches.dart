import 'package:flutter/material.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/principal/layouthome.dart';

import 'package:my_gasolinera/services/coche_service.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';
import 'package:my_gasolinera/models/coche.dart';
import 'package:my_gasolinera/coches/widgets/coche_card.dart';
import 'package:my_gasolinera/metodos/dialog_helper.dart';
import 'package:my_gasolinera/services/car_data_service.dart';

class CochesScreen extends StatefulWidget {
  const CochesScreen({super.key});

  @override
  State<CochesScreen> createState() => _CochesScreenState();
}

class _CochesScreenState extends State<CochesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _kilometrajeInicialController = TextEditingController();
  final _capacidadTanqueController = TextEditingController();
  final _consumoTeoricoController = TextEditingController();
  final _fechaUltimoCambioAceiteController = TextEditingController();
  final _kmUltimoCambioAceiteController = TextEditingController();
  final _intervaloKmController = TextEditingController(text: '15000');
  final _intervaloMesesController = TextEditingController(text: '12');

  final List<Coche> _coches = [];
  bool _isLoading = false;

  // Internal keys for mapping
  // Map of combustible keys. If dynamic data introduces new types, logic needs to handle it.
  final Map<String, bool> _tiposCombustible = {
    'gasolina95': false,
    'gasolina98': false,
    'diesel': false,
    'dieselPremium': false,
    'glp': false,
    'hibrido': false,
  };

  // ... (rest of class)

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

  void initState() {
    super.initState();
    CarDataService().loadData(); // Cargar datos de coches
    _cargarCoches();
  }

  // Función para cargar los coches usando el servicio
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

  // Función para crear un coche usando el servicio
  Future<void> _crearCoche() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final l10n = AppLocalizations.of(context)!;
      // Obtener los combustibles seleccionados (nombres localizados)
      final combustiblesSeleccionados = _tiposCombustible.entries
          .where((entry) => entry.value)
          .map((entry) => _getLocalizedFuelName(entry.key, l10n))
          .toList();

      await CocheService.crearCoche(
        marca: _marcaController.text,
        modelo: _modeloController.text,
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
              .cocheCreadoExito(_marcaController.text, _modeloController.text),
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

    // Reset controllers
    _marcaController.clear();
    _modeloController.clear();
    _tiposCombustible.updateAll((key, value) => false);
    _kilometrajeInicialController.clear();
    _capacidadTanqueController.clear();
    _consumoTeoricoController.clear();
    _fechaUltimoCambioAceiteController.clear();
    _kmUltimoCambioAceiteController.clear();
    _intervaloKmController.text = '15000';
    _intervaloMesesController.text = '12';

    // State variables for dropdowns
    int? selectedMarcaId;
    int? selectedModeloId;
    dynamic selectedMotorizacion;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final carService = CarDataService();
            final marcas = carService.getMarcas();
            final modelos = selectedMarcaId != null
                ? carService.getModelos(selectedMarcaId!)
                : [];
            final motorizaciones = selectedModeloId != null
                ? carService.getMotorizaciones(selectedModeloId!)
                : [];

            return AlertDialog(
              title: Text(
                l10n.anadirCoche,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Marca Dropdown
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: l10n.marca,
                          hintText: l10n.ejemploMarca,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.directions_car),
                        ),
                        value: selectedMarcaId,
                        items: marcas.map<DropdownMenuItem<int>>((marca) {
                          return DropdownMenuItem<int>(
                            value: marca['id'],
                            child: Text(marca['nombre']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMarcaId = value;
                            selectedModeloId = null; // Reset dependants
                            selectedMotorizacion = null;
                            _marcaController.text = marcas
                                .firstWhere((m) => m['id'] == value)['nombre'];
                            _modeloController.clear();
                            _consumoTeoricoController.clear();
                            _tiposCombustible.updateAll((key, val) => false);
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return l10n.ingresaMarca;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Modelo Dropdown
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: l10n.modelo,
                          hintText: l10n.ejemploModelo,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.car_crash),
                        ),
                        value: selectedModeloId,
                        items: modelos.map<DropdownMenuItem<int>>((modelo) {
                          return DropdownMenuItem<int>(
                            value: modelo['id'],
                            child: Text(modelo['nombre']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedModeloId = value;
                            selectedMotorizacion = null;
                            _modeloController.text = modelos
                                .firstWhere((m) => m['id'] == value)['nombre'];
                            _consumoTeoricoController.clear();
                            _tiposCombustible.updateAll((key, val) => false);
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return l10n.ingresaModelo;
                          }
                          return null;
                        },
                        onTap: selectedMarcaId == null
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Por favor, seleccione una marca primero.')),
                                );
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Motorización Dropdown
                      if (selectedModeloId != null) ...[
                        DropdownButtonFormField<dynamic>(
                          decoration: InputDecoration(
                            labelText: 'Motorización',
                            hintText: 'Selecciona una motorización',
                            border: const OutlineInputBorder(),
                            prefixIcon:
                                const Icon(Icons.settings_input_component),
                          ),
                          value: selectedMotorizacion,
                          items: motorizaciones
                              .map<DropdownMenuItem<dynamic>>((moto) {
                            return DropdownMenuItem<dynamic>(
                              value: moto,
                              child: Text(
                                  '${moto['nombre']} (${moto['potencia']})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedMotorizacion = value;
                                // Update Consumo
                                if (value['consumo'] != null) {
                                  // Extract number from string like "5.5 l/100km" or "17.5 kWh/100km"
                                  final consumoStr = value['consumo'] as String;
                                  final match = RegExp(r'(\d+[.,]?\d*)')
                                      .firstMatch(consumoStr);
                                  if (match != null) {
                                    _consumoTeoricoController.text =
                                        match.group(0)!.replaceAll(',', '.');
                                  }
                                }

                                // Update Combustible
                                final combustible =
                                    value['combustible'] as String;
                                _tiposCombustible.updateAll(
                                    (key, val) => false); // Reset all

                                // Map string to internal keys
                                if (combustible == 'Gasolina') {
                                  _tiposCombustible['gasolina95'] = true;
                                } else if (combustible == 'Diésel' ||
                                    combustible == 'Diesel') {
                                  _tiposCombustible['diesel'] = true;
                                } else if (combustible == 'Híbrido') {
                                  _tiposCombustible['hibrido'] = true;
                                } else if (combustible ==
                                    'Híbrido Enchufable') {
                                  _tiposCombustible['hibrido'] = true;
                                } else if (combustible == 'Eléctrico') {
                                  _tiposCombustible['hibrido'] =
                                      true; // Eléctrico mapped to hibrido logic for now
                                } else if (combustible == 'GLP') {
                                  _tiposCombustible['glp'] = true;
                                }
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Seleccione una motorización';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

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
                          controlAffinity: ListTileControlAffinity.leading,
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
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const Layouthome(),
                          ),
                        ),
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
