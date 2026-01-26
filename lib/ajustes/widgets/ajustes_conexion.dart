import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/services/config_service.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';

class AjustesConexion extends StatefulWidget {
  const AjustesConexion({super.key});

  @override
  State<AjustesConexion> createState() => _AjustesConexionState();
}

class _AjustesConexionState extends State<AjustesConexion> {
  bool _actualizandoUrl = false;
  DateTime? _lastUrlUpdate;
  double _radiusKm = 25.0;

  @override
  void initState() {
    super.initState();
    _cargarDatosConexion();
  }

  Future<void> _cargarDatosConexion() async {
    final lastTime = await ConfigService.getLastFetchTime();
    final prefs = await SharedPreferences.getInstance();
    final savedRadius = prefs.getDouble('radius_km') ?? 25.0;

    if (mounted) {
      setState(() {
        _lastUrlUpdate = lastTime;
        _radiusKm = savedRadius;
      });
    }
  }

  Future<void> _guardarRadio(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('radius_km', valor);
    setState(() {
      _radiusKm = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.conexionMapa,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            l10n.servidorBackend,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _lastUrlUpdate != null
                                ? 'Act: ${_lastUrlUpdate!.hour.toString().padLeft(2, '0')}:${_lastUrlUpdate!.minute.toString().padLeft(2, '0')}'
                                : 'Sin actualizar',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _actualizandoUrl
                          ? null
                          : () async {
                              setState(() => _actualizandoUrl = true);
                              try {
                                await ConfigService.forceRefresh();
                                final lastTime =
                                    await ConfigService.getLastFetchTime();
                                if (mounted) {
                                  setState(() {
                                    _lastUrlUpdate = lastTime;
                                    _actualizandoUrl = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ URL actualizada'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() => _actualizandoUrl = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('❌ Error: $e')),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.primary,
                        elevation: 0,
                      ),
                      child: _actualizandoUrl
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary),
                              ),
                            )
                          : Text(l10n.actualizar),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // 2. Slider Radio
                Row(
                  children: [
                    Icon(Icons.radar, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.radioBusqueda,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_radiusKm.toInt()} km',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _radiusKm,
                            min: 5,
                            max: 100,
                            divisions: 19,
                            activeColor: theme.colorScheme.primary,
                            label: '${_radiusKm.toInt()} km',
                            onChanged: (value) {
                              setState(() {
                                _radiusKm = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _guardarRadio(value);
                            },
                          ),
                        ],
                      ),
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
