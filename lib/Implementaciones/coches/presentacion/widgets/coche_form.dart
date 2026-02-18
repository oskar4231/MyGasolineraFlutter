import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/coches/data/services/car_data_service.dart';

/// Datos que devuelve el formulario al confirmar.
class DatosCoche {
  final String marca;
  final String modelo;
  final List<String> tiposCombustible; // nombres localizados
  final int? kilometrajeInicial;
  final double? capacidadTanque;
  final double? consumoTeorico;

  const DatosCoche({
    required this.marca,
    required this.modelo,
    required this.tiposCombustible,
    this.kilometrajeInicial,
    this.capacidadTanque,
    this.consumoTeorico,
  });
}

/// Diálogo de formulario para añadir un coche.
/// Gestiona su propio estado interno y devuelve [DatosCoche] via [onConfirm].
class CocheForm extends StatefulWidget {
  final Future<void> Function(DatosCoche datos) onConfirm;
  final bool isLoading;

  const CocheForm({
    super.key,
    required this.onConfirm,
    this.isLoading = false,
  });

  /// Abre el diálogo y devuelve el resultado.
  static Future<void> mostrar(
    BuildContext context, {
    required Future<void> Function(DatosCoche datos) onConfirm,
    bool isLoading = false,
  }) {
    return showDialog(
      context: context,
      builder: (_) => CocheForm(onConfirm: onConfirm, isLoading: isLoading),
    );
  }

  @override
  State<CocheForm> createState() => _CocheFormState();
}

