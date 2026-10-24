/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: user_submissions.dart
/// Description: `UserSubmissions`, the forms one person has submitted and
///              when (the person's "User Responses" index).
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

/// The forms one person has submitted, and when.
class UserSubmissions {
  /// The person's email.
  final String email;

  /// Ids of the submitted forms (same order as [submittedAt]).
  final List<String> formIds;

  /// Submission time of each entry of [formIds].
  final List<DateTime> submittedAt;

  const UserSubmissions({
    required this.email,
    required this.formIds,
    required this.submittedAt,
  });

  /// True when [formId] was submitted.
  bool contains(String formId) => formIds.contains(formId);

  /// Method Name: [submissionDateOf]
  ///
  /// Purpose: the submission date of a form (FB-FILL-02: one date for every
  /// reader). Uses the last entry and guards against lists of different
  /// lengths in old data.
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: the date, or null when the form is not in the index.
  DateTime? submissionDateOf(String formId) {
    final int i = formIds.lastIndexOf(formId);
    if (i < 0 || i >= submittedAt.length) return null;
    return submittedAt[i];
  }
}
