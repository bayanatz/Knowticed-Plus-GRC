/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: users_responses.dart
/// Description: `UsersResponses`, the people of a form split into those who
///              have not answered yet and those who have.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/user_grid_item.dart';

/// The people of a form, split by whether they answered.
class UsersResponses {
  /// People who have not answered yet.
  final List<UserGridItem> pending;

  /// People who answered.
  final List<UserGridItem> submitted;

  const UsersResponses({required this.pending, required this.submitted});
}
