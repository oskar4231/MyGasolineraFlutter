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
                  const SizedBox(height: 20),

                  Container(
                    margin: const EdgeInsets.only(bottom: 30.0),
                    child: const Text(
                      'MyGasolinera',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF492714),
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 30.0),
                    child: Image.asset(
                      'lib/assets/logo.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // Botón Iniciar Sesión
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
                  
                  // Botón Crear Cuenta
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
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}