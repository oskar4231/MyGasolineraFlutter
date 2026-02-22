import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

class ConnectionSection extends StatelessWidget {
  final DateTime? lastUrlUpdate;
  final bool actualizandoUrl;
  final VoidCallback onRefreshUrl;

  const ConnectionSection({
    super.key,
    required this.lastUrlUpdate,
    required this.actualizandoUrl,
    required this.onRefreshUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.conexionMapa,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. Botón Actualizar Servidor
                Row(
                  children: [
                    Icon(Icons.sync, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.servidorBackend,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            lastUrlUpdate != null
                                ? 'Act: ${lastUrlUpdate!.hour.toString().padLeft(2, '0')}:${lastUrlUpdate!.minute.toString().padLeft(2, '0')}'
                                : 'Sin actualizar',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: actualizandoUrl ? null : onRefreshUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.primary,
                        elevation: 0,
                      ),
                      child: actualizandoUrl
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            )
                          : Text(AppLocalizations.of(context)!.actualizar),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
