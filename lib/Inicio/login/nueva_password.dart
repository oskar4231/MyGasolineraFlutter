import 'package:flutter/material.dart';
import 'package:my_gasolinera/Inicio/login/login.dart';
import 'package:my_gasolinera/services/auth_service.dart';
import 'package:my_gasolinera/widgets/password_requirements.dart';

class NuevaPasswordScreen extends StatefulWidget {
  final String email;

  const NuevaPasswordScreen({super.key, required this.email});

  @override
  State<NuevaPasswordScreen> createState() => _NuevaPasswordScreenState();
}

class _NuevaPasswordScreenState extends State<NuevaPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _isLoading = false;
  bool _showPasswordRequirements = false;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios del foco en el campo de contraseña
    _passwordFocus.addListener(() {
      setState(() {
        _showPasswordRequirements = _passwordFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _isPasswordValid() {
    final password = _passwordController.text;
    final hasMinLength = password.length >= 8;
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[#$?¿]'));
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));

    return hasMinLength && hasNumber && hasSpecialChar && hasUppercase;
  }

  Future<void> _handleChangePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      // Primero verificar el token
      final verifyResponse = await AuthService.verifyToken(
        _tokenController.text.trim(),
      );

      if (!mounted) return;

      if (verifyResponse['status'] != 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verifyResponse['message'] ?? 'Token inválido o expirado',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Si el token es válido, cambiar la contraseña
      final resetResponse = await AuthService.resetPassword(
        _tokenController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (resetResponse['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar al login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resetResponse['message'] ?? 'Error al cambiar contraseña',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.95;
    final cardWidth = maxWidth > 520.0 ? 520.0 : maxWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE8DA),
      appBar: AppBar(
        title: const Text(
          'Nueva contraseña',
          style: TextStyle(
            color: Color(0xFF492714),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF492714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCFB0),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MyGasolinera',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF492714),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'lib/assets/logo.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  // Mostrar el email
                  Text(
                    'Código enviado a: ${widget.email}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF492714),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Campo para el código de 6 dígitos
                  TextFormField(
                    controller: _tokenController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 20, letterSpacing: 8),
                    textAlign: TextAlign.center,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle: const TextStyle(letterSpacing: 8),
                      labelText: 'Código de recuperación',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      counterText: '',
                    ),
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa el código';
                      if (v.length != 6)
                        return 'El código debe tener 6 dígitos';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nueva contraseña
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: true,
                    style: const TextStyle(fontSize: 16),
                    enabled: !_isLoading,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Nueva contraseña',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Ingresa la nueva contraseña';
                      if (!_isPasswordValid())
                        return 'La contraseña no cumple todos los requisitos';
                      return null;
                    },
                  ),
                  PasswordRequirements(
                    password: _passwordController.text,
                    isVisible: _showPasswordRequirements,
                    primaryColor: const Color(0xFF492714),
                  ),
                  const SizedBox(height: 16),

                  // Confirmar contraseña
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    style: const TextStyle(fontSize: 16),
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'Confirmar contraseña',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    onFieldSubmitted: (_) => _handleChangePassword(),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Confirma la contraseña';
                      if (v != _passwordController.text)
                        return 'Las contraseñas no coinciden';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isLoading || !_isPasswordValid() || _tokenController.text.isEmpty) ? null : _handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9955),
                        foregroundColor: const Color(0xFF492714),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF492714),
                                ),
                              ),
                            )
                          : const Text('Cambiar contraseña'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
