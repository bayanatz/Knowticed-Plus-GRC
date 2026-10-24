/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: field_text.dart
/// Description: `FieldText`, one editable text of a form field (title,
///              hint, option…) kept as a plain value in the editor state.
///              Replaces the TextEditingControllers the field controllers
///              used to hold (Home rule 2): the widgets own their
///              TextEditingControllers and bind them with `FieldTextBinder`.
/// Author: Amr Mesbah
/// Created at: 23/10/2026
library;

import 'package:flutter/foundation.dart';

/// One editable text of a form field. Listeners are told when [text]
/// changes (the editor's live preview subscribes to them).
class FieldText extends ChangeNotifier {
  FieldText({String text = ''}) : _text = text;

  String _text;
  bool _disposed = false;

  /// The current text.
  String get text => _text;

  /// Sets the text and tells the listeners. Ignored once disposed, so a
  /// widget still bound for one frame cannot throw.
  set text(String value) {
    if (_disposed || value == _text) return;
    _text = value;
    notifyListeners();
  }

  /// Method Name: [clear]
  ///
  /// Purpose: empties the text.
  void clear() => text = '';

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }
}
