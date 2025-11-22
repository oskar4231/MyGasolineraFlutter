import 'package:flutter/material.dart';

class CochesScreen extends StatefulWidget {
  const CochesScreen({super.key});

  @override
  State<CochesScreen> createState() => _CochesScreenState();
}

class _CochesScreenState extends State<CochesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  
  // Tipos de combustible disponibles en España
  final Map<String, bool> _tiposCombustible = {
    'Gasolina 95': false,
    'Gasolina 98': false,
    'Diésel': false,
    'Diésel Premium': false,
    'GLP (Autogas)': false,
    'GNC (Gas Natural)': false,
    'Eléctrico': false,
    'Híbrido': false,
  };

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    super.dispose();
  }

  void _mostrarModalFormulario() {
    // Resetear el formulario
    _marcaController.clear();
    _modeloController.clear();
    _tiposCombustible.updateAll((key, value) => false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Añadir Coche',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo Marca
                      TextFormField(
                        controller: _marcaController,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          hintText: 'Ej: Toyota, BMW, Seat...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa la marca';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo Modelo
                      TextFormField(
                        controller: _modeloController,
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                          hintText: 'Ej: Corolla, Serie 3, León...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.car_rental),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el modelo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Tipo de Combustible
                      const Text(
                        'Tipo de Combustible:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Checkboxes para tipos de combustible
                      ..._tiposCombustible.keys.map((tipo) {
                        return CheckboxListTile(
                          title: Text(tipo),
                          value: _tiposCombustible[tipo],
                          onChanged: (bool? value) {
                            setDialogState(() {
                              _tiposCombustible[tipo] = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Verificar que al menos un tipo de combustible esté seleccionado
                      bool alMenosUnoCombustible = _tiposCombustible.values.any((v) => v);
                      
                      if (!alMenosUnoCombustible) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selecciona al menos un tipo de combustible'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // Obtener los combustibles seleccionados
                      List<String> combustiblesSeleccionados = _tiposCombustible.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList();

                      // Aquí puedes guardar los datos
                      print('Marca: ${_marcaController.text}');
                      print('Modelo: ${_modeloController.text}');
                      print('Combustibles: $combustiblesSeleccionados');

                      // Mostrar confirmación
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Coche añadido: ${_marcaController.text} ${_modeloController.text}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9350),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE2CE),
      body: SafeArea(
        child: Column(
          children: [
            // Header con título "Coches" arriba a la derecha
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFF9350),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Coches',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido principal
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      onTap: _mostrarModalFormulario,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9350), Color(0xFFFFB380)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Barra de navegación inferior (igual que en layouthome.dart)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFF9350),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Botón coche (ya estamos en esta pantalla)
                  IconButton(
                    onPressed: () {
                      // Ya estamos en la pantalla de coches
                    },
                    icon: const Icon(Icons.directions_car, size: 40, color: Colors.white),
                  ),
                  
                  // Botón pin (volver a home)
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.pin_drop, size: 40),
                  ),
                  
                  // Botón ajustes
                  IconButton(
                    onPressed: () {
                      // Navegar a ajustes si existe
                    },
                    icon: const Icon(Icons.settings, size: 40),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
