import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

class InfoRepostaje extends StatelessWidget {
  final TextEditingController litrosController;
  final TextEditingController precioLitroController;
  final TextEditingController kilometrajeController;
  final String? tipoCombustibleSeleccionado;
  final List<Map<String, dynamic>> coches;
  final int? cocheSeleccionado;
  final Function(int?) onCocheChanged;
  final Function(String?) onTipoCombustibleChanged;

  const InfoRepostaje({
    required this.litrosController,
    required this.precioLitroController,
    required this.kilometrajeController,
    required this.tipoCombustibleSeleccionado,
    required this.coches,
    required this.cocheSeleccionado,
    required this.onCocheChanged,
    required this.onTipoCombustibleChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const tiposCombustible = [
      'Gasolina 95',
      'Gasolina 98',
      'Diésel',
      'Diésel Premium',
      'GLP (Autogas)',
    ];

    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.infoRepostaje,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          color: Theme.of(context).colorScheme.onSurface,
          thickness: 1,
        ),
        const SizedBox(height: 16),
        // Dropdown Coche
        DropdownButtonFormField<int>(
          value: cocheSeleccionado,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.coche,
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
          items: coches.map((coche) {
            return DropdownMenuItem<int>(
              value: coche['id_coche'],
              child: Text(
                '${coche['marca']} ${coche['modelo']}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: onCocheChanged,
          dropdownColor: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: litrosController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.litros,
            hintText: 'Ej: 45.5',
            labelStyle:
                TextStyle(color: Theme.of(context).colorScheme.onSurface),
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: precioLitroController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '${AppLocalizations.of(context)!.precioLitro} (€)',
            hintText: 'Ej: 1.459',
            labelStyle:
                TextStyle(color: Theme.of(context).colorScheme.onSurface),
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: kilometrajeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.kilometraje,
            hintText: 'Ej: 45230',
            labelStyle:
                TextStyle(color: Theme.of(context).colorScheme.onSurface),
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
          child: DropdownButtonFormField<String>(
            value: tipoCombustibleSeleccionado,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.tipoCombustible,
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
            items: tiposCombustible.map((tipo) {
              return DropdownMenuItem<String>(
                value: tipo,
                child: Text(
                  tipo,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: onTipoCombustibleChanged,
            dropdownColor: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
