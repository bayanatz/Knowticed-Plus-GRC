/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: synced_search_field.dart
/// Description: `SyncedSearchField`, the app search field that owns its
///              text controller and follows the search text kept by a
///              cubit (cleared when the cubit clears it).
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';

/// The app search field; owns its controller (Share rule 2).
class SyncedSearchField extends StatefulWidget {
  const SyncedSearchField({
    super.key,
    required this.text,
    required this.onChanged,
    this.fillColor,
  });

  /// The field colour, or null for the default.
  final Color? fillColor;

  /// The search text the cubit holds.
  final String text;

  /// Called with every change typed.
  final ValueChanged<String> onChanged;

  @override
  State<SyncedSearchField> createState() => _SyncedSearchFieldState();
}

class _SyncedSearchFieldState extends State<SyncedSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );

  @override
  void didUpdateWidget(covariant SyncedSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != _controller.text) _controller.text = widget.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSearchTextField(
      controller: _controller,
      fillColor: widget.fillColor,
      onChanged: widget.onChanged,
    );
  }
}
