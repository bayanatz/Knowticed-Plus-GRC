/// Module: database / db1_create_database / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_rule.dart
/// Description: Declares `DatabaseAccessRule`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// The one rule for who may see and act on a database (DB-CREATE-01). The list,
/// the details screen and the table screens all ask this, so they cannot
/// disagree.
///
///   creator                      everything
///   Personal database            creator only
///   draft                        creator only
///   member of a grant            the highest level whose dates include today
///   deleted database             creator or Full Access (to restore it)
///   anyone else                  nothing
///
/// This is enforced in the app only. Firestore rules must enforce the same
/// thing on the server; see `firestore.rules`.
library;

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_window.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';

class DatabaseAccessRule {
  const DatabaseAccessRule();

  /// Function Name: [resolve]
  ///
  /// Purpose: Decide what [viewerId] may do with [database] on [today].
  ///
  /// Parameters:
  ///   [database] the record, carrying its access index.
  ///   [viewerId] the signed-in employee's id, or null when nobody is.
  ///   [today]    the day the grants' dates are checked against.
  ///
  /// Returns: [DatabaseAccess] — [DatabaseAccess.none] when the viewer may not
  /// even see it.
  DatabaseAccess resolve(
    DatabaseEntity database, {
    required String? viewerId,
    required DateTime today,
  }) {
    if (viewerId == null || viewerId.isEmpty) return DatabaseAccess.none;
    if (database.createdBy == viewerId) {
      return const DatabaseAccess(isCreator: true);
    }
    if (database.isDraft ||
        database.accessType == DatabaseAccessType.personal) {
      return DatabaseAccess.none;
    }

    DatabasePermissionLevel? best;
    for (final DatabaseAccessWindow window
        in database.accessIndex[viewerId] ?? const <DatabaseAccessWindow>[]) {
      if (!window.isActiveOn(today)) continue;
      if (DatabaseAccess.rankOf(window.permission) >
          DatabaseAccess.rankOf(best)) {
        best = window.permission;
      }
    }
    if (best == null) return DatabaseAccess.none;

    final DatabaseAccess access = DatabaseAccess(level: best);
    if (database.isDeleted && !access.canManage) return DatabaseAccess.none;
    return access;
  }
}
