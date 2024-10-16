import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final String selectedSortField;
  final Map<String, String> sortOptions;
  final ValueChanged<String?> onSortFieldChange;
  final String labelText;

  const CustomDropdownButton({
    super.key,
    required this.selectedSortField,
    required this.sortOptions,
    required this.onSortFieldChange,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedSortField,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      items: sortOptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(
            entry.value,
          ),
        );
      }).toList(),
      onChanged: onSortFieldChange,
    );
  }
}
