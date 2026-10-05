import 'package:flutter/material.dart';
import 'package:safeplace/theme/colors.dart';

class CampoAuth extends StatelessWidget {
  const CampoAuth({
    super.key,
    required this.controller,
    required this.hint,
    required this.icone,
    this.senha = false,
    this.email = false,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icone;
  final bool senha;
  final bool email;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: senha,
      keyboardType: senha
          ? TextInputType.visiblePassword
          : email
              ? TextInputType.emailAddress
              : TextInputType.name,
      style: const TextStyle(fontFamily: 'Inter', color: SafePlaceColors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: SafePlaceColors.mediumGray),
        prefixIcon: Icon(icone, color: SafePlaceColors.safeBlue),
        filled: true,
        fillColor: SafePlaceColors.panel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
