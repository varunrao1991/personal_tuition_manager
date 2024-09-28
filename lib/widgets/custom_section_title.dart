// custom_section_title.dart

import 'package:flutter/material.dart';

class CustomSectionTitle extends StatelessWidget {
  final String title;

  const CustomSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}
