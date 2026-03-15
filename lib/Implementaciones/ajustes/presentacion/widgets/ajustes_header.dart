import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

class AjustesHeader extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations l10n;

  const AjustesHeader({
    super.key,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    final appBarContentColor =
        isDark ? Colors.white : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      // Eliminamos decoración de fondo para hacerlo transparente
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Título (Centrado)
          Text(
            l10n.ajustesTitulo,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 28, // Más grande como solicitado
              fontWeight: FontWeight.bold,
              color: appBarContentColor, // Usamos el color de texto adaptable
            ),
          ),
        ],
      ),
    );
  }
}
