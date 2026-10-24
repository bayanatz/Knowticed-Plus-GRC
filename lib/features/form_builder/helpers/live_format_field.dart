/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: live_format_field.dart
/// Description: `LiveFormatField` — wraps a `CustomTextField` and re-checks
///          its value on every keystroke, handing the builder the message to
///          show under the field (CustomTextField has an `errorText`, no
///          `validator`).
/// Author: Amr Mesbah
/// Created at: 13/10/2026
library;

import 'package:flutter/material.dart';

class LiveFormatField extends StatefulWidget {
  const LiveFormatField({
    super.key,
    required this.initialValue,
    required this.validate,
    required this.builder,
    this.onChanged,
  });

  final String? initialValue;

  /// Message for a bad value, null when it is fine. Empty values are the
  /// caller's call (validators here return null for empty).
  final String? Function(String value) validate;

  final ValueChanged<String>? onChanged;

  final Widget Function(String? errorText, ValueChanged<String> onChanged)
      builder;

  @override
  State<LiveFormatField> createState() => _LiveFormatFieldState();
}

class _LiveFormatFieldState extends State<LiveFormatField> {
  String? _error;

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue ?? '';
    _error = v.isEmpty ? null : widget.validate(v);
  }

  void _changed(String value) {
    final String? next = widget.validate(value);
    if (next != _error) setState(() => _error = next);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) => widget.builder(_error, _changed);
}
