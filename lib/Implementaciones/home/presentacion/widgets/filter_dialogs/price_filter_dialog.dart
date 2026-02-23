import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

class PriceFilterDialog extends StatefulWidget {
  final double? precioDesde;
  final double? precioHasta;
  final String? tipoCombustible;

  const PriceFilterDialog({
    super.key,
    this.precioDesde,
    this.precioHasta,
    this.tipoCombustible,
  });

  static Future<Map<String, double?>?> show(
    BuildContext context, {
    required double? precioDesde,
    required double? precioHasta,
    required String? tipoCombustible,
  }) async {
    return await showDialog<Map<String, double?>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PriceFilterDialog(
        precioDesde: precioDesde,
        precioHasta: precioHasta,
        tipoCombustible: tipoCombustible,
      ),
    );
  }

  @override
  State<PriceFilterDialog> createState() => _PriceFilterDialogState();
}

class _PriceFilterDialogState extends State<PriceFilterDialog> {
  late TextEditingController _desdeController;
  late TextEditingController _hastaController;
  String? _errorMessage;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _desdeController = TextEditingController(
      text: widget.precioDesde?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
    );
    _hastaController = TextEditingController(
      text: widget.precioHasta?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
    );
    _validarPrecios();
  }

  @override
  void dispose() {
    _desdeController.dispose();
    _hastaController.dispose();
    super.dispose();
  }

  void _validarPrecios() {
    final desde = double.tryParse(_desdeController.text.replaceAll(',', '.'));
    final hasta = double.tryParse(_hastaController.text.replaceAll(',', '.'));

    setState(() {
      if (desde != null && hasta != null && hasta < desde) {
        _errorMessage = 'El valor debe ser superior al desde';
        _isValid = false;
      } else {
        _errorMessage = null;
        _isValid = true;
      }
    });
  }

  void _aplicarFiltro() {
    if (!_isValid) return;

    final desdeText = _desdeController.text.replaceAll(',', '.');
    final hastaText = _hastaController.text.replaceAll(',', '.');

    final result = {
      'desde': desdeText.isNotEmpty ? double.tryParse(desdeText) : null,
      'hasta': hastaText.isNotEmpty ? double.tryParse(hastaText) : null,
    };

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dialogBackgroundColor =
        isDark ? const Color(0xFF212124) : theme.colorScheme.surface;
    final titleColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;
    final accentColor = isDark ? const Color(0xFFFF8235) : theme.primaryColor;
    final inputBgColor =
        isDark ? const Color(0xFF323236) : Colors.grey.withValues(alpha: 0.1);

    // Validación: requiere tipo de combustible
    if (widget.tipoCombustible == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.seleccioneCombustibleAlert,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: MediaQuery.of(context).size.height * 0.4,
            ),
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      });
      return const SizedBox.shrink();
    }

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
              l10n.filtrarPrecio,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.desde,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _desdeController,
              style: TextStyle(color: textColor),
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: true,
              ),
              onChanged: (_) => _validarPrecios(),
              inputFormatters: [
                _PriceInputFormatter(),
              ],
              decoration: InputDecoration(
                hintText: l10n.ejemploPrecio,
                hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
                filled: true,
                fillColor: inputBgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: isDark
                      ? const BorderSide(color: Color(0xFF38383A))
                      : BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: isDark
                      ? const BorderSide(color: Color(0xFF38383A))
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.hasta,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _hastaController,
              style: TextStyle(color: textColor),
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: true,
              ),
              onChanged: (_) => _validarPrecios(),
              inputFormatters: [
                _PriceInputFormatter(
                  getDesdeValue: () => double.tryParse(
                    _desdeController.text.replaceAll(',', '.'),
                  ),
                ),
              ],
              decoration: InputDecoration(
                hintText: l10n.ejemploPrecio,
                hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
                filled: true,
                fillColor: inputBgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: isDark
                      ? const BorderSide(color: Color(0xFF38383A))
                      : BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: isDark
                      ? const BorderSide(color: Color(0xFF38383A))
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                  onPressed: _isValid ? _aplicarFiltro : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValid
                        ? accentColor
                        : (isDark ? const Color(0xFF38383A) : Colors.grey[300]),
                    foregroundColor: _isValid
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? const Color(0xFF9E9E9E) : Colors.grey[600]),
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

class _PriceInputFormatter extends TextInputFormatter {
  final double? Function()? getDesdeValue;

  _PriceInputFormatter({this.getDesdeValue});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Solo dígitos
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Máximo 3 dígitos (X,XX)
    if (text.length > 3) {
      text = text.substring(0, 3);
    }

    String formattedText;
    if (text.length == 1) {
      formattedText = '$text,';
    } else {
      formattedText = '${text.substring(0, 1)},${text.substring(1)}';
    }

    // Si tenemos un valor "desde" para comparar
    if (getDesdeValue != null) {
      final desde = getDesdeValue!();
      if (desde != null) {
        // Lógica de bloqueo inteligente:
        // Solo bloqueamos si es IMPOSIBLE que el número que se está formando llegue a ser >= desde.

        // El valor máximo que se puede formar con los dígitos actuales:
        // Si tenemos "1,", el máximo es "1,99".
        // Si tenemos "1,4", el máximo es "1,49".
        String maxPossibleText = formattedText;
        if (text.length == 1) {
          maxPossibleText = '${text.substring(0, 1)},99';
        } else if (text.length == 2) {
          maxPossibleText = '${text.substring(0, 1)},${text.substring(1, 2)}9';
        }

        final maxVal = double.tryParse(maxPossibleText.replaceAll(',', '.'));
        if (maxVal != null && maxVal < desde) {
          // Si ni con el máximo posible llegamos al "desde", bloqueamos.
          return oldValue;
        }
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
