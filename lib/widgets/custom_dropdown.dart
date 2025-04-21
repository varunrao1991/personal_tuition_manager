import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final String selectedSortField;
  final Map<String, String> sortOptions;
  final ValueChanged<String?> onSortFieldChange;
  final String? labelText;
  final bool isDense;
  final EdgeInsetsGeometry? padding;
  final double? minHeight;

  const CustomDropdownButton({
    super.key,
    required this.selectedSortField,
    required this.sortOptions,
    required this.onSortFieldChange,
    this.labelText,
    this.isDense = false, // Changed default to false for better height
    this.padding,
    this.minHeight = 48.0, // Added minimum height parameter
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8), // Increased spacing
        ],
        Container(
          constraints: BoxConstraints(
            minHeight: minHeight!, // Enforce minimum height
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.5),
              width: 1,
            ),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16), // Increased padding
          child: DropdownButtonFormField<String>(
            value: selectedSortField,
            isExpanded: true,
            isDense: isDense,
            dropdownColor: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            icon: Icon(
              Icons.arrow_drop_down,
              color: colorScheme.onSurface.withOpacity(0.6),
              size: 24, // Increased icon size
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: isDense ? 8 : 12, // Adjusted vertical padding
              ),
              isCollapsed: true,
            ),
            style: theme.textTheme.bodyLarge?.copyWith( // Using bodyLarge for better readability
              color: colorScheme.onSurface,
            ),
            items: sortOptions.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8), // Added item padding
                  child: Text(
                    entry.value,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge, // Consistent text style
                  ),
                ),
              );
            }).toList(),
            onChanged: onSortFieldChange,
            selectedItemBuilder: (BuildContext context) {
              return sortOptions.entries.map((entry) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }
}