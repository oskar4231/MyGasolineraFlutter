import 'package:flutter/material.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';
import 'package:my_gasolinera/ajustes/facturas/FacturasScreen.dart';
import 'package:my_gasolinera/ajustes/estadisticas/estadisticas.dart';
import 'package:my_gasolinera/ajustes/accesibilidad/accesibilidad.dart';
import 'package:my_gasolinera/ajustes/idiomas/idiomas_screen.dart';

class AjustesOpciones extends StatelessWidget {
  final VoidCallback onBorrarCuenta;

  const AjustesOpciones({
    super.key,
    required this.onBorrarCuenta,
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
        _OpcionItem(
          icono: Icons.language,
          texto: l10n.idiomas,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const IdiomasScreen(),
              ),
            );
          },
        ),
        _OpcionItem(
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
        _OpcionItem(
          icono: Icons.receipt,
          texto: l10n.gastosFacturas,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FacturasScreen()),
            );
          },
        ),
        _OpcionItem(
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
        _OpcionItem(
          icono: Icons.delete_outline,
          texto: l10n.borrarCuenta,
          onTap: onBorrarCuenta,
        ),
      ],
    );
  }
}

class _OpcionItem extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  const _OpcionItem({
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
