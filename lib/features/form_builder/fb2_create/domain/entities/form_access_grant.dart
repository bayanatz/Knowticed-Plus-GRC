/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_access_grant.dart
/// Description: `FormAccessGrant`, the access list to save for a form
///              (plain domain data; the repository builds the Firestore
///              document from it).
/// Author: Amr Mesbah
/// Created at: 23/10/2026
library;

/// The people who get access to a form, with one shared period and edit
/// permission. Built by the home screen from the publish / edit dialogs.
class FormAccessGrant {
  /// The recipients' emails.
  final List<String> emails;

  /// When access starts (null = immediately).
  final DateTime? accessBegin;

  /// When access ends (null = never).
  final DateTime? accessEnd;

  /// Whether the recipients may edit their answers.
  final bool editPermission;

  const FormAccessGrant({
    required this.emails,
    this.accessBegin,
    this.accessEnd,
    this.editPermission = false,
  });
}
