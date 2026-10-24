/// Module: database / db1_create_database / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: database_directory_base_repository.dart
/// Description: Declares `DatabaseDirectoryBaseRepository`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// The org directory for the Database module's access screens (rule 1). The
/// create wizard, the database Access screen, the table Access flow and the
/// comment thread used to reach into the roles feature's controllers through
/// `Get.find` and each map the records themselves; they now get this
/// injected, and the one mapping lives in the data layer.
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_directory.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';

/// Reads the company's employees and departments.
abstract interface class DatabaseDirectoryBaseRepository {
  /// Function Name: [loadDirectory]
  ///
  /// Purpose: Read every employee and department.
  ///
  /// Returns: [Future<Either<Failure, DatabaseDirectory>>] — a failure when
  /// either list could not be read, never an empty list standing in for one.
  Future<Either<Failure, DatabaseDirectory>> loadDirectory();

  /// Function Name: [findMember]
  ///
  /// Purpose: One employee by id — the comment thread's author card.
  ///
  /// Parameters: [employeeId] the employee to look up.
  ///
  /// Returns: [Future<Either<Failure, DatabaseMember?>>] — null when the id is
  /// not in the directory.
  Future<Either<Failure, DatabaseMember?>> findMember(String employeeId);
}
