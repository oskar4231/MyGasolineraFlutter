import 'package:flutter/material.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';

class FuelFilterDialog extends StatefulWidget {
  final String? valorActual;

  const FuelFilterDialog({
    super.key,
    this.valorActual,
  });

  static Future<String?> show(
    BuildContext context, {
    required String? valorActual,
  }) async {
    return await showDialog<String>(
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
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        value: _valorTemporal == value,
        onChanged: (bool? checked) {
          setState(() {
            _valorTemporal = checked == true ? value : null;
          });
        },
        activeColor: Colors.white,
        checkColor: const Color(0xFFFF9350),
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
      backgroundColor: const Color(0xFFFF9350),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tiposCombustible,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _valorTemporal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF9350),
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
