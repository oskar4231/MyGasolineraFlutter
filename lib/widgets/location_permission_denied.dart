import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/controllers/map_controller.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';



/// Widget que informa al usuario del estado de su permiso de ubicación
/// cuando éste no ha sido concedido.
///
/// Distingue tres situaciones:
/// - [LocationPermissionState.denied]: el permiso fue rechazado pero puede
///   volver a solicitarse. Muestra un botón "Permitir acceso".
/// - [LocationPermissionState.deniedForever]: el sistema no permite volver a
///   pedir el permiso. El botón lleva al usuario a los Ajustes del sistema.
/// - [LocationPermissionState.serviceDisabled]: el GPS del dispositivo está
///   apagado, independientemente de los permisos. Se le indica que lo active.
class LocationPermissionDenied extends StatelessWidget {
  /// Estado concreto que motiva la pantalla (no debe ser [loading] ni [granted]).
  final LocationPermissionState state;

  /// Callback que se invoca cuando el usuario pulsa el botón de acción
  /// (reintentar solicitud o abrir ajustes). El padre es responsable de
  /// llamar a [MapController.iniciarSeguimiento] de nuevo si procede.
  final VoidCallback onRetry;

  const LocationPermissionDenied({
    super.key,
    required this.state,
    required this.onRetry,
  });

  // ── Textos según estado ───────────────────────────────────────────────────

  String _title(AppLocalizations l10n) => switch (state) {
        LocationPermissionState.serviceDisabled =>
          l10n.permisoUbicacionTituloGpsOff,
        LocationPermissionState.deniedForever =>
          l10n.permisoUbicacionTituloBloqueado,
        _ => l10n.permisoUbicacionTituloNecesario,
      };

  String _body(AppLocalizations l10n) => switch (state) {
        LocationPermissionState.serviceDisabled =>
          l10n.permisoUbicacionCuerpoGpsOff,
        LocationPermissionState.deniedForever =>
          l10n.permisoUbicacionCuerpoBloqueado,
        _ =>
          l10n.permisoUbicacionCuerpoNecesario,
      };

  String _buttonLabel(AppLocalizations l10n) => switch (state) {
        LocationPermissionState.serviceDisabled => l10n.permisoUbicacionBotonAjustesSistema,
        LocationPermissionState.deniedForever => l10n.permisoUbicacionBotonAjustesApp,
        _ => l10n.permisoUbicacionBotonPermitir,
      };

  IconData _icon() => switch (state) {
        LocationPermissionState.serviceDisabled => Icons.location_off_rounded,
        LocationPermissionState.deniedForever => Icons.lock_outline_rounded,
        _ => Icons.location_disabled_rounded,
      };

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Usa el color primario del tema activo (naranja en claro y oscuro)
    final accent = colorScheme.primary;
    final onAccent = colorScheme.onPrimary;
    final subtextColor = colorScheme.onSurface.withValues(alpha: 0.55);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icono ───────────────────────────────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.12),
              ),
              child: Icon(
                _icon(),
                size: 40,
                color: accent,
              ),
            ),

            const SizedBox(height: 24),

            // ── Título ──────────────────────────────────────────────────────
            Text(
              _title(l10n),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 12),

            // ── Descripción ─────────────────────────────────────────────────
            Text(
              _body(l10n),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: subtextColor,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // ── Botón de acción ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(
                  state == LocationPermissionState.serviceDisabled ||
                          state == LocationPermissionState.deniedForever
                      ? Icons.settings_outlined
                      : Icons.my_location_rounded,
                  size: 20,
                ),
                label: Text(_buttonLabel(l10n)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  shadowColor: accent.withValues(alpha: 0.35),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),

            // ── Nota extra para deniedForever / serviceDisabled ─────────────
            if (state == LocationPermissionState.deniedForever ||
                state == LocationPermissionState.serviceDisabled) ...[
              const SizedBox(height: 12),
              Text(
                l10n.permisoUbicacionNotaVolver,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtextColor.withValues(alpha: 0.65),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
