/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: field_text_binder.dart
/// Description: `FieldTextBinder`, owns the TextEditingController of one
///              text input and keeps it in step with a `FieldText` of the
///              editor state (Home rule 2: no TextEditingController in the
///              cubit or its state).
/// Author: Amr Mesbah
/// Created at: 23/10/2026
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

/// Builds a text input for [text] with a TextEditingController this widget
/// owns: typing writes into [text], and a change made elsewhere (demo data,
/// language switch) is shown in the input.
class FieldTextBinder extends StatefulWidget {
  const FieldTextBinder({super.key, required this.text, required this.builder});

  /// The value in the editor state.
  final FieldText text;

  /// Builds the input with the owned controller.
  final Widget Function(BuildContext context, TextEditingController controller)
  builder;

  @override
  State<FieldTextBinder> createState() => _FieldTextBinderState();
}

class _FieldTextBinderState extends State<FieldTextBinder> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text.text,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_toValue);
    widget.text.addListener(_fromValue);
  }

  @override
  void didUpdateWidget(covariant FieldTextBinder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.text, widget.text)) return;
    oldWidget.text.removeListener(_fromValue);
    widget.text.addListener(_fromValue);
    _fromValue();
  }

  /// Typing → the editor state.
  void _toValue() {
    if (widget.text.text != _controller.text) {
      widget.text.text = _controller.text;
    }
  }

  /// The editor state → the input (keeps the cursor at the end).
  void _fromValue() {
    final String value = widget.text.text;
    if (_controller.text == value) return;
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  void dispose() {
    widget.text.removeListener(_fromValue);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
