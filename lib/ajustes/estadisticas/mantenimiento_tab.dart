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
    // Variable para detectar tema oscuro
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loadingColor = isDark ? Colors.white : const Color(0xFFFF9350);

    return RefreshIndicator(
      onRefresh: _recargar,
      color: loadingColor,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mantenimientoData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: loadingColor));
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString(), isDark);
          }

          final coches = snapshot.data ?? [];

          if (coches.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coches.length,
            itemBuilder: (context, index) {
              final coche = coches[index];
              return _buildCocheCard(coche, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildError(String error, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF492714);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            'Error: $error',
            style: TextStyle(fontSize: 16, color: textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _recargar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9350),
            ),
            child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF492714);
    final subtextColor = isDark ? Colors.grey[400] : Colors.grey;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build, size: 80, color: subtextColor),
          const SizedBox(height: 20),
          Text(
            'No hay datos de mantenimiento',
            style: TextStyle(fontSize: 16, color: textColor),
          ),
          const SizedBox(height: 10),
          Text(
            'Añade coches con información de kilometraje',
            style: TextStyle(fontSize: 14, color: subtextColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _recargar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9350),
            ),
            child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCocheCard(Map<String, dynamic> coche, bool isDark) {
    final necesitaCambio = coche['necesita_cambio'] as bool;
    final progreso = double.tryParse(coche['progreso_km'].toString()) ?? 0;
    final kmRestantes = coche['km_restantes'] as int;
    final marca = coche['marca'] as String;
    final modelo = coche['modelo'] as String;
    final kmDesdeCambio = coche['km_desde_ultimo_cambio'] as int;
    final kmActual = coche['kilometraje_actual'] as int?;

    // Colores dinámicos para la tarjeta
    final cardBgColor = isDark 
        ? (necesitaCambio ? const Color(0xFF4A1818) : const Color(0xFF2C2C2C)) // Rojo oscuro si necesita cambio, gris si no
        : (necesitaCambio ? Colors.red[50] : Colors.white); // Rojo claro si necesita cambio, blanco si no
        
    final textColor = isDark ? Colors.white : const Color(0xFF492714);
    final subtextColor = isDark ? Colors.grey[400] : Colors.grey;
    final warningColor = Colors.red;
    final goodColor = const Color(0xFFFF9350);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: cardBgColor,
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
                        ? (isDark ? Colors.redAccent.withOpacity(0.2) : const Color(0xFF492714).withOpacity(0.2))
                        : (isDark ? Colors.orangeAccent.withOpacity(0.2) : const Color(0xFFFF9350).withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.car_repair,
                    color: necesitaCambio 
                        ? (isDark ? Colors.redAccent : const Color(0xFF492714)) 
                        : (isDark ? Colors.orangeAccent : const Color(0xFFFF9350)),
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
                          color: textColor,
                        ),
                      ),
                      if (kmActual != null)
                        Text(
                          'KM actual: $kmActual',
                          style: TextStyle(
                            fontSize: 12,
                            color: subtextColor,
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
            Divider(color: isDark ? Colors.white24 : Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              'Cambio de Aceite',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: necesitaCambio 
                    ? (isDark ? Colors.white : const Color(0xFF492714)) 
                    : (isDark ? Colors.orangeAccent : const Color(0xFFFF9350)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KM desde último cambio',
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                    Text(
                      '$kmDesdeCambio km',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'KM restantes',
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                    Text(
                      '$kmRestantes km',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: necesitaCambio 
                            ? (isDark ? Colors.white : const Color(0xFF492714)) 
                            : (isDark ? Colors.orangeAccent : const Color(0xFFFF9350)),
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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      necesitaCambio ? '¡Necesita cambio!' : 'En buen estado',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: necesitaCambio 
                            ? (isDark ? Colors.white : const Color(0xFF492714)) 
                            : (isDark ? Colors.orangeAccent : const Color(0xFFFF9350)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progreso / 100,
                    backgroundColor: isDark ? Colors.white12 : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      necesitaCambio ? warningColor : (isDark ? Colors.greenAccent : Colors.green),
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
                      color: isDark ? Colors.redAccent.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: isDark ? Colors.redAccent : Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Programa el cambio de aceite próximamente',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.redAccent[100] : Colors.red[700],
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