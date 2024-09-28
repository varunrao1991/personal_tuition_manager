import 'package:flutter/material.dart';

import 'custom_dropdown.dart';

class SortModal extends StatelessWidget {
  final String title;
  final String selectedSortField;
  final Map<String, String> sortOptions;
  final bool isAscending;
  final ValueChanged<String?> onSortFieldChange;
  final ValueChanged<bool> onSortOrderChange;

  const SortModal({
    super.key,
    required this.title,
    required this.selectedSortField,
    required this.sortOptions,
    required this.isAscending,
    required this.onSortFieldChange,
    required this.onSortOrderChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomDropdownButton(
          selectedSortField: selectedSortField,
          sortOptions: sortOptions,
          onSortFieldChange: onSortFieldChange,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Ascending'),
          trailing: Switch(
            value: isAscending,
            onChanged: onSortOrderChange,
          ),
        ),
      ],
    );
  }
}
