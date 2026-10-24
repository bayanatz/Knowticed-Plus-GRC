/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: response_model.dart
/// Description: `ResponseModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/page_model.dart';

/// One response document in Firestore (answers, submission times, reminders).
class ResponseModel {
  final String submittedBy;
  final List<Timestamp> timestamps;
  final List<Timestamp> reminder;
  final List<PageModel>? pages;
  final String? id;

  ResponseModel({
    required this.submittedBy,
    required this.timestamps,
    required this.reminder,
    required this.pages,
    this.id,
  });
  static const String submittedByField = 'Submitted_By';
  static const String timestampsField = 'Timestamps';
  static const String reminderField = 'Reminder';
  static const String pagesField = 'Pages';

  factory ResponseModel.fromMap(Map<String, dynamic> map, String id) {
    return ResponseModel(
      id: id,
      submittedBy: map[submittedByField],
      timestamps: List<Timestamp>.from(map[timestampsField]),
      reminder: List<Timestamp>.from(map[reminderField]),
      pages: map[pagesField] == null
          ? null
          : List<PageModel>.from((map[pagesField] as List<dynamic>)
              .map<PageModel>(
                  (x) => PageModel.fromMap(x as Map<String, dynamic>))),
    );
  }

  /// Method Name: [toMap]
  ///
  /// Purpose: the Firestore map of this model.
  ///
  /// Returns: [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      submittedByField: submittedBy,
      timestampsField: timestamps,
      reminderField: reminder,
      pagesField: pages?.map((e) => e.toMap()).toList(),
    };
  }

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given fields changed.
  ///
  /// Returns: the new object.
  ResponseModel copyWith({
    String? submittedBy,
    List<Timestamp>? timestamps,
    List<Timestamp>? reminder,
    List<PageModel>? pages,
    String? id,
  }) {
    return ResponseModel(
      submittedBy: submittedBy ?? this.submittedBy,
      timestamps: timestamps ?? this.timestamps,
      reminder: reminder ?? this.reminder,
      pages: pages ?? this.pages,
      id: id ?? this.id,
    );
  }
}
