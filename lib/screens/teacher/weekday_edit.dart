import 'package:flutter/material.dart';
import '../../widgets/custom_elevated_button.dart';

class WeekdayEditorDialog extends StatefulWidget {
  final List<bool> isSelected;

  const WeekdayEditorDialog({
    super.key,
    required this.isSelected,
  });

  @override
  _WeekdayEditorDialogState createState() => _WeekdayEditorDialogState();
}

class _WeekdayEditorDialogState extends State<WeekdayEditorDialog> {
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = List.from(widget.isSelected);
  }

  void _toggleDaySelection(int index) {
    setState(() {
      _isSelected[index] = !_isSelected[index];
    });
  }

  void _setWeekdays() {
    Navigator.of(context).pop(_isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Weekdays'),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: List.generate(7, (index) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isSelected[index] ? Colors.redAccent : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onPressed: () => _toggleDaySelection(index),
              child: Text(
                _dayName(index),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            );
          }),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomElevatedButton(
                text: 'Cancel',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: CustomElevatedButton(
                text: 'Set',
                onPressed: _setWeekdays,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _dayName(int index) {
    switch (index) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return '';
    }
  }
}
