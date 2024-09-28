import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final String selectedSortField;
  final Map<String, String>
      sortOptions; // Map for options where key is the return value and value is the label
  final ValueChanged<String?> onSortFieldChange;

  const CustomDropdownButton({
    super.key,
    required this.selectedSortField,
    required this.sortOptions,
    required this.onSortFieldChange,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedSortField,
      decoration: InputDecoration(
        labelText: 'Sort by',
        prefixIcon: const Icon(Icons.sort, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.black38, width: 2),
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
      items: sortOptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key, // Return value
          child: Text(entry.value), // Display label
        );
      }).toList(),
      onChanged: onSortFieldChange,
    );
  }
}
