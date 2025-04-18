import 'package:flutter/material.dart';

class PasswordFormTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const PasswordFormTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.obscureText,
    required this.keyboardType,
    this.validator,
  });

  @override
  _PasswordFormTextFieldState createState() => _PasswordFormTextFieldState();
}

class _PasswordFormTextFieldState extends State<PasswordFormTextField> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      enableInteractiveSelection: false,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: Icon(widget.prefixIcon),
      ),
    );
  }
}
