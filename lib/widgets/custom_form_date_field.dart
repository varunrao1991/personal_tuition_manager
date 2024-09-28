import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateInputField extends StatelessWidget {
  final String? title;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  CustomDateInputField({
    required this.title,
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(selectedDate),
    ); // Use the controller to display the date

    return GestureDetector(
      onTap: () async {
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
          controller:
              dateController, // Display the selected date as the field's value
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.date_range, color: Colors.blueAccent),
            labelText: title, // Set the title as the label text
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
          readOnly: true, // Make the field read-only
        ),
      ),
    );
  }
}
