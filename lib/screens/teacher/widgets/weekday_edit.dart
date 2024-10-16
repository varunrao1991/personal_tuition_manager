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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Select Weekdays',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Note: Changing these selections may affect the ongoing courses end date calculation.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.3,
              ),
              itemCount: 7,
              itemBuilder: (ctx, index) {
                final isSelected = _isSelected[index];
                return CustomCard(
                  onTap: () => _toggleDaySelection(index),
                  isSelected: isSelected,
                  child: Center(
                    child: Text(
                      _dayName(index),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            Row(
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
        return 'Sun';
      case 1:
        return 'Mon';
      case 2:
        return 'Tues';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      default:
        return '';
    }
  }
}
