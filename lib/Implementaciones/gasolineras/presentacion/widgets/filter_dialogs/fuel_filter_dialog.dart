import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

class FuelFilterDialog extends StatefulWidget {
  final String? valorActual;

  const FuelFilterDialog({
    super.key,
    this.valorActual,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String? valorActual,
  }) async {
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FuelFilterDialog(valorActual: valorActual),
    );
  }

  @override
  State<FuelFilterDialog> createState() => _FuelFilterDialogState();
}

class _FuelFilterDialogState extends State<FuelFilterDialog> {
  String? _valorTemporal;

  @override
  void initState() {
    super.initState();
    _valorTemporal = widget.valorActual;
  }

  Widget _buildCheckboxOption(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
        value: _valorTemporal == value,
        onChanged: (bool? checked) {
          setState(() {
            _valorTemporal = checked == true ? value : null;
          });
        },
        activeColor: Theme.of(context).colorScheme.primary,
        checkColor: Theme.of(context).colorScheme.onPrimary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final opciones = {
      'Gasolina 95': '${l10n.gasolina} 95',
      'Gasolina 98': '${l10n.gasolina} 98',
      'Diesel': l10n.diesel,
      'Diesel Premium': '${l10n.diesel} Premium',
      'Gas': 'Gas (GLP)',
    };

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tiposCombustible,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ...opciones.entries.map(
              (entry) => _buildCheckboxOption(entry.value, entry.key),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancelar,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, {'applied': true, 'value': _valorTemporal}),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.aplicar,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
