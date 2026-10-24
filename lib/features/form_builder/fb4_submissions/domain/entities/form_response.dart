/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: form_response.dart
/// Description: `FormResponse`, one person's response to a form (their
///              answers, when they submitted and when they were reminded).
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';

/// One person's response to a form.
class FormResponse {
  /// Email of the person who answered (or was reminded).
  final String submittedBy;

  /// The answered pages; null or empty when the person has not submitted.
  final List<PageEntity>? pages;

  /// When the response was submitted (first entry = first submission).
  final List<DateTime> submittedAt;

  /// When the person was reminded.
  final List<DateTime> reminders;

  const FormResponse({
    required this.submittedBy,
    required this.pages,
    required this.submittedAt,
    required this.reminders,
  });

  /// True when the person has submitted answers.
  bool get isSubmitted => pages != null && pages!.isNotEmpty;

  /// The last reminder, or null when never reminded.
  DateTime? get lastReminder => reminders.isEmpty ? null : reminders.last;

  /// The first submission time, or null when not submitted.
  DateTime? get firstSubmission =>
      submittedAt.isEmpty ? null : submittedAt.first;
}
