/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: submissions.dart
/// Description: `RequestedModel` data model, `SubmissionsModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

/// Immutable submission/request entities (final fields + copyWith).

class RequestedModel {
  final DateTime receivedDate;
  final String email;

  const RequestedModel(this.receivedDate, this.email);

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given fields changed.
  ///
  /// Returns: the new object.
  RequestedModel copyWith({
    DateTime? receivedDate,
    String? email,
  }) {
    return RequestedModel(
      receivedDate ?? this.receivedDate,
      email ?? this.email,
    );
  }
}

/// When a person received and submitted a form.
class SubmissionsModel {
  final DateTime submissionDate;
  final DateTime receivedDate;
  final String email;

  const SubmissionsModel({
    required this.submissionDate,
    required this.email,
    required this.receivedDate,
  });

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given fields changed.
  ///
  /// Returns: the new object.
  SubmissionsModel copyWith({
    DateTime? submissionDate,
    DateTime? receivedDate,
    String? email,
  }) {
    return SubmissionsModel(
      submissionDate: submissionDate ?? this.submissionDate,
      receivedDate: receivedDate ?? this.receivedDate,
      email: email ?? this.email,
    );
  }
}
