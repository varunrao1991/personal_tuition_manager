import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateInputField extends StatelessWidget {
  final String? title;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool readOnly;

  const CustomDateInputField({
    required this.title,
    required this.selectedDate,
    required this.onDateSelected,
    this.readOnly = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(selectedDate),
    );

    return GestureDetector(
      onTap: readOnly
          ? null
          : () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                onDateSelected(pickedDate);
              }
            },
      child: AbsorbPointer(
        child: TextFormField(
          controller: dateController,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.date_range),
            labelText: title,
          ),
        ),
      ),
    );
  }
}
