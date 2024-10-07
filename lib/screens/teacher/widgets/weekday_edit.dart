import 'package:flutter/material.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_elevated_button.dart';

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
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Select Weekdays',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.5,
                ),
                itemCount: 7, // Number of days in a week
                itemBuilder: (ctx, index) {
                  final isSelected = _isSelected[index];
                  return CustomCard(
                      onTap: () => _toggleDaySelection(index),
                      isSelected: isSelected,
                      child: Center(
                        child: Text(
                          _dayName(index),
                          style: TextStyle(
                            color:
                                isSelected ? Colors.blueAccent : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16.0,
                          ),
                        ),
                      ));
                },
              ),
            ),
            const SizedBox(height: 16.0),
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
        ),
      ),
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
