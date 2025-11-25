import 'package:flutter/material.dart';
import 'package:my_gasolinera/Inicio/crear_cuenta/crear.dart';
import 'login/login.dart';
import 'package:my_gasolinera/principal/homepage.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE8DA),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),

                  // Logo y texto en fila - GRANDES Y CENTRADOS
Container(
  padding: const EdgeInsets.fromLTRB(30, 80, 30, 30),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        'lib/assets/logo.png', 
        height: 120, 
        width: 120
      ),
      SizedBox(height: 20),
      Text(
        'MyGasolinera',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF492714),
        ),
      ),
    ],
  ),
),

                  const SizedBox(height: 20),
                  
                  // Botón Iniciar Sesión (ORIGINAL)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF9350),
                        foregroundColor: Color(0xFF492714),
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Color(0xFF492714),
                            width: 2.0
                          ),
                        ),
                        elevation: 0,
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        )
                      ),
                      child: const Text('Iniciar Sesión'),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Botón Crear Cuenta (ORIGINAL)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CrearScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFCFB0),
                        foregroundColor: Color(0xFF492714),
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Color(0xFFFF9350),
                            width: 2.0
                          ),
                        ),
                        elevation: 0,
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        )
                      ),
                      child: const Text('Crear Cuenta'),
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}