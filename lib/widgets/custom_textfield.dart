import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.controller,
    required this.labelText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
        ),
      ),
      validator: validator,
    );
  }
}
