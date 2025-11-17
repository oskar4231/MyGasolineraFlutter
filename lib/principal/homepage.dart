import 'package:flutter/material.dart';
import 'package:my_gasolinera/principal/layouthome.dart'; // Importar Layouthome

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Devolver Layouthome que contiene el mapa + FAB
    return const Layouthome();
  }
}