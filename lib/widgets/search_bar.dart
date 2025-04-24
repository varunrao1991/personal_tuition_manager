import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class GenericSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final String? hintText;
  final String? labelText;
  final ValueChanged<String> onChanged;
  final Duration debounceDuration;
  final bool autofocus;
  final VoidCallback? onFilterPressed;

  const GenericSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onChanged,
    this.hintText,
    this.labelText,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.autofocus = false,
    this.onFilterPressed,
  });

  @override
  _GenericSearchBarState createState() => _GenericSearchBarState();
}

class _GenericSearchBarState extends State<GenericSearchBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8), // 👈 Add padding here
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                autofocus: widget.autofocus,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppPaddings.mediumPadding,
                    vertical: AppPaddings.smallPadding,
                  ),
                  hintText: widget.hintText ?? 'Search...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  labelText: widget.labelText,
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  suffixIcon: widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          onPressed: () {
                            widget.controller.clear();
                            widget.onClear();
                            widget.onChanged('');
                          },
                        )
                      : null,
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (widget.onFilterPressed != null)
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.filter_alt_rounded,
                  color: colorScheme.primary,
                ),
                tooltip: 'Filter',
                onPressed: widget.onFilterPressed,
              ),
            ),
        ],
      ),
    );
  }
}
