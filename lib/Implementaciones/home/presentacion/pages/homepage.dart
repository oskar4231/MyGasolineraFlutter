import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/presentacion/pages/mapa.dart';

/// HomePage ahora abre el mapa en tiempo real automáticamente.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Devolver directamente el widget del mapa para que se muestre al navegar aquí.
    return MapaTiempoReal();
  }
}