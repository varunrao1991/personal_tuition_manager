import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'custom_dropdown.dart';
import 'custom_elevated_button.dart';

class SortModal extends StatefulWidget {
  final String title;
  final String selectedSortField;
  final Map<String, String> sortOptions;
  final bool isAscending;
  final VoidCallback? onCancel;

  const SortModal({
    super.key,
    required this.title,
    required this.selectedSortField,
    required this.sortOptions,
    required this.isAscending,
    this.onCancel,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppPaddings.largePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onCancel?.call();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sort field dropdown
              Text(
                'Sort by',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              CustomDropdownButton(
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
              const SizedBox(height: 24),

              // Sort order toggle
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sort order',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      Switch.adaptive(
                        value: _isAscending,
                        onChanged: (value) {
                          setState(() {
                            _isAscending = value;
                          });
                        },
                        activeColor: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _isAscending ? 'Ascending' : 'Descending',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onCancel?.call();
                        },
                        text: 'Cancel'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomElevatedButton(
                      text: 'Apply',
                      onPressed: _onOkPressed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
