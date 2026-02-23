import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

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

  Widget _buildCheckboxOption(String title, String value, bool isDark,
      Color accentColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF323236)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF38383A) : Colors.transparent,
          width: 1,
        ),
      ),
      child: CheckboxListTile(
        title: Text(title, style: TextStyle(color: textColor)),
        value: _valorTemporal == value,
        onChanged: (bool? checked) {
          setState(() {
            _valorTemporal = checked == true ? value : null;
          });
        },
        activeColor: accentColor,
        checkColor: isDark ? Colors.black : Colors.white,
        side: BorderSide(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dialogBackgroundColor =
        isDark ? const Color(0xFF212124) : theme.colorScheme.surface;
    final titleColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;
    final accentColor = isDark ? const Color(0xFFFF8235) : theme.primaryColor;

    return Dialog(
      backgroundColor: dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isDark
            ? const BorderSide(color: Color(0xFF38383A), width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tiposCombustible,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 20),
            ...opciones.entries.map(
              (entry) => _buildCheckboxOption(
                  entry.value, entry.key, isDark, accentColor, textColor),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancelar,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF9E9E9E)
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _valorTemporal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
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
