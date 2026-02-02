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

  @override
  void initState() {
    super.initState();
    _desdeController = TextEditingController(
      text: widget.precioDesde?.toString().replaceAll('.', ',') ?? '',
    );
    _hastaController = TextEditingController(
      text: widget.precioHasta?.toString().replaceAll('.', ',') ?? '',
    );
  }

  @override
  void dispose() {
    _desdeController.dispose();
    _hastaController.dispose();
    super.dispose();
  }

  void _aplicarFiltro() {
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

    // Validación: requiere tipo de combustible
    if (widget.tipoCombustible == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.seleccioneCombustibleAlert,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFF9350),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.white,
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
              l10n.filtrarPrecio,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.desde,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _desdeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*[,.]?\d{0,3}'),
                ),
              ],
              decoration: InputDecoration(
                hintText: l10n.ejemploPrecio,
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
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
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _hastaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*[,.]?\d{0,3}'),
                ),
              ],
              decoration: InputDecoration(
                hintText: l10n.ejemploPrecio,
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _aplicarFiltro,
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
