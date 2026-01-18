import 'package:flutter/material.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/services/coche_service.dart';
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

  final Map<String, bool> _tiposCombustible = {
    'Gasolina 95': false,
    'Gasolina 98': false,
    'Diésel': false,
    'Diésel Premium': false,
    'GLP (Autogas)': false,
    'Híbrido': false,
  };

  @override
  void initState() {
    super.initState();
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
      // Obtener los combustibles seleccionados
      final combustiblesSeleccionados = _tiposCombustible.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
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
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _marcaController,
                        decoration: InputDecoration(
                          labelText: l10n.marca,
                          hintText: l10n.ejemploMarca,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.directions_car),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.ingresaMarca;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _modeloController,
                        decoration: InputDecoration(
                          labelText: l10n.modelo,
                          hintText: l10n.ejemploModelo,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.car_crash),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.ingresaModelo;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.tiposCombustibleLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._tiposCombustible.keys.map((tipo) {
                        return CheckboxListTile(
                          title: Text(tipo),
                          value: _tiposCombustible[tipo],
                          onChanged: (bool? value) {
                            setDialogState(() {
                              _tiposCombustible[tipo] = value ?? false;
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _mostrarModalFormulario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.onPrimary, // White (usually)
                      foregroundColor: theme.colorScheme.primary, // Orange
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation:
                          0, // Flat look often fits better on colored headers
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.anadirCoche,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
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
                    onPressed: () {},
                    icon: Icon(
                      Icons.directions_car,
                      size: 40,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.pin_drop,
                      size: 40,
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.5),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AjustesScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.settings,
                      size: 40,
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
