import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/pages/layouthome.dart';

class AjustesHeader extends StatelessWidget {
  const AjustesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? const Color(0xFF212124)
        : (theme.cardTheme.color ?? theme.cardColor);
    final lighterCardColor = isDark
        ? const Color(0xFF3E3E42)
        : Color.lerp(cardColor, Colors.white, 0.25);

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
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: lighterCardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: appBarContentColor,
                ),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Layouthome()),
                ),
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
