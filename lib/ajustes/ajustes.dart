import 'package:flutter/material.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.blue,
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
          // Sección de Perfil
          _buildSeccionPerfil(),
          const SizedBox(height: 24),
          
          // Sección de Estadísticas
          _buildSeccionEstadisticas(),
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
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 16),
            Column(
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

  Widget _buildSeccionEstadisticas() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _EstadisticaItem(
          valor: '123,82€',
          label: 'Dinero gastado\neste mes',
        ),
        _EstadisticaItem(
          valor: '3',
          label: 'Veces repostadas\neste mes',
        ),
      ],
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
                // Por ejemplo: 
                // AuthService().signOut();
                // Navigator.pushAndRemoveUntil(...);
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }
}

// Widget para items de estadísticas
class _EstadisticaItem extends StatelessWidget {
  final String valor;
  final String label;

  const _EstadisticaItem({
    required this.valor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// Widget para items de opciones
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