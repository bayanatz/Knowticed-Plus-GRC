/// Module: form_builder_module/presentation
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_shortcut.dart
/// Description: One-shot "open Form Builder AT …" request from outside the module.
/// Author: Amr Mesbah
/// Created at: 29/9/2026 — bug report p.2: the Home "Forms" card buttons
///          (Create Form / View Draft Form / View Requested Form) had empty
///          onTap handlers, so they did nothing.
library;

import 'package:flutter/foundation.dart';

/// Where the Form Builder home should land when it next opens.
enum FormBuilderShortcut {
  createForm,
  publish,
  drafts,
  requestedForms,
  submissions,
}

/// Holder for a pending [FormBuilderShortcut]. The Home card sets it and then
/// switches to the module; FormBuilderHomeScreen consumes (and clears) it once
/// its data is loaded, the same pattern as
/// `FormResponsivePageLayout.pendingResultForm`.
class FormBuilderShortcuts {
  FormBuilderShortcuts._();

  /// A notifier, not a bare field. The Form Builder home
  /// read the shortcut only in initState — but on tablet / desktop the module
  /// stays alive in the side rail, so after the first visit a Home "Forms"
  /// button just switched modules and never opened its page. The home screen
  /// now also LISTENS, so a shortcut set while it is alive is applied too.
  static final ValueNotifier<FormBuilderShortcut?> notifier =
      ValueNotifier<FormBuilderShortcut?>(null);

  static FormBuilderShortcut? get pending => notifier.value;
  static set pending(FormBuilderShortcut? value) {
    // Same value twice in a row (pressing the same button again) must still
    // notify, so clear first.
    if (value != null && notifier.value == value) notifier.value = null;
    notifier.value = value;
  }

  /// Returns the pending shortcut and clears it.
  static FormBuilderShortcut? take() {
    final FormBuilderShortcut? value = notifier.value;
    notifier.value = null;
    return value;
  }

  /// Home tab index for a tab shortcut, or null for [FormBuilderShortcut.createForm].
  static int? tabIndexOf(FormBuilderShortcut shortcut) {
    switch (shortcut) {
      case FormBuilderShortcut.publish:
        return 0;
      case FormBuilderShortcut.drafts:
        return 1;
      case FormBuilderShortcut.requestedForms:
        return 2;
      case FormBuilderShortcut.submissions:
        return 3;
      case FormBuilderShortcut.createForm:
        return null;
    }
  }
}
