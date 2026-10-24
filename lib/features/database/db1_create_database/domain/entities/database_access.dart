/// Module: database / db1_create_database / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: database_access.dart
/// Description: Declares `DatabaseAccess`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// What one viewer may do with one database, as decided by
/// `DatabaseAccessRule` (DB-CREATE-01). The screens ask this object; they never
/// read grants, levels or dates themselves.
///
/// Levels are ordered: View < Export < Edit < Full Access. A higher level
/// includes everything below it. The creator can do everything.
library;

import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';

class DatabaseAccess {
  const DatabaseAccess({
    this.isCreator = false,
    this.level,
    this.visibleColumnIds,
  });

  /// No access at all: the database is not shown.
  static const DatabaseAccess none = DatabaseAccess();

  final bool isCreator;

  /// The highest level the viewer holds today, or null when they hold none.
  final DatabasePermissionLevel? level;

  /// On a table: the column ids this viewer may see, or null for every column
  /// (DB-TABLE-03). Always null on a database.
  final Set<String>? visibleColumnIds;

  /// Function Name: [showsColumn]
  ///
  /// Purpose: Whether the column with [columnId] is shown to this viewer.
  ///
  /// Parameters: [columnId] a table column's id.
  ///
  /// Returns: [bool].
  bool showsColumn(String columnId) =>
      visibleColumnIds?.contains(columnId) ?? true;

  /// Edit rows and import. Needs Edit level AND every column: the editor shows
  /// all of a table's columns, so a viewer limited to some cannot use it.
  bool get canEditRows => canEdit && visibleColumnIds == null;

  bool get canView => isCreator || level != null;
  bool get canExport =>
      isCreator || rankOf(level) >= rankOf(DatabasePermissionLevel.export);
  bool get canEdit =>
      isCreator || rankOf(level) >= rankOf(DatabasePermissionLevel.edit);

  /// Delete, Restore and changing who has access.
  bool get canManage =>
      isCreator || rankOf(level) >= rankOf(DatabasePermissionLevel.fullAccess);

  /// Function Name: [rankOf]
  ///
  /// Purpose: Orders the permission levels so the highest one wins.
  ///
  /// Parameters: [level] a level, or null for none.
  ///
  /// Returns: [int] 0 for none; `custom` ranks as View until it has a meaning.
  static int rankOf(DatabasePermissionLevel? level) {
    switch (level) {
      case null:
        return 0;
      case DatabasePermissionLevel.view:
      case DatabasePermissionLevel.custom:
        return 1;
      case DatabasePermissionLevel.export:
        return 2;
      case DatabasePermissionLevel.edit:
        return 3;
      case DatabasePermissionLevel.fullAccess:
        return 4;
    }
  }
}
