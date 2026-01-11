import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/estadisticas_avanzadas_service.dart';

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
      print('Error cargando mantenimiento: $e');
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
            'Error: $error',
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _recargar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9350),
            ),
            child: const Text('Reintentar'),
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
            'No hay datos de mantenimiento',
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          const Text(
            'Añade coches con información de kilometraje',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _recargar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9350),
            ),
            child: const Text('Reintentar'),
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
    final primaryIconColor =
        isDarkMode ? Colors.orangeAccent : Theme.of(context).primaryColor;
    final errorIconColor =
        isDarkMode ? Colors.redAccent : Theme.of(context).colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: necesitaCambio
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: necesitaCambio
                        ? errorIconColor.withOpacity(0.2)
                        : primaryIconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.car_repair,
                    color: necesitaCambio ? errorIconColor : primaryIconColor,
                    size: 32,
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (kmActual != null)
                        Text(
                          'KM actual: $kmActual',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                if (necesitaCambio)
                  const Icon(Icons.warning, color: Colors.red, size: 32),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Cambio de Aceite',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: necesitaCambio
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KM desde último cambio',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '$kmDesdeCambio km',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'KM restantes',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '$kmRestantes km',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: necesitaCambio
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso: ${progreso.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      necesitaCambio ? '¡Necesita cambio!' : 'En buen estado',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: necesitaCambio
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progreso / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      necesitaCambio ? Colors.red : Colors.green,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
            if (necesitaCambio)
              Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Programa el cambio de aceite próximamente',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
