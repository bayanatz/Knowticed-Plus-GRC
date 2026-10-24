/// Module: database / db1_create_database / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_window.dart
/// Description: Declares `DatabaseAccessWindow`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// One person's access through one grant: a permission level and the dates it
/// holds for. A person picked in two grants has two windows.
library;

import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';

class DatabaseAccessWindow {
  const DatabaseAccessWindow({
    required this.permission,
    this.startDate,
    this.endDate,
    this.viewableFields = const <String>[],
  });

  /// Column ids this window shows on a TABLE grant; empty means every column.
  /// Always empty on a database grant.
  final List<String> viewableFields;

  final DatabasePermissionLevel permission;

  /// First day the access holds. Null means it has no start limit.
  final DateTime? startDate;

  /// Last day the access holds, inclusive. Null means it never ends.
  final DateTime? endDate;

  /// Function Name: [isActiveOn]
  ///
  /// Purpose: Whether this window covers [day]. Compares calendar days, so an
  /// end date of today still grants access for the whole of today.
  ///
  /// Parameters: [day] the day to check, usually today.
  ///
  /// Returns: [bool] true when [day] is inside the window.
  bool isActiveOn(DateTime day) {
    final DateTime today = DateTime(day.year, day.month, day.day);
    final DateTime? start = startDate;
    final DateTime? end = endDate;
    if (start != null &&
        today.isBefore(DateTime(start.year, start.month, start.day))) {
      return false;
    }
    if (end != null && today.isAfter(DateTime(end.year, end.month, end.day))) {
      return false;
    }
    return true;
  }
}
