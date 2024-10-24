import 'package:flutter/material.dart';

class PasswordFormTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;

  const PasswordFormTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.validator,
  });

  @override
  _PasswordFormTextFieldState createState() => _PasswordFormTextFieldState();
}

class _PasswordFormTextFieldState extends State<PasswordFormTextField> {
  bool _obscureText = true;

  void _togglePasswordVisibility(bool isObscure) {
    setState(() {
      _obscureText = isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: GestureDetector(
          onTapDown: (_) => _togglePasswordVisibility(false),
          onTapUp: (_) => _togglePasswordVisibility(true),
          onTapCancel: () => _togglePasswordVisibility(true),
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
    );
  }
}
