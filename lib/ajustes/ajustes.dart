import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:my_gasolinera/Inicio/facturas/FacturasScreen.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  File? _profileImage;
  String _telefonoUsuario = "123-456-7890"; // Número por defecto
  String _nombre = "Nombre"; // Nombre por defecto
  String _apellido = "Apellido"; // Apellido por defecto
  final String _emailUsuario =
      "usuario@gmail.com"; // Este vendría de tu base de datos

  // Función para seleccionar imagen desde galería
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Función para tomar foto con cámara
  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Diálogo para elegir entre cámara o galería
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar foto de perfil'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Selecciona de dónde quieres tomar la foto:'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
              child: const Text('Galería'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
              child: const Text('Cámara'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar diálogo de edición de nombre
  void _mostrarDialogoEditarNombre() {
    TextEditingController nombreController = TextEditingController();
    TextEditingController apellidoController = TextEditingController();
    TextEditingController telefonoController = TextEditingController();

    nombreController.text = _nombre;
    apellidoController.text = _apellido;
    telefonoController.text = _telefonoUsuario;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFE8DA), // Color de fondo del cuadro
          title: const Text(
            'Editar Información',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ), // Título en negro
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  hintText: 'Ingresa tu nombre',
                  labelStyle: TextStyle(color: Colors.black), // Label en negro
                  hintStyle: TextStyle(color: Colors.black54), // Hint en negro
                ),
                style: const TextStyle(
                  color: Colors.black,
                ), // Texto ingresado en negro
                maxLength: 25,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                  hintText: 'Ingresa tu apellido',
                  labelStyle: TextStyle(color: Colors.black), // Label en negro
                  hintStyle: TextStyle(color: Colors.black54), // Hint en negro
                ),
                style: const TextStyle(
                  color: Colors.black,
                ), // Texto ingresado en negro
                maxLength: 25,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  hintText: 'Ingresa tu número de teléfono',
                  prefixIcon: Icon(
                    Icons.phone,
                    color: Colors.black,
                  ), // Icono en negro
                  labelStyle: TextStyle(color: Colors.black), // Label en negro
                  hintStyle: TextStyle(color: Colors.black54), // Hint en negro
                ),
                style: const TextStyle(
                  color: Colors.black,
                ), // Texto ingresado en negro
                keyboardType: TextInputType.phone,
                maxLength: 15,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.black,
                ), // Botón cancelar en negro
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.trim().isNotEmpty &&
                    telefonoController.text.trim().isNotEmpty) {
                  setState(() {
                    _nombre = nombreController.text.trim();
                    _apellido = apellidoController.text.trim();
                    _telefonoUsuario = telefonoController.text.trim();
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Información actualizada'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFFFF9350,
                ), // Fondo del botón guardar en negro
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(
                  color: Colors.white,
                ), // Texto del botón guardar en blanco
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF9350), // Fondo naranja
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Letras negras en el AppBar
          ),
        ),
        backgroundColor: const Color(0xFFFF9350),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ), // Iconos negros en AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildAjustesContent(context),
    );
  }

  Widget _buildAjustesContent(BuildContext context) {
    return Container(
      color: const Color(0xFFFF9350), // Fondo naranja
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSeccionPerfil(),
                  const SizedBox(height: 24),
                  _buildSeccionOpciones(context),
                ],
              ),
            ),
          ),
          // Botón Cerrar Sesión abajo del todo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBotonCerrarSesion(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionPerfil() {
    return Card(
      elevation: 2,
      color: const Color(0xFFFFE8DA), // Mantener el card blanco para contraste
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: _showImagePickerDialog,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black, // Icono de cámara negro
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _mostrarDialogoEditarNombre,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$_nombre $_apellido',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Texto negro
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.black, // Icono editar negro
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 14,
                          color: Colors.black, // Icono teléfono negro
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _telefonoUsuario,
                            style: const TextStyle(
                              color: Colors.black, // Texto negro
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _emailUsuario,
                      style: const TextStyle(
                        color: Colors.black, // Texto negro
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionOpciones(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Texto negro
          ),
        ),
        const SizedBox(height: 16),
        _OpcionItem(
          icono: Icons.local_gas_station,
          texto: 'Combustible',
          onTap: () {},
        ),
        _OpcionItem(
          icono: Icons.attach_money,
          texto: 'Registro costo',
          onTap: () {},
        ),
        _OpcionItem(
          icono: Icons.receipt,
          texto: 'Gasto/Facturas',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FacturasScreen()),
            );
          },
        ),
        _OpcionItem(icono: Icons.speed, texto: 'Registro km', onTap: () {}),
      ],
    );
  }

  Widget _buildBotonCerrarSesion(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          _mostrarDialogoCerrarSesion(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar sesión'),
      ),
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí iría la lógica real de cierre de sesión
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }
}

class _OpcionItem extends StatefulWidget {
  final IconData icono;
  final String texto;
  final bool tieneCheckbox;
  final bool checkboxValue;
  final VoidCallback onTap;

  const _OpcionItem({
    required this.icono,
    required this.texto,
    this.tieneCheckbox = false,
    this.checkboxValue = false,
    required this.onTap,
  });

  @override
  State<_OpcionItem> createState() => __OpcionItemState();
}

class __OpcionItemState extends State<_OpcionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: _isHovered ? Colors.black12 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(widget.icono, color: Colors.black),
          title: Text(
            widget.texto,
            style: const TextStyle(color: Colors.black),
          ),
          trailing: widget.tieneCheckbox
              ? Checkbox(
                  value: widget.checkboxValue,
                  onChanged: (bool? value) {
                    widget.onTap();
                  },
                )
              : null, // Eliminamos el icono de flecha
          onTap: widget.onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
        ),
      ),
    );
  }
}
