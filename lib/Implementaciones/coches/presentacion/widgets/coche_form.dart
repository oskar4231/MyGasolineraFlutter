import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _onMotorizacionChanged(dynamic value) {
    setState(() {
      _selectedMotorizacion = value;

      // Autorellenar consumo
      if (value['consumo'] != null) {
        final match =
            RegExp(r'(\d+[.,]?\d*)').firstMatch(value['consumo'] as String);
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
      } else if (combustible == 'Híbrido' ||
          combustible == 'Híbrido Enchufable' ||
          combustible == 'Eléctrico') {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final carService = CarDataService();
    final marcas = carService.getMarcas();
    final modelos = _selectedMarcaId != null
        ? carService.getModelos(_selectedMarcaId!)
        : [];
    final motorizaciones = _selectedModeloId != null
        ? carService.getMotorizaciones(_selectedModeloId!)
        : [];
    final dialogBg = isDark
        ? const Color(0xFF212124)
        : theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface;
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;
    final accentColor =
        isDark ? const Color(0xFFFF8235) : const Color(0xFFFF9350);
    final inputFillColor = isDark ? const Color(0xFF3E3E42) : null;
    final borderColor = isDark ? const Color(0xFF38383A) : null;
    final checkColor = isDark ? accentColor : theme.primaryColor;

    return AlertDialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isDark
            ? const BorderSide(color: Color(0xFF38383A), width: 1)
            : BorderSide.none,
      ),
      title: Text(
        l10n.anadirCoche,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : textColor,
        ),
      ),
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
                  labelStyle:
                      TextStyle(color: textColor.withValues(alpha: 0.7)),
                  hintText: l10n.ejemploMarca,
                  hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor ?? Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: borderColor ?? Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                  filled: isDark,
                  fillColor: inputFillColor,
                  prefixIcon: Icon(Icons.directions_car, color: accentColor),
                ),
                dropdownColor: isDark ? const Color(0xFF3E3E42) : null,
                style: TextStyle(color: textColor),
                value: _selectedMarcaId,
                items: marcas
                    .map<DropdownMenuItem<int>>((m) => DropdownMenuItem(
                        value: m['id'], child: Text(m['nombre'])))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedMarcaId = value;
                  _selectedModeloId = null;
                  _selectedMotorizacion = null;
                  _marcaController.text =
                      marcas.firstWhere((m) => m['id'] == value)['nombre'];
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
                  labelStyle:
                      TextStyle(color: textColor.withValues(alpha: 0.7)),
                  hintText: l10n.ejemploModelo,
                  hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor ?? Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: borderColor ?? Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                  filled: isDark,
                  fillColor: inputFillColor,
                  prefixIcon: Icon(Icons.car_crash, color: accentColor),
                ),
                dropdownColor: isDark ? const Color(0xFF3E3E42) : null,
                style: TextStyle(color: textColor),
                value: _selectedModeloId,
                items: modelos
                    .map<DropdownMenuItem<int>>((m) => DropdownMenuItem(
                        value: m['id'], child: Text(m['nombre'])))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedModeloId = value;
                  _selectedMotorizacion = null;
                  _modeloController.text =
                      modelos.firstWhere((m) => m['id'] == value)['nombre'];
                  _consumoController.clear();
                  _tiposCombustible.updateAll((k, v) => false);
                }),
                validator: (v) => v == null ? l10n.ingresaModelo : null,
                onTap: _selectedMarcaId == null
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Por favor, seleccione una marca primero.')))
                    : null,
              ),
              const SizedBox(height: 16),

              // ── Motorización (solo si hay modelo) ────────────────────────
              if (_selectedModeloId != null) ...[
                DropdownButtonFormField<dynamic>(
                  decoration: InputDecoration(
                    labelText: 'Motorización',
                    labelStyle:
                        TextStyle(color: textColor.withValues(alpha: 0.7)),
                    hintText: 'Selecciona una motorización',
                    hintStyle:
                        TextStyle(color: textColor.withValues(alpha: 0.4)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor ?? Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: borderColor ?? Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                    filled: isDark,
                    fillColor: inputFillColor,
                    prefixIcon: Icon(Icons.settings_input_component,
                        color: accentColor),
                  ),
                  dropdownColor: isDark ? const Color(0xFF3E3E42) : null,
                  style: TextStyle(color: textColor),
                  value: _selectedMotorizacion,
                  items: motorizaciones
                      .map<DropdownMenuItem<dynamic>>((moto) =>
                          DropdownMenuItem(
                            value: moto,
                            child:
                                Text('${moto['nombre']} (${moto['potencia']})'),
                          ))
                      .toList(),
                  onChanged: _onMotorizacionChanged,
                  validator: (v) =>
                      v == null ? 'Seleccione una motorización' : null,
                ),
                const SizedBox(height: 16),
              ],

              // ── Tipos de combustible ──────────────────────────────────────
              Text(l10n.tiposCombustibleLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  )),
              const SizedBox(height: 8),
              ..._tiposCombustible.keys.map((key) => CheckboxListTile(
                    title: Text(
                      _fuelLabel(key, l10n),
                      style: TextStyle(color: textColor),
                    ),
                    value: _tiposCombustible[key],
                    activeColor: checkColor,
                    checkColor: isDark ? Colors.black : Colors.white,
                    onChanged: (v) =>
                        setState(() => _tiposCombustible[key] = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  )),
              const SizedBox(height: 16),

              // ── Campos numéricos ──────────────────────────────────────────
              _buildTextField(
                controller: _kilometrajeController,
                label: l10n.kilometrajeInicial,
                hint: l10n.ejemploKilometraje,
                textColor: textColor,
                accentColor: accentColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
                isDark: isDark,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final valor = int.tryParse(v);
                  if (valor == null) return "Solo números enteros";
                  if (valor < 0) return "No puede ser negativo";
                  if (valor > 1000000) return "Máximo 1.000.000 km";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _capacidadController,
                label: l10n.capacidadTanque,
                hint: l10n.ejemploTanque,
                textColor: textColor,
                accentColor: accentColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
                isDark: isDark,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final cleanValue = v.replaceAll(',', '.');
                  final valor = double.tryParse(cleanValue);
                  if (valor == null) return "Formato inválido";
                  if (valor < 0) return "No puede ser negativo";
                  if (valor > 300) return "El tanque no puede superar los 300L";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _consumoController,
                label: l10n.consumoTeorico,
                hint: l10n.ejemploConsumo,
                textColor: textColor,
                accentColor: accentColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
                isDark: isDark,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return null;

                  final cleanValue = v.replaceAll(',', '.');
                  final valor = double.tryParse(cleanValue);

                  if (valor == null) return "Formato inválido";
                  if (valor < 0) return "No puede ser negativo";
                  if (valor > 50) return "El consumo no puede superar los 50.0";

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancelar,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: widget.isLoading ? null : () => _confirmar(l10n),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color textColor,
    required Color accentColor,
    Color? borderColor,
    Color? fillColor,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.number,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor.withValues(alpha: 0.7)),
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor ?? Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor ?? Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        filled: isDark,
        fillColor: fillColor,
      ),
    );
  }
}
