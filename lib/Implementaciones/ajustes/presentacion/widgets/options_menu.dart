import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/pages/idiomas_screen.dart';
import 'package:my_gasolinera/Implementaciones/estadisticas/presentacion/pages/estadisticas.dart';
import 'package:my_gasolinera/Implementaciones/facturas/presentacion/pages/facturas_screen.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/pages/accesibilidad_screen.dart';

class OptionsMenu extends StatelessWidget {
  final VoidCallback onDeleteAccount;

  const OptionsMenu({
    super.key,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.opciones,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _OptionItem(
          icono: Icons.language,
          texto: l10n.idiomas,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const IdiomasScreen()),
            );
          },
        ),
        _OptionItem(
          icono: Icons.query_stats,
          texto: l10n.estadisticas,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EstadisticasScreen(),
              ),
            );
          },
        ),
        _OptionItem(
          icono: Icons.receipt,
          texto: l10n.gastosFacturas,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FacturasScreen()),
            );
          },
        ),
        _OptionItem(
          icono: Icons.accessibility_new,
          texto: l10n.accesibilidad,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccesibilidadScreen(),
              ),
            );
          },
        ),
        _OptionItem(
          icono: Icons.delete_outline,
          texto: l10n.borrarCuenta,
          onTap: onDeleteAccount,
        ),
      ],
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: theme.colorScheme.primary),
        ),
        title: Text(
          texto,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
