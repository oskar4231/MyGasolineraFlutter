import 'package:flutter/material.dart';
import 'package:my_gasolinera/Inicio/inicio.dart';

import 'package:my_gasolinera/services/config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar configuración dinámica del backend
  await ConfigService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyGasolinera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Inicio(),
    );
  }
}
