import 'package:flutter/material.dart';
import 'package:my_gasolinera/coches/coches.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/principal/layouthome.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  void _navigateTo(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const CochesScreen();
        break;
      case 1:
        nextScreen = const Layouthome();
        break;
      case 2:
        nextScreen = const AjustesScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Helper to build icon button
    Widget buildNavButton(IconData icon, int index) {
      final isSelected = currentIndex == index;
      return IconButton(
        onPressed: isSelected ? null : () => _navigateTo(context, index),
        icon: Icon(
          icon,
          size: 40,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimary.withValues(alpha: 0.5),
        ),
      );
    }

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
          buildNavButton(Icons.directions_car, 0),
          buildNavButton(Icons.pin_drop, 1),
          buildNavButton(Icons.settings, 2),
        ],
      ),
    );
  }
}
