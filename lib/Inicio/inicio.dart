import 'package:flutter/material.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE8DA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título en formato h1
            const Text(
              'MyGasolinera',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF492714), // Agregando 0xFF al inicio
              ),
            ),
            const SizedBox(height: 20), // Espacio entre el título y el primer botón
            ElevatedButton(
              onPressed: () {
                // Acción para el primer botón
              },
              //Configuración Estilo Boton
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9350), //Color boton
                foregroundColor: Color(0xFF492714), //Color del texto
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 35),
                side: BorderSide(
                  color: Color(0xFF492714),
                  width: 2.0
                ),
                textStyle: TextStyle(
                  fontSize: 18,
                  wordSpacing: 2.0
                )
              ),
              child: const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 10), // Espacio entre botones
            ElevatedButton(
              onPressed: () {
                // Acción para el segundo botón
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:  Color(0xFFFFCFB0),
                foregroundColor:  Color(0xFF492714),
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 35),
                side: BorderSide(
                  color: Color(0xFFFF9350),
                  width: 2.0
                ),
                textStyle: TextStyle(
                  fontSize: 18,
                  wordSpacing: 2.0
                )
              ),
              child: const Text('Crear Cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
