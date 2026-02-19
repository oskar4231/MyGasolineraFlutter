import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/pages/layouthome.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';

class AjustesHeader extends StatelessWidget {
  const AjustesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final appBarContentColor =
        isDark ? Colors.white : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      // Eliminamos decoración de fondo para hacerlo transparente
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Botón Atrás (Alineado a la izquierda)
          Align(
            alignment: Alignment.centerLeft,
            child: HoverBackButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Layouthome()),
              ),
            ),
          ),
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
