/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: user_grid_item.dart
/// Description: Entity for a user card in the results grid.
/// Author: Amr Mesbah
/// Created at: 23/3/2025
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';

/// One person on the Results page: who they are, their answers and their
/// reminders.
class UserGridItem {
  PersonEntity person;
  DateTime? lastReminderTime;
  int reminderCounter;
  List<PageEntity>? page;
  DateTime? submissionTime;

  UserGridItem(
      {required this.person,
      this.lastReminderTime,
      required this.reminderCounter,
      this.page,
      this.submissionTime});
}
