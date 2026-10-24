/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: form_state.dart
/// Description: `FormStatus` enum, extension methods of `FormStatus`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';

enum FormStatus {
  publish,
  drafts,
  requestedForms,
  submissions,
  deleted,
}

// Extension to get the name of the form status as a string
extension FormStatusExtension on FormStatus {
  /// STABLE identifier — this is the value stored on the form document and the
  /// Key the home tabs filter on. NOT translated; see [label].
  String get name {
    switch (this) {
      case FormStatus.publish:
        return 'Publish';
      case FormStatus.drafts:
        return 'Drafts';
      case FormStatus.requestedForms:
        return 'Requested Forms';
      case FormStatus.submissions:
        return 'Submissions';
      case FormStatus.deleted:
        return 'Deleted';
    }
  }

  /// Translated tab label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case FormStatus.publish:
        return s.formStatusPublish;
      case FormStatus.drafts:
        return s.formStatusDrafts;
      case FormStatus.requestedForms:
        return s.formStatusRequestedForms;
      case FormStatus.submissions:
        return s.formStatusSubmissions;
      case FormStatus.deleted:
        return s.formStatusDeleted;
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in FormStatus.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }
}
