/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: analytics_text_field_entity.dart
/// Description: `AnalyticsTextFieldEntity` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';

/// One person's answer in an analytics answer list.
class AnalyticsTextFieldEntity {
  PersonEntity person;
  DateTime submissionDate;
  List<String> answers;

  AnalyticsTextFieldEntity({
    required this.person,
    required this.submissionDate,
    required this.answers,
  });
}
