/// Module: database / db1_create_database / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: database_session_repository.dart
/// Description: Declares `DatabaseSessionRepository`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// Reads the signed-in employee through `AppControllers`, the one place the
/// app talks to the GetX locator. Registered once at app start in `main.dart`.
///
/// The id is read on every call, never cached: the employee is loaded after
/// sign-in, so a value captured when the app or a screen started can be null.
library;

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';

class DatabaseSessionRepository implements DatabaseSessionBaseRepository {
  const DatabaseSessionRepository();

  @override
  String? get signedInEmployeeId {
    final String? id = AppControllers.signedInEmployeeDirectory?.employee?.id;
    if (id == null || id.isEmpty) return null;
    return id;
  }
}
