import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

/// Sección "Información del repostaje" del formulario de factura.
///
/// Escucha [litrosController] y [costoController] en tiempo real para
/// calcular automáticamente el precio/litro y actualizarlo en
/// [precioLitroController] (que se sigue enviando al backend igual que antes).
class InfoRepostaje extends StatefulWidget {
  final TextEditingController litrosController;
  final TextEditingController precioLitroController;
  final TextEditingController kilometrajeController;

  /// Necesario para calcular precio = coste ÷ litros en tiempo real.
  final TextEditingController costoController;

  final String? tipoCombustibleSeleccionado;
  final List<Map<String, dynamic>> coches;
  final int? cocheSeleccionado;
  final Function(int?) onCocheChanged;
  final Function(String?) onTipoCombustibleChanged;

  const InfoRepostaje({
    required this.litrosController,
    required this.precioLitroController,
    required this.costoController,
    required this.kilometrajeController,
    required this.tipoCombustibleSeleccionado,
    required this.coches,
    required this.cocheSeleccionado,
    required this.onCocheChanged,
    required this.onTipoCombustibleChanged,
    super.key,
  });

  @override
  State<InfoRepostaje> createState() => _InfoRepostajeState();
}

class _InfoRepostajeState extends State<InfoRepostaje> {
  /// Precio/litro calculado. null = chip oculto.
  double? _preciocalculado;

  /// Capacidad máxima del coche seleccionado. null = sin límite.
  double? _capacidadMaxima;

