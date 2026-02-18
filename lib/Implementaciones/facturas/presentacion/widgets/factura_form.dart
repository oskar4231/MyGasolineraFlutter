import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class FacturaForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController tituloController;
  final TextEditingController costoController;
  final TextEditingController fechaController;
  final TextEditingController horaController;
  final TextEditingController descripcionController;
  final Function(DateTime) onFechaChanged;
  final Function(TimeOfDay) onHoraChanged;

  const FacturaForm({
    required this.formKey,
    required this.tituloController,
    required this.costoController,
    required this.fechaController,
    required this.horaController,
    required this.descripcionController,
    required this.onFechaChanged,
    required this.onHoraChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: formKey,
      child: Column(
        children: [
          // Campo Título
          _buildWrappedField(
            child: TextFormField(
              controller: tituloController,
              decoration: _getInputDecoration(context, l10n.titulo),
              validator: (value) =>
                  (value == null || value.isEmpty) ? l10n.ingreseTitulo : null,
            ),
          ),
          const SizedBox(height: 16),

          // Campo Costo
          _buildWrappedField(
            child: TextFormField(
              controller: costoController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(
                    text: newValue.text.replaceAll(',', '.'),
                  );
                }),
              ],
              decoration:
                  _getInputDecoration(context, '${l10n.costeTotal} (€)'),
              validator: (value) {
                if (value == null || value.isEmpty) return l10n.ingreseCoste;
                if (!RegExp(r'^\d+([.,]\d{1,3})?$').hasMatch(value)) {
                  return l10n.formatoInvalido;
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Fila de Fecha y Hora
          Row(
            children: [
              Expanded(
                child: _buildWrappedField(
                  child: TextFormField(
                    controller: fechaController,
                    readOnly: true,
                    decoration: _getInputDecoration(context, l10n.fecha),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) onFechaChanged(picked);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWrappedField(
                  child: TextFormField(
                    controller: horaController,
                    readOnly: true,
                    decoration: _getInputDecoration(context, l10n.hora),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) onHoraChanged(picked);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Campo Descripción
          _buildWrappedField(
            child: TextFormField(
              controller: descripcionController,
              maxLines: 4,
              decoration:
                  _getInputDecoration(context, l10n.descripcionOpcional),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para envolver cualquier campo con la sombra
  Widget _buildWrappedField({required Widget child}) {
    return ShadowFieldWrapper(child: child);
  }

  // Helper para mantener el estilo de los inputs consistente
  InputDecoration _getInputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

// --- Componente de Sombreado ---
class ShadowFieldWrapper extends StatefulWidget {
  final Widget child;
  const ShadowFieldWrapper({required this.child, super.key});

  @override
  State<ShadowFieldWrapper> createState() => _ShadowFieldWrapperState();
}

class _ShadowFieldWrapperState extends State<ShadowFieldWrapper> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: _hasFocus
                ? Theme.of(context).primaryColor.withOpacity(0.15)
                : Colors.black
                    .withOpacity(0.05), // Sombra muy tenue si no hay foco
            blurRadius: _hasFocus ? 12 : 4,
            offset: _hasFocus ? const Offset(0, 4) : const Offset(0, 2),
          ),
        ],
      ),
      child: Focus(
        focusNode: _focusNode,
        child: widget.child,
      ),
    );
  }
}
