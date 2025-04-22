import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_elevated_button.dart';

class WeekdayEditorDialog extends StatefulWidget {
  final List<int> enabledWeekdayIds; // List of enabled weekday IDs (1-7)

  const WeekdayEditorDialog({
    super.key,
    required this.enabledWeekdayIds,
  });

  @override
  _WeekdayEditorDialogState createState() => _WeekdayEditorDialogState();
}

class _WeekdayEditorDialogState extends State<WeekdayEditorDialog> {
  late List<int> _selectedWeekdayIds;

  @override
  void initState() {
    super.initState();
    _selectedWeekdayIds = List.from(widget.enabledWeekdayIds);
  }

  void _toggleDaySelection(int weekdayId) {
    setState(() {
      if (_selectedWeekdayIds.contains(weekdayId)) {
        _selectedWeekdayIds.remove(weekdayId);
      } else {
        _selectedWeekdayIds.add(weekdayId);
      }
      _selectedWeekdayIds.sort(); // Keep them ordered
    });
  }

  void _setWeekdays() {
    Navigator.of(context).pop(_selectedWeekdayIds);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.mediumPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Select Weekdays',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16.0),
            Text(
              'Note: Changing these selections may affect the ongoing courses end date calculation.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
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
                final weekdayId = index + 1; // Convert to 1-7
                final isSelected = _selectedWeekdayIds.contains(weekdayId);

                return CustomCard(
                  onTap: () => _toggleDaySelection(weekdayId),
                  isSelected: isSelected,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dayName(weekdayId),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                        ),
                      ],
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
                    onPressed: () => Navigator.of(context).pop(),
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

  String _dayName(int weekdayId) {
    switch (weekdayId) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'Unknown';
    }
  }
}