  @override
  void initState() {
    super.initState();
    // Calculamos después del primer frame para evitar setState durante build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _actualizarCapacidad(widget.cocheSeleccionado);
      _recalcular();
    });

    // Escuchar cambios en tiempo real.
    widget.litrosController.addListener(_recalcular);
    widget.costoController.addListener(_recalcular);
  }

  /// Busca la capacidad del tanque del coche [idCoche] en la lista de coches.
  void _actualizarCapacidad(int? idCoche) {
    if (idCoche == null) {
      if (mounted) setState(() => _capacidadMaxima = null);
      return;
    }
    final coche = widget.coches.firstWhere(
      (c) => c['id_coche'] == idCoche,
      orElse: () => {},
    );
    final capacidad = coche.isEmpty
        ? null
        : double.tryParse(coche['capacidad_tanque']?.toString() ?? '');
    if (mounted) setState(() => _capacidadMaxima = capacidad);
  }

  @override
  void dispose() {
    widget.litrosController.removeListener(_recalcular);
    widget.costoController.removeListener(_recalcular);
    super.dispose();
  }

  /// Recalcula precio = coste ÷ litros y actualiza [precioLitroController].
  void _recalcular() {
    final litros =
        double.tryParse(widget.litrosController.text.replaceAll(',', '.'));
    final coste =
        double.tryParse(widget.costoController.text.replaceAll(',', '.'));

    if (litros != null && litros > 0 && coste != null && coste > 0) {
      final calculado = coste / litros;
      final redondeado = double.parse(calculado.toStringAsFixed(3));

      // Actualizar el controller interno para que el backend reciba el valor.
      if (widget.precioLitroController.text !=
          redondeado.toStringAsFixed(3)) {
        widget.precioLitroController.text = redondeado.toStringAsFixed(3);
      }

      if (mounted) setState(() => _preciocalculado = redondeado);
    } else {
      // Si el precio venía prellenado desde la gasolinera y no hay litros,
      // intentar recuperarlo del controller.
      final prellenado = double.tryParse(
          widget.precioLitroController.text.replaceAll(',', '.'));
      if (mounted) setState(() => _preciocalculado = prellenado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFFFF8235) : theme.colorScheme.primary;

    const tiposCombustible = [
      'Gasolina 95',
      'Gasolina 98',
      'Diésel',
      'Diésel Premium',
      'GLP (Autogas)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.infoRepostaje,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: theme.colorScheme.onSurface, thickness: 1),
        const SizedBox(height: 16),

        // ── Selector de coche ──────────────────────────────────────────────
        ShadowFieldWrapper(
          child: DropdownButtonFormField<int>(
            value: widget.cocheSeleccionado,
            decoration:
                _getInputDecoration(context, l10n.coche),
            items: widget.coches.map((coche) {
              return DropdownMenuItem<int>(
                value: coche['id_coche'],
                child: Text(
                  '${coche['marca']} ${coche['modelo']}',
                  style:
                      TextStyle(color: theme.colorScheme.onSurface),
                ),
              );
            }).toList(),
            onChanged: (value) {
              _actualizarCapacidad(value);
              widget.onCocheChanged(value);
            },
            dropdownColor: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            icon: Icon(Icons.arrow_drop_down,
                color: theme.colorScheme.onSurface),
          ),
        ),
        const SizedBox(height: 16),

        // ── Litros + chip precio/litro calculado ───────────────────────────
        Row(
          children: [
            // Campo litros (ocupa todo el ancho si no hay chip, o la mitad)
            Expanded(
              child: ShadowFieldWrapper(
                child: TextFormField(
                  controller: widget.litrosController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9,.]')),
                  ],
                  decoration: _getInputDecoration(
                    context,
                    l10n.litros,
                    hint: _capacidadMaxima != null
                        ? 'Máx. ${_capacidadMaxima!.toStringAsFixed(0)} L'
                        : 'Ej: 45.5',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final litros = double.tryParse(
                        value.replaceAll(',', '.'));
                    if (litros == null) return 'Formato inválido';
                    if (litros <= 0) return 'Debe ser mayor que 0';
                    if (_capacidadMaxima != null &&
                        litros > _capacidadMaxima!) {
                      return 'Máx. ${_capacidadMaxima!.toStringAsFixed(0)} L (capacidad del tanque)';
                    }
                    return null;
                  },
                ),
              ),
            ),

            // Chip precio/litro — solo visible cuando hay cálculo
            if (_preciocalculado != null) ...[
              const SizedBox(width: 12),
              _PrecioChip(
                precio: _preciocalculado!,
                accentColor: accentColor,
                isDark: isDark,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // ── Kilometraje ────────────────────────────────────────────────────
        ShadowFieldWrapper(
          child: TextFormField(
            controller: widget.kilometrajeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _getInputDecoration(context, l10n.kilometraje,
                hint: 'Ej: 45230'),
          ),
        ),
        const SizedBox(height: 16),

        // ── Tipo de combustible ────────────────────────────────────────────
        ConstrainedBox(
          constraints:
              const BoxConstraints(minWidth: 300, maxWidth: double.infinity),
          child: ShadowFieldWrapper(
            child: DropdownButtonFormField<String>(
              value: widget.tipoCombustibleSeleccionado,
              isExpanded: true,
              decoration:
                  _getInputDecoration(context, l10n.tipoCombustible),
              items: tiposCombustible.map((tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface)),
                );
              }).toList(),
              onChanged: widget.onTipoCombustibleChanged,
              dropdownColor: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              icon: Icon(Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _getInputDecoration(BuildContext context, String label,
      {String? hint}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
      hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      filled: true,
      fillColor: Colors.transparent,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDense: true,
    );
  }
}

// ── Chip de precio calculado ───────────────────────────────────────────────────

class _PrecioChip extends StatelessWidget {
  final double precio;
  final Color accentColor;
  final bool isDark;

  const _PrecioChip({
    required this.precio,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.15 : 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_gas_station_outlined,
              size: 15, color: accentColor),
          const SizedBox(width: 5),
          Text(
            '${precio.toStringAsFixed(3)} €/L',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ShadowFieldWrapper ─────────────────────────────────────────────────────────

class ShadowFieldWrapper extends StatefulWidget {
  final Widget child;
  const ShadowFieldWrapper({required this.child, super.key});

  @override
  State<ShadowFieldWrapper> createState() => _ShadowFieldWrapperState();
}

class _ShadowFieldWrapperState extends State<ShadowFieldWrapper> {
  bool _hasFocus = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = Theme.of(context).cardColor;

    if (_hasFocus) {
      backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    } else if (_isHovered) {
      backgroundColor = Color.alphaBlend(
        Theme.of(context).hoverColor,
        Theme.of(context).cardColor,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Focus(
        onFocusChange: (value) => setState(() => _hasFocus = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color: _hasFocus
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.05),
                blurRadius: _hasFocus ? 12 : (_isHovered ? 8 : 4),
                offset: _hasFocus
                    ? const Offset(0, 4)
                    : const Offset(0, 2),
              ),
            ],
            border: _hasFocus
                ? Border.all(
                    color: Theme.of(context).primaryColor, width: 1.5)
                : Border.all(color: Colors.transparent, width: 1.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.child,
        ),
      ),
    );
  }
}
