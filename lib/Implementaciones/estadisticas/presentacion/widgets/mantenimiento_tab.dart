import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/estadisticas/data/services/estadisticas_avanzadas_service.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class MantenimientoTab extends StatefulWidget {
  const MantenimientoTab({super.key});

  @override
  State<MantenimientoTab> createState() => _MantenimientoTabState();
}

class _MantenimientoTabState extends State<MantenimientoTab> {
  late Future<List<Map<String, dynamic>>> _mantenimientoData;

  @override
  void initState() {
    super.initState();
    _mantenimientoData = _cargarMantenimiento();
  }

  Future<List<Map<String, dynamic>>> _cargarMantenimiento() async {
    try {
      return await EstadisticasAvanzadasService.obtenerMantenimiento();
    } catch (e) {
      // Si hay error, devolver lista vacía
      AppLogger.error('Error cargando mantenimiento',
          tag: 'MantenimientoTab', error: e);
      return [];
    }
  }

  Future<void> _recargar() async {
    setState(() {
      _mantenimientoData = _cargarMantenimiento();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _recargar,
      color: Theme.of(context).primaryColor,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mantenimientoData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor));
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final coches = snapshot.data ?? [];

          if (coches.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coches.length,
            itemBuilder: (context, index) {
              final coche = coches[index];
              return _buildCocheCard(coche);
            },
          );
        },
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            '${AppLocalizations.of(context)!.error}: $error',
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _recargar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(
              AppLocalizations.of(context)!.reintentar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.build, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.noDatosMantenimiento,
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.anadeCochesMantenimiento,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _recargar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(
              AppLocalizations.of(context)!.reintentar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCocheCard(Map<String, dynamic> coche) {
    final necesitaCambio = coche['necesita_cambio'] as bool;
    final progreso = double.tryParse(coche['progreso_km'].toString()) ?? 0;
    final kmRestantes = coche['km_restantes'] as int;
    final marca = coche['marca'] as String;
    final modelo = coche['modelo'] as String;
    final kmDesdeCambio = coche['km_desde_ultimo_cambio'] as int;
    final kmActual = coche['kilometraje_actual'] as int?;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Paleta de colores Premium
    final primaryIconColor =
        isDarkMode ? const Color(0xFFFF8235) : Theme.of(context).primaryColor;
    final errorIconColor = isDarkMode
        ? const Color(0xFFFF5252)
        : Theme.of(context).colorScheme.error;

    final cardBackgroundColor = necesitaCambio
        ? (isDarkMode
            ? const Color(0xFF3B2020)
            : Theme.of(context).colorScheme.errorContainer)
        : (isDarkMode ? const Color(0xFF2C2C2E) : Theme.of(context).cardColor);

    final mainTextColor =
        isDarkMode ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF9E9E9E)
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    final valueTextColor = isDarkMode
        ? const Color(0xFFEBEBEB)
        : Theme.of(context).colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDarkMode
            ? BorderSide(
                color: const Color(0xFF38383A)
                    .withValues(alpha: necesitaCambio ? 0 : 1),
                width: 1)
            : BorderSide.none,
      ),
      elevation: isDarkMode ? 0 : 2,
      shadowColor: isDarkMode ? Colors.transparent : Colors.black12,
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: necesitaCambio
                        ? errorIconColor.withValues(alpha: 0.15)
                        : primaryIconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.car_repair,
                    color: necesitaCambio ? errorIconColor : primaryIconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$marca $modelo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: mainTextColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (kmActual != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context)!.kmActual}: $kmActual',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (necesitaCambio)
                  Icon(Icons.warning_rounded, color: errorIconColor, size: 28),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
                color: isDarkMode ? const Color(0xFF38383A) : Colors.grey[200]),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.cambioAceite,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: necesitaCambio
                    ? errorIconColor
                    : (isDarkMode
                        ? const Color(0xFFCCCCCC)
                        : Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.kmDesdeCambio,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$kmDesdeCambio km',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: valueTextColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.kmRestantes,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$kmRestantes km',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: necesitaCambio ? errorIconColor : mainTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.progreso}: ${progreso.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: valueTextColor,
                      ),
                    ),
                    Text(
                      necesitaCambio
                          ? AppLocalizations.of(context)!.necesitaCambio
                          : AppLocalizations.of(context)!.buenEstado,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: necesitaCambio
                            ? errorIconColor
                            : (isDarkMode
                                ? const Color(0xFF4CAF50)
                                : Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progreso / 100,
                    backgroundColor:
                        isDarkMode ? const Color(0xFF1C1C1E) : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      necesitaCambio
                          ? errorIconColor
                          : (isDarkMode
                              ? const Color(0xFFFF8235)
                              : Colors.green),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
            if (necesitaCambio)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: errorIconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: errorIconColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: errorIconColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.programaCambioAceite,
                          style: TextStyle(
                            fontSize: 13,
                            color: errorIconColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
