import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/login.dart';

class AjustesDialogs {
  static void showImagePickerDialog(
    BuildContext context, {
    required VoidCallback onGallery,
    required VoidCallback onCamera,
  }) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.cambiarFotoPerfil),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(l10n.seleccionarFuenteFoto)],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onGallery();
              },
              child: Text(l10n.galeria),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCamera();
              },
              child: Text(l10n.camara),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelar),
            ),
          ],
        );
      },
    );
  }

  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.cerrarSesion),
          content: Text(AppLocalizations.of(context)!.confirmarCerrarSesion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancelar),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(AppLocalizations.of(context)!.cerrarSesion),
            ),
          ],
        );
      },
    );
  }

  static void showDeleteAccountDialog(
    BuildContext context, {
    required Future<void> Function(BuildContext) onDelete,
  }) {
    final theme = Theme.of(context);
    bool eliminando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.borrarCuenta),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.confirmarBorrarCuenta,
                    style: TextStyle(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.87),
                      fontSize: 16,
                    ),
                  ),
                  if (eliminando) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context)!.eliminandoCuenta),
                  ],
                ],
              ),
              actions: [
                if (!eliminando)
                  ElevatedButton(
                    onPressed: () async {
                      setDialogState(() => eliminando = true);
                      await onDelete(context);
                      // If onDelete fails or finishes without navigation, we might need to reset.
                      // But typically onDelete will handle navigation or show error.
                      // If we are here, maybe we should close dialog if it failed?
                      // Let's assume onDelete handles the flow.
                      // Ideally, if it fails, it throws or we pass a callback for error.
                      // For now simpler is better.
                      if (context.mounted) {
                        setDialogState(() => eliminando = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.eliminar,
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                if (!eliminando)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context)!.cancelar),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
