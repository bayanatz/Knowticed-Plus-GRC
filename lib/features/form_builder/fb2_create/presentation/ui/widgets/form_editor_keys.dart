/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_editor_keys.dart
/// Description: `FormEditorKeys`, the Form keys of the form editor (header
///              and pages). Kept in the UI layer, not in the cubits, and
///              provided once by the Form Builder page.
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:flutter/widgets.dart';

/// The Form keys of the form editor. Each editor screen renews its key when
/// it opens, so a closing screen and a new one never share a key.
class FormEditorKeys {
  /// The key of the header Form (title, access type, cover …).
  GlobalKey<FormState> headFormKey = GlobalKey<FormState>();

  /// The key of the pages Form (the fields).
  GlobalKey<FormState> dataFormKey = GlobalKey<FormState>();

  /// Method Name: [renewHead]
  ///
  /// Purpose: a fresh header key for a new editor screen. The screen keeps
  /// the key it got, so a closing screen never rebuilds with the new one.
  ///
  /// Returns: the new key.
  GlobalKey<FormState> renewHead() => headFormKey = GlobalKey<FormState>();

  /// Method Name: [renewData]
  ///
  /// Purpose: a fresh pages key for a new editor screen (kept by that
  /// screen, like [renewHead]).
  ///
  /// Returns: the new key.
  GlobalKey<FormState> renewData() => dataFormKey = GlobalKey<FormState>();
}
