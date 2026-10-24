/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_access_record.dart
/// Description: `FormAccessRecord`, the signed-in user's own row of a form's
///              access list (plain domain data).
/// Author: Amr Mesbah
/// Created at: 23/10/2026
library;

/// The signed-in user's row in the access list of one form shared with them.
class FormAccessRecord {
  /// The form.
  final String formId;

  /// When the user's access starts, or null.
  final DateTime? accessBegin;

  /// When the user's access ends, or null.
  final DateTime? accessEnd;

  /// Whether the row is active (not removed from the list).
  final bool isActive;

  /// Whether the user may edit their answer.
  final bool canEdit;

  const FormAccessRecord({
    required this.formId,
    required this.accessBegin,
    required this.accessEnd,
    required this.isActive,
    required this.canEdit,
  });

  /// Method Name: [isOpenAt]
  ///
  /// Purpose: whether the access period includes [now].
  ///
  /// Parameters:
  /// - [now]: the moment to check.
  ///
  /// Returns: true when [now] is inside the access period.
  bool isOpenAt(DateTime now) {
    if (accessBegin != null && accessBegin!.isAfter(now)) return false;
    if (accessEnd != null && accessEnd!.isBefore(now)) return false;
    return true;
  }
}
