import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'custom_dropdown.dart';
import 'custom_elevated_button.dart';

class SortModal extends StatefulWidget {
  final String title;
  final String selectedSortField;
  final Map<String, String> sortOptions;
  final bool isAscending;

  const SortModal({
    super.key,
    required this.title,
    required this.selectedSortField,
    required this.sortOptions,
    required this.isAscending,
  });

  @override
  _SortModalState createState() => _SortModalState();
}

class _SortModalState extends State<SortModal> {
  late String _selectedSortField;
  late bool _isAscending;

  @override
  void initState() {
    super.initState();
    _selectedSortField = widget.selectedSortField;
    _isAscending = widget.isAscending;
  }

  void _onOkPressed() {
    Navigator.of(context)
        .pop({'field': _selectedSortField, 'order': _isAscending});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(AppPaddings.mediumPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                CustomDropdownButton(
                  labelText: "Sort by",
                  selectedSortField: _selectedSortField,
                  sortOptions: widget.sortOptions,
                  onSortFieldChange: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSortField = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Ascending'),
                  trailing: Switch(
                    value: _isAscending,
                    onChanged: (value) {
                      setState(() {
                        _isAscending = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                CustomElevatedButton(
                  text: 'OK',
                  onPressed: _onOkPressed,
                ),
              ],
            )));
  }
}
