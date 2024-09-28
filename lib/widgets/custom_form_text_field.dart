import 'package:flutter/material.dart';

class CustomFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? intialValue;
  final IconData prefixIcon;
  final bool readOnly;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Future<void> Function()? onTap;

  const CustomFormTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    this.intialValue,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(
          prefixIcon,
          color: readOnly
              ? Colors.grey
              : Colors.blueAccent, // Dull color for read-only mode
        ),
        labelText: labelText,
        labelStyle: TextStyle(
          color: readOnly
              ? Colors.grey
              : Colors.black, // Dull color for read-only label
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        filled: readOnly,
        fillColor: readOnly
            ? Colors.grey.shade200
            : Colors.transparent, // Light background for read-only mode
      ),
      initialValue: intialValue,
      onTap: onTap,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(
        color: readOnly
            ? Colors.grey
            : Colors.black, // Dull text color for read-only mode
      ),
    );
  }
}
