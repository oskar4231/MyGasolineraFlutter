import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/coches/presentacion/pages/coches.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/pages/layouthome.dart';

class AjustesFooter extends StatelessWidget {
  const AjustesFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CochesScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.directions_car,
              size: 40,
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.5),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const Layouthome(),
                ),
              );
            },
            icon: Icon(
              Icons.pin_drop,
              size: 40,
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.5),
            ),
          ),
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.settings,
              size: 40,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
