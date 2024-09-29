import 'package:flutter/material.dart';

class GenericSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final String? labelText;
  final ValueChanged<String> onChanged;

  const GenericSearchBar(
      {super.key,
      required this.controller,
      required this.onClear,
      required this.onChanged,
      this.labelText = 'Search'});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Search',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
      ),
      onChanged: onChanged,
    );
  }
}
