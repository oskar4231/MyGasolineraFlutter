import 'package:flutter/material.dart';
import 'mapa.dart';

class Layouthome extends StatelessWidget {
  const Layouthome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE2CE),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFF9350),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MyGasolinera",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: 100,
                          min: 0,
                          max: 100,
                          onChanged: (value) {},
                        ),
                      ),
                      const Text("100km"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Icon(Icons.stars, size: 40),
                      Icon(Icons.arrow_upward, size: 40),
                      Icon(Icons.schedule, size: 40),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                // Incrustar el mapa aquí
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const MapWidget(),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFFFF9350),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Icon(Icons.directions_car, size: 40),
                  Icon(Icons.pin_drop, size: 40),
                  Icon(Icons.settings, size: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}