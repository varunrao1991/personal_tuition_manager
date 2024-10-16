import 'dart:async';
import 'package:flutter/material.dart';

class GenericSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final String? labelText;
  final ValueChanged<String> onChanged;

  const GenericSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onChanged,
    this.labelText = 'Search',
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

    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: widget.onClear,
              )
            : null,
      ),
      onChanged: _onSearchChanged,
    );
  }
}
