/// Module: database / db3_create_table / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: table_access_rule.dart
/// Description: Declares `TableAccessRule`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// What a viewer may do with one TABLE (DB-TABLE-03): the database rule from
/// DB-CREATE-01, narrowed by the table's own grants.
///
///   cannot see the database            nothing
///   database creator or Full Access     everything, every column
///   table creator                       everything, every column
///   table has no access records         the database access, every column
///   table has grants                    only its grantees: the highest active
///                                       level, and the columns those grants
///                                       name (none named = every column)
///
/// Column limits are applied in the app. Firestore cannot hide fields inside a
/// row document; see `firestore.rules`.
library;

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_window.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/use_cases/database_access_rule.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';

class TableAccessRule {
  const TableAccessRule(
      {DatabaseAccessRule database = const DatabaseAccessRule()})
      : _database = database;

  final DatabaseAccessRule _database;

  /// Function Name: [resolve]
  ///
  /// Purpose: Decide what [viewerId] may do with [table] on [today].
  ///
  /// Parameters:
  ///   [database] the table's parent, carrying its access index.
  ///   [table]    the table, carrying its own access index.
  ///   [viewerId] the signed-in employee's id, or null.
  ///   [today]    the day the grants' dates are checked against.
  ///
  /// Returns: [DatabaseAccess], with [DatabaseAccess.visibleColumnIds] set
  /// when the viewer may see only some columns.
  DatabaseAccess resolve(
    DatabaseEntity database,
    DatabaseTableEntity table, {
    required String? viewerId,
    required DateTime today,
  }) {
    final DatabaseAccess base =
        _database.resolve(database, viewerId: viewerId, today: today);
    if (!base.canView) return DatabaseAccess.none;
    if (base.canManage) return base;
    if (viewerId != null && table.createdBy == viewerId) {
      return const DatabaseAccess(isCreator: true);
    }
    if (!table.accessRestricted && table.accessIndex.isEmpty) return base;

    DatabasePermissionLevel? best;
    Set<String>? columns = <String>{};
    for (final DatabaseAccessWindow window
        in table.accessIndex[viewerId] ?? const <DatabaseAccessWindow>[]) {
      if (!window.isActiveOn(today)) continue;
      if (DatabaseAccess.rankOf(window.permission) >
          DatabaseAccess.rankOf(best)) {
        best = window.permission;
      }
      if (window.viewableFields.isEmpty) {
        columns = null;
      } else {
        columns?.addAll(window.viewableFields);
      }
    }
    if (best == null) return DatabaseAccess.none;
    return DatabaseAccess(level: best, visibleColumnIds: columns);
  }
}
