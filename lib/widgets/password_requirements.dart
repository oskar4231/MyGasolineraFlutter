import 'package:flutter/material.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;
  final Color primaryColor;
  final Color successColor;
  final Color errorColor;

  const PasswordRequirements({
    super.key,
    required this.password,
    this.primaryColor = const Color(0xFF492714),
    this.successColor = Colors.green,
    this.errorColor = Colors.red,
  });

  // Validaciones
  bool get hasMinLength => password.length >= 8;
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar =>
      password.contains(RegExp(r'[#$?¿]'));
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));

  // Validación de todos los requisitos
  bool get isAllValid =>
      hasMinLength && hasNumber && hasSpecialChar && hasUppercase;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requisitos de contraseña:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('Al menos 8 caracteres', hasMinLength),
          _buildRequirementItem('Al menos un número (0-9)', hasNumber),
          _buildRequirementItem('Al menos un carácter especial (#, \$, ?, ¿)',
              hasSpecialChar),
          _buildRequirementItem('Al menos una mayúscula (A-Z)', hasUppercase),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMet
                  ? successColor.withOpacity(0.1)
                  : errorColor.withOpacity(0.1),
              border: Border.all(
                color: isMet ? successColor : errorColor,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                isMet ? Icons.check : Icons.close,
                size: 12,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
