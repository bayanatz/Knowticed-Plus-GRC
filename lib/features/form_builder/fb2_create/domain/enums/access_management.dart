/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: access_management.dart
/// Description: `AccessManagement` enum, extension methods of `AccessManagement`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';

enum AccessManagement { openAccess, restrictedAccess, personalAccess }

/// Extension to provide additional functionalities to the AccessManagement enum.
extension AccessManagementExtension on AccessManagement {
  /// STABLE identifier — persisted on the form and compared against in
  /// `home_controller`, `create_form_data_cubit` and `publish_screen`.
  /// Deliberately NOT translated; see [label].
  String get name {
    switch (this) {
      case AccessManagement.personalAccess:
        return 'Personal Access';
      case AccessManagement.restrictedAccess:
        return 'Restricted Access';
      case AccessManagement.openAccess:
        return 'Open Access';
    }
  }

  /// Translated label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case AccessManagement.personalAccess:
        return s.personalAccess;
      case AccessManagement.restrictedAccess:
        return s.restrictedAccess;
      case AccessManagement.openAccess:
        return s.openAccess;
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  ///
  /// Screens that read `formHeadModel.accessManagement`
  /// Straight out of Firestore were printing the raw English value. Route it
  /// Through here instead so the tag follows the locale. Unknown values are
  /// Returned untouched rather than swallowed, so bad data stays visible.
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in AccessManagement.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }

  /// Function Name: [fromStored]
  ///
  /// Purpose: Reads the access type saved on a form. Older forms saved the
  /// enum name ('openAccess'), newer ones [name] ('Open Access'), so the
  /// match ignores case, spaces, '_' and '-'.
  ///
  /// Returns: the matching value, or null for an empty or unknown value.
  static AccessManagement? fromStored(String? value) {
    if (value == null) return null;
    String squash(String v) =>
        v.replaceAll(RegExp(r'[\s_-]'), '').toLowerCase();
    final String wanted = squash(value);
    for (final element in AccessManagement.values) {
      if (squash(element.name) == wanted) return element;
    }
    return null;
  }

  static List<String> dropDownStringItems() {
    return AccessManagement.values.map((element) {
      return element.name;
    }).toList();
  }
}
