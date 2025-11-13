import 'package:flutter/material.dart';
import 'mapa.dart';

class Layouthome extends StatefulWidget {
  const Layouthome({super.key});

  @override
  State<Layouthome> createState() => _LayouthomeState();
}

class _LayouthomeState extends State<Layouthome> {
  bool _showMap = true;

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFFFE2CE),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
   const SizedBox(
  height: 80, // 🔹 Cambia este número para ajustar la altura
  child: DrawerHeader(
    decoration: BoxDecoration(color: Color(0xFFFF9350)),
    margin: EdgeInsets.zero,
    padding: EdgeInsets.all(16),
    child: Align(
      alignment: Alignment.centerLeft, // Puedes centrar el texto si quieres
      child: Text(
        'Filtros',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ),
  ),
),

            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.red),
              title: Text('Precio+'),
            ),
                   ListTile(
              leading: Icon(Icons.attach_money, color: Colors.green),
              title: Text('Precio-'),
            ),
            ListTile(
              leading: Icon(Icons.local_gas_station, color: Colors.grey),
              title: Text('Diesel'),
            ),
            ListTile(
              leading: Icon(Icons.local_gas_station, color: Colors.orange),
              title: Text('Gasolina 95'),
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.blue),
              title: Text('Abierto'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9350),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9350),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ToggleButtons(
                            isSelected: [_showMap, !_showMap],
                            onPressed: (index) {
                              setState(() {
                                _showMap = index == 0;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            selectedColor: Colors.black,
                            color: Colors.white,
                            fillColor: Colors.white70,
                            constraints: const BoxConstraints(
                              minHeight: 36,
                              minWidth: 100,
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Mapa',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Lista',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
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
                    children: [
                      const Icon(Icons.stars, size: 40),
                      const Icon(Icons.arrow_upward, size: 40),
                      IconButton(
                        icon: const Icon(Icons.add, size: 40),
                        onPressed: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: MapWidget(),
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9350),
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