class _CocheFormState extends State<CocheForm> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _kilometrajeController = TextEditingController();
  final _capacidadController = TextEditingController();
  final _consumoController = TextEditingController();

  int? _selectedMarcaId;
  int? _selectedModeloId;
  dynamic _selectedMotorizacion;

  final Map<String, bool> _tiposCombustible = {
    'gasolina95': false,
    'gasolina98': false,
    'diesel': false,
    'dieselPremium': false,
    'glp': false,
    'hibrido': false,
  };

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _kilometrajeController.dispose();
    _capacidadController.dispose();
    _consumoController.dispose();
    super.dispose();
  }

  String _fuelLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'gasolina95':   return l10n.gasolina95;
      case 'gasolina98':   return l10n.gasolina98;
      case 'diesel':       return l10n.diesel;
      case 'dieselPremium':return l10n.dieselPremium;
      case 'glp':          return l10n.glp;
      case 'hibrido':      return l10n.hibrido;
      default:             return key;
    }
  }

  void _onMotorizacionChanged(dynamic value) {
    setState(() {
      _selectedMotorizacion = value;

      // Autorellenar consumo
      if (value['consumo'] != null) {
        final match = RegExp(r'(\d+[.,]?\d*)').firstMatch(value['consumo'] as String);
        if (match != null) {
          _consumoController.text = match.group(0)!.replaceAll(',', '.');
        }
      }

      // Autoseleccionar combustible
      _tiposCombustible.updateAll((k, v) => false);
      final combustible = value['combustible'] as String;
      if (combustible == 'Gasolina') {
        _tiposCombustible['gasolina95'] = true;
      } else if (combustible == 'Diésel' || combustible == 'Diesel') {
        _tiposCombustible['diesel'] = true;
      } else if (combustible == 'Híbrido' || combustible == 'Híbrido Enchufable' || combustible == 'Eléctrico') {
        _tiposCombustible['hibrido'] = true;
      } else if (combustible == 'GLP') {
        _tiposCombustible['glp'] = true;
      }
    });
  }

  Future<void> _confirmar(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final seleccionados = _tiposCombustible.entries
        .where((e) => e.value)
        .map((e) => _fuelLabel(e.key, l10n))
        .toList();

    if (seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.seleccionaCombustibleError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    await widget.onConfirm(DatosCoche(
      marca: _marcaController.text,
      modelo: _modeloController.text,
      tiposCombustible: seleccionados,
      kilometrajeInicial: _kilometrajeController.text.isNotEmpty
          ? int.tryParse(_kilometrajeController.text)
          : null,
      capacidadTanque: _capacidadController.text.isNotEmpty
          ? double.tryParse(_capacidadController.text)
          : null,
      consumoTeorico: _consumoController.text.isNotEmpty
          ? double.tryParse(_consumoController.text)
          : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final carService = CarDataService();
    final marcas = carService.getMarcas();
    final modelos = _selectedMarcaId != null ? carService.getModelos(_selectedMarcaId!) : [];
    final motorizaciones = _selectedModeloId != null ? carService.getMotorizaciones(_selectedModeloId!) : [];

    return AlertDialog(
      title: Text(l10n.anadirCoche, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Marca ────────────────────────────────────────────────────
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: l10n.marca,
                  hintText: l10n.ejemploMarca,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.directions_car),
                ),
                value: _selectedMarcaId,
                items: marcas.map<DropdownMenuItem<int>>((m) =>
                  DropdownMenuItem(value: m['id'], child: Text(m['nombre']))).toList(),
                onChanged: (value) => setState(() {
                  _selectedMarcaId = value;
                  _selectedModeloId = null;
                  _selectedMotorizacion = null;
                  _marcaController.text = marcas.firstWhere((m) => m['id'] == value)['nombre'];
                  _modeloController.clear();
                  _consumoController.clear();
                  _tiposCombustible.updateAll((k, v) => false);
                }),
                validator: (v) => v == null ? l10n.ingresaMarca : null,
              ),
              const SizedBox(height: 16),

              // ── Modelo ───────────────────────────────────────────────────
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: l10n.modelo,
                  hintText: l10n.ejemploModelo,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.car_crash),
                ),
                value: _selectedModeloId,
                items: modelos.map<DropdownMenuItem<int>>((m) =>
                  DropdownMenuItem(value: m['id'], child: Text(m['nombre']))).toList(),
                onChanged: (value) => setState(() {
                  _selectedModeloId = value;
                  _selectedMotorizacion = null;
                  _modeloController.text = modelos.firstWhere((m) => m['id'] == value)['nombre'];
                  _consumoController.clear();
                  _tiposCombustible.updateAll((k, v) => false);
                }),
                validator: (v) => v == null ? l10n.ingresaModelo : null,
                onTap: _selectedMarcaId == null
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, seleccione una marca primero.')))
                    : null,
              ),
              const SizedBox(height: 16),

              // ── Motorización (solo si hay modelo) ────────────────────────
              if (_selectedModeloId != null) ...[
                DropdownButtonFormField<dynamic>(
                  decoration: const InputDecoration(
                    labelText: 'Motorización',
                    hintText: 'Selecciona una motorización',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.settings_input_component),
                  ),
                  value: _selectedMotorizacion,
                  items: motorizaciones.map<DropdownMenuItem<dynamic>>((moto) =>
                    DropdownMenuItem(
                      value: moto,
                      child: Text('${moto['nombre']} (${moto['potencia']})'),
                    )).toList(),
                  onChanged: _onMotorizacionChanged,
                  validator: (v) => v == null ? 'Seleccione una motorización' : null,
                ),
                const SizedBox(height: 16),
              ],

              // ── Tipos de combustible ──────────────────────────────────────
              Text(l10n.tiposCombustibleLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._tiposCombustible.keys.map((key) => CheckboxListTile(
                title: Text(_fuelLabel(key, l10n)),
                value: _tiposCombustible[key],
                onChanged: (v) => setState(() => _tiposCombustible[key] = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              )),
              const SizedBox(height: 16),

              // ── Campos numéricos ──────────────────────────────────────────
              TextFormField(
                controller: _kilometrajeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.kilometrajeInicial,
                  hintText: l10n.ejemploKilometraje,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacidadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.capacidadTanque,
                  hintText: l10n.ejemploTanque,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _consumoController,
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
          onPressed: widget.isLoading ? null : () => _confirmar(l10n),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9350),
            foregroundColor: const Color(0xFF3E2723),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(l10n.guardar),
        ),
      ],
    );
  }
}
