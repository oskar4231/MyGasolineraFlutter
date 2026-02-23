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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dialogBackgroundColor = isDark
        ? const Color(0xFF212124) // Fondo premium modo oscuro
        : theme.colorScheme.surface;
    final titleColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;
    final accentColor = isDark ? const Color(0xFFFF8235) : theme.primaryColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isDark
                ? const BorderSide(color: Color(0xFF38383A), width: 1)
                : BorderSide.none,
          ),
          title: Text(
            AppLocalizations.of(context)!.cerrarSesion,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.confirmarCerrarSesion,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancelar,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF9E9E9E)
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: isDark ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(
                AppLocalizations.of(context)!.cerrarSesion,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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
            final isDark = theme.brightness == Brightness.dark;
            final dialogBackgroundColor =
                isDark ? const Color(0xFF323236) : theme.colorScheme.surface;
            final titleColor =
                isDark ? const Color(0xFFFF8235) : theme.colorScheme.onSurface;
            final textColor =
                isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;

            return AlertDialog(
              backgroundColor: dialogBackgroundColor,
              title: Text(
                AppLocalizations.of(context)!.borrarCuenta,
                style: TextStyle(color: titleColor),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.confirmarBorrarCuenta,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                  if (eliminando) ...[
                    const SizedBox(height: 16),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(isDark
                          ? const Color(0xFFFF8235)
                          : theme.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.eliminandoCuenta,
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ],
              ),
              actions: [
                if (!eliminando) ...[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context)!.cancelar,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF9E9E9E)
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setDialogState(() => eliminando = true);
                      await onDelete(context);
                      if (context.mounted) {
                        setDialogState(() => eliminando = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFFFF8235)
                          : theme.colorScheme.error,
                      foregroundColor: isDark
                          ? const Color(0xFF151517)
                          : theme.colorScheme.onError,
                    ),
                    child: Text(AppLocalizations.of(context)!.eliminar),
                  ),
                ]
              ],
            );
          },
        );
      },
    );
  }
}
