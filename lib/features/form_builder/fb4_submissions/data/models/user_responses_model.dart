/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: user_responses_model.dart
/// Description: `UserResponsesModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// The "User Responses" index of one person: the forms they submitted and
/// when.
class UserResponsesModel {
  final String email;
  final List<String> formIds;
  final List<Timestamp> submissionTimestamp;

  UserResponsesModel({
    required this.email,
    required this.formIds,
    required this.submissionTimestamp,
  });

  static const String emailField = 'Email';
  static const String formIdsField = 'Form_Ids';
  static const String submissionTimestampField = 'Submission_Timestamp';

  factory UserResponsesModel.fromMap(Map<String, dynamic> map) {
    return UserResponsesModel(
      email: map[emailField],
      formIds: List<String>.from(map[formIdsField]),
      submissionTimestamp: List<Timestamp>.from(map[submissionTimestampField]),
    );
  }

  /// Method Name: [toMap]
  ///
  /// Purpose: the Firestore map of this model.
  ///
  /// Returns: [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      emailField: email,
      formIdsField: formIds,
      submissionTimestampField: submissionTimestamp,
    };
  }

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given fields changed.
  ///
  /// Returns: the new object.
  UserResponsesModel copyWith({
    String? email,
    List<String>? formIds,
    List<Timestamp>? submissionTimestamp,
  }) {
    return UserResponsesModel(
      email: email ?? this.email,
      formIds: formIds ?? this.formIds,
      submissionTimestamp: submissionTimestamp ?? this.submissionTimestamp,
    );
  }
}
