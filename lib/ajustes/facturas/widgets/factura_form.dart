import 'package:flutter/material.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: tituloController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.titulo,
              labelStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onSurface),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.ingreseTitulo;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: costoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText:
                  '${AppLocalizations.of(context)!.costeTotal} (€)',
              labelStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onSurface),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.ingreseCoste;
              }
              if (!RegExp(r'^\d+([.,]\d{1,3})?$').hasMatch(value)) {
                return AppLocalizations.of(context)!.formatoInvalido;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: fechaController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.fecha,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      onFechaChanged(picked);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: horaController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.hora,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      onHoraChanged(picked);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descripcionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText:
                  AppLocalizations.of(context)!.descripcionOpcional,
              labelStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onSurface),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}