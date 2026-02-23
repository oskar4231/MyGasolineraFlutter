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
        ShadowFieldWrapper(
          child: DropdownButtonFormField<int>(
            value: cocheSeleccionado,
            decoration: _getInputDecoration(
                context, AppLocalizations.of(context)!.coche),
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
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ShadowFieldWrapper(
                child: TextFormField(
                  controller: litrosController,
                  keyboardType: TextInputType.number,
                  decoration: _getInputDecoration(
                      context, AppLocalizations.of(context)!.litros,
                      hint: 'Ej: 45.5'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ShadowFieldWrapper(
                child: TextFormField(
                  controller: precioLitroController,
                  keyboardType: TextInputType.number,
                  decoration: _getInputDecoration(context,
                      '${AppLocalizations.of(context)!.precioLitro} (€)',
                      hint: 'Ej: 1.459'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ShadowFieldWrapper(
          child: TextFormField(
            controller: kilometrajeController,
            keyboardType: TextInputType.number,
            decoration: _getInputDecoration(
                context, AppLocalizations.of(context)!.kilometraje,
                hint: 'Ej: 45230'),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
          child: ShadowFieldWrapper(
            child: DropdownButtonFormField<String>(
              initialValue: tipoCombustibleSeleccionado,
              isExpanded: true,
              decoration: _getInputDecoration(
                  context, AppLocalizations.of(context)!.tipoCombustible),
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
        ),
      ],
    );
  }

  InputDecoration _getInputDecoration(BuildContext context, String label,
      {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
      ),
      filled: true,
      fillColor: Colors.transparent, // El fondo lo da el Wrapper
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDense: true,
    );
  }
}

// --- Componente de Sombreado (Copiado para consistencia local) ---
class ShadowFieldWrapper extends StatefulWidget {
  final Widget child;
  const ShadowFieldWrapper({required this.child, super.key});

  @override
  State<ShadowFieldWrapper> createState() => _ShadowFieldWrapperState();
}

class _ShadowFieldWrapperState extends State<ShadowFieldWrapper> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine background color based on state
    Color backgroundColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_hasFocus) {
      backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    } else if (_isHovered) {
      // Rounded hover effect color
      backgroundColor = isDark
          ? const Color(0xFF383838)
          : Theme.of(context).cardColor.withOpacity(0.9);

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
                    ? Theme.of(context).primaryColor.withOpacity(0.15)
                    : Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
                blurRadius: _hasFocus ? 12 : (_isHovered ? 8 : 4),
                offset: _hasFocus ? const Offset(0, 4) : const Offset(0, 2),
              ),
            ],
            border: _hasFocus
                ? Border.all(color: Theme.of(context).primaryColor, width: 1.5)
                : Border.all(color: Colors.transparent, width: 1.0),
          ),
          clipBehavior:
              Clip.antiAlias, // Ensures hover color respects rounded corners
          child: widget.child,
        ),
      ),
    );
  }
}
