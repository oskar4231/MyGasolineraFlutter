import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  File? _profileImage; // Para almacenar la imagen seleccionada

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFF9350),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildAjustesContent(context),
    );
  }

  Widget _buildAjustesContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de Perfil (ahora con funcionalidad de cambiar imagen)
          _buildSeccionPerfil(),
          const SizedBox(height: 24),
          
          // Sección de Opciones
          _buildSeccionOpciones(context),
          const SizedBox(height: 24),
          
          // Botón Cerrar Sesión
          _buildBotonCerrarSesion(context),
        ],
      ),
    );
  }

  Widget _buildSeccionPerfil() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // CircleAvatar con funcionalidad de cambiar imagen
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
                        color: Colors.blue,
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Computer Perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'username@gmail.com',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
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
          ),
        ),
        const SizedBox(height: 16),
        _OpcionItem(
          icono: Icons.local_gas_station,
          texto: 'Combustible',
          onTap: () {
            // Navegar a pantalla de configuración de combustible
          },
        ),
        _OpcionItem(
          icono: Icons.attach_money,
          texto: 'Registro costo',
          tieneCheckbox: true,
          checkboxValue: false,
          onTap: () {
            // Lógica para toggle del checkbox
          },
        ),
        _OpcionItem(
          icono: Icons.receipt,
          texto: 'Gasto/Facturas',
          onTap: () {
            // Navegar a pantalla de gastos/facturas
          },
        ),
        _OpcionItem(
          icono: Icons.speed,
          texto: 'Registro km',
          tieneCheckbox: true,
          checkboxValue: false,
          onTap: () {
            // Lógica para toggle del checkbox
          },
        ),
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
          backgroundColor: Colors.red,
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

// Widget para items de opciones (sin cambios)
class _OpcionItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono, color: Colors.blue),
      title: Text(texto),
      trailing: tieneCheckbox
          ? Checkbox(
              value: checkboxValue,
              onChanged: (bool? value) {
                onTap();
              },
            )
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}