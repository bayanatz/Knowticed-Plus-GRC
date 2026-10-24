/// Module: database / db1_create_database / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: database_directory.dart
/// Description: Declares `DatabaseDirectory`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
library;

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_department.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';

/// The company's people and departments, as the access screens need them.
class DatabaseDirectory {
  const DatabaseDirectory({required this.members, required this.departments});

  /// Every employee with a non-empty id.
  final List<DatabaseMember> members;

  /// Every department with a non-empty id.
  final List<DatabaseDepartment> departments;
}
