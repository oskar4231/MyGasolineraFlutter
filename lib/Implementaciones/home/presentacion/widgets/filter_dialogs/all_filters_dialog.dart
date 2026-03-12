import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/main.dart' as app;

class AllFiltersDialog extends StatefulWidget {
  final String? initialSort;
  final Function(String?, double?, double?, String?, String?)? onApply;

  const AllFiltersDialog({
    super.key,
    this.initialSort,
    this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialSort,
    Function(String?, double?, double?, String?, String?)? onApply,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AllFiltersDialog(
        initialSort: initialSort,
        onApply: onApply,
      ),
    );
  }

  @override
  State<AllFiltersDialog> createState() => _AllFiltersDialogState();
}

class _AllFiltersDialogState extends State<AllFiltersDialog> {
  String? _combustibleTemp;
  double? _precioDesdeTemp;
  double? _precioHastaTemp;
  String? _aperturaTemp;
  String? _ordenTemp;

  @override
  void initState() {
    super.initState();
    // Cargar valores actuales desde el proveedor
    _combustibleTemp = app.filterProvider.tipoCombustibleSeleccionado;
    _precioDesdeTemp = app.filterProvider.precioDesde;
    _precioHastaTemp = app.filterProvider.precioHasta;
    _aperturaTemp = app.filterProvider.tipoAperturaSeleccionado;
    _ordenTemp = widget.initialSort;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores basados en la imagen (Apple-style / Cálido)
    const creamBg = Color(0xFFFBF1E6);
    const softOrange = Color(0xFFFB9B5F);
    const darkChocolate = Color(0xFF3E2723);

    final dialogBg = isDark
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.98)
        : creamBg.withValues(alpha: 0.98);
    final textColor = isDark ? const Color(0xFFEBEBEB) : darkChocolate;
    final accentColor = softOrange;
    final sectionTitleColor =
        isDark ? Colors.white70 : darkChocolate.withValues(alpha: 0.6);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Dialog(
        backgroundColor: dialogBg,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.filtros,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: textColor.withValues(alpha: 0.4)),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: textColor.withValues(alpha: 0.05),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Sección 1: Combustible (MAYOR RELEVANCIA)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildSectionTitle(
                              "1º ${l10n.tipoCombustible}", accentColor),
                          const Spacer(),
                          Text(
                            "REQUERIDO",
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildFuelOptions(isDark, accentColor, textColor, l10n),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 14,
                              color: accentColor.withValues(alpha: 0.7)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Selecciona primero el combustible para activar los filtros.",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Sección 2: Ordenar por Precio (Ascendente / Descendente)
                _buildSectionTitle("2º Ordenar Precio", sectionTitleColor),
                const SizedBox(height: 14),
                _buildSortOptions(isDark, accentColor, textColor, l10n),
                const SizedBox(height: 28),

                // Sección 3: Precio (Rango)
                _buildSectionTitle(l10n.filtrarPrecio, sectionTitleColor),
                const SizedBox(height: 14),
                _buildPriceInputs(isDark, accentColor, textColor, l10n),
                const SizedBox(height: 28),

                // Sección 4: Apertura
                _buildSectionTitle(l10n.apertura, sectionTitleColor),
                const SizedBox(height: 14),
                _buildOpeningOptions(isDark, accentColor, textColor, l10n),
                const SizedBox(height: 28),

                const SizedBox(height: 8),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _combustibleTemp = null;
                            _precioDesdeTemp = null;
                            _precioHastaTemp = null;
                            _aperturaTemp = null;
                            _ordenTemp = widget.initialSort;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: textColor.withValues(alpha: 0.03),
                        ),
                        child: Text(
                          'Limpiar',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          if (widget.onApply != null) {
                            widget.onApply!(
                              _combustibleTemp,
                              _precioDesdeTemp,
                              _precioHastaTemp,
                              _aperturaTemp,
                              _ordenTemp,
                            );
                          } else {
                            await app.filterProvider
                                .setTipoCombustible(_combustibleTemp);
                            await app.filterProvider.setPrecioFiltros(
                                _precioDesdeTemp, _precioHastaTemp);
                            await app.filterProvider
                                .setTipoApertura(_aperturaTemp);
                          }
                          nav.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shadowColor: accentColor.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          l10n.aplicar,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFuelOptions(
      bool isDark, Color accentColor, Color textColor, AppLocalizations l10n) {
    final fuels = {
      'Gasolina 95': '${l10n.gasolina} 95',
      'Gasolina 98': '${l10n.gasolina} 98',
      'Diesel': l10n.diesel,
      'Diesel Premium': '${l10n.diesel} Premium',
      'Gas': 'Gas (GLP)',
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: fuels.entries.map((e) {
        final isSelected = _combustibleTemp == e.key;
        return InkWell(
          onTap: () =>
              setState(() => _combustibleTemp = isSelected ? null : e.key),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? accentColor : textColor.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Text(
              e.value,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : textColor.withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceInputs(
      bool isDark, Color accentColor, Color textColor, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildPriceField(
            'Min',
            _precioDesdeTemp,
            (v) => setState(() => _precioDesdeTemp = v),
            isDark,
            accentColor,
            textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPriceField(
            'Max',
            _precioHastaTemp,
            (v) => setState(() => _precioHastaTemp = v),
            isDark,
            accentColor,
            textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField(
      String label,
      double? value,
      Function(double?) onChanged,
      bool isDark,
      Color accentColor,
      Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.1), width: 1.5),
      ),
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (v) => onChanged(double.tryParse(v)),
        decoration: InputDecoration(
          hintText: value?.toString() ?? label,
          hintStyle: TextStyle(
            color: textColor.withValues(alpha: 0.3),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.euro,
              size: 16, color: accentColor.withValues(alpha: 0.6)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: TextStyle(
            color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildOpeningOptions(
      bool isDark, Color accentColor, Color textColor, AppLocalizations l10n) {
    final options = {
      'Abierto ahora': l10n.abiertoAhora,
      '24 Horas': l10n.veinticuatroHoras,
    };

    return Row(
      children: options.entries.map((e) {
        final isSelected = (_aperturaTemp ?? '') == e.key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () =>
                  setState(() => _aperturaTemp = isSelected ? null : e.key),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? accentColor
                        : textColor.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : textColor.withValues(alpha: 0.8),
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSortOptions(
      bool isDark, Color accentColor, Color textColor, AppLocalizations l10n) {
    final sortOptions = {
      'Nombre': l10n.nombre,
      'Precio Ascendente': l10n.precioAscendente,
      'Precio Descendente': l10n.precioDescendente,
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: sortOptions.entries.map((e) {
        final isSelected = _ordenTemp == e.key;
        return InkWell(
          onTap: () => setState(() => _ordenTemp = e.key),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? accentColor : textColor.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Text(
              e.value,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : textColor.withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
