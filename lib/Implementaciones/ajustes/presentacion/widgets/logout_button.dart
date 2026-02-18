import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFFF8235) : theme.primaryColor;
    final onPrimary = isDark ? Colors.black : theme.colorScheme.onPrimary;

    return Center(
      child: ElevatedButton.icon(
        onPressed: onLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar Sesión'),
      ),
    );
  }
}
