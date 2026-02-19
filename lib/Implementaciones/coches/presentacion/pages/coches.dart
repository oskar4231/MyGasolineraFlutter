import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/pages/ajustes.dart';
import 'package:my_gasolinera/Implementaciones/coches/data/controllers/coches_controller.dart';
import 'package:my_gasolinera/Implementaciones/coches/presentacion/widgets/coche_card.dart';
import 'package:my_gasolinera/Implementaciones/coches/presentacion/widgets/coche_estado_vacio.dart';
import 'package:my_gasolinera/Implementaciones/coches/presentacion/widgets/coche_form.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/pages/layouthome.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/coches/data/services/car_data_service.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';

class CochesScreen extends StatefulWidget {
  const CochesScreen({super.key});

  @override
  State<CochesScreen> createState() => _CochesScreenState();
}

class _CochesScreenState extends State<CochesScreen> {
  late final CochesController _controller;

  @override
  void initState() {
    super.initState();
    CarDataService().loadData();
    _controller = CochesController(context);
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario() async {
    await CocheForm.mostrar(
      context,
      isLoading: _controller.isLoading,
      onConfirm: (datos) => _controller.crear(
        marca: datos.marca,
        modelo: datos.modelo,
        tiposCombustible: datos.tiposCombustible,
        kilometrajeInicial: datos.kilometrajeInicial,
        capacidadTanque: datos.capacidadTanque,
        consumoTeorico: datos.consumoTeorico,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accentColor =
        isDark ? const Color(0xFFFF8235) : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header plano ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: HoverBackButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const Layouthome()),
                      ),
                    ),
                  ),
                  Text(
                    l10n.cochesTitulo,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Contenido ────────────────────────────────────────────────
            Expanded(
              child: _controller.isLoading
                  ? Center(child: CircularProgressIndicator(color: accentColor))
                  : _controller.coches.isEmpty
                      ? const CocheEstadoVacio()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _controller.coches.length,
                          itemBuilder: (context, index) {
                            final coche = _controller.coches[index];
                            return CocheCard(
                              coche: coche,
                              onDelete: () => _controller.eliminar(coche),
                            );
                          },
                        ),
            ),

            // ── Footer ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: null, // Ya estamos en Coches
                    icon: Icon(Icons.directions_car,
                        size: 40,
                        color: isDark
                            ? Colors.black
                            : theme.colorScheme.onPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const Layouthome()),
                    ),
                    icon: Icon(Icons.pin_drop,
                        size: 40,
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.5)
                            : theme.colorScheme.onPrimary
                                .withValues(alpha: 0.5)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const AjustesScreen()),
                    ),
                    icon: Icon(Icons.settings,
                        size: 40,
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.5)
                            : theme.colorScheme.onPrimary
                                .withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: _abrirFormulario,
          backgroundColor:
              isDark ? const Color(0xFF3E3E42) : theme.primaryColor,
          child: Icon(Icons.add,
              color: isDark
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onPrimary),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
