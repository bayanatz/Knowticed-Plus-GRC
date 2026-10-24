/// Module: database / db1_create_database / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_index_model.dart
/// Description: Declares `DatabaseAccessIndexModel`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// Reads and writes the access index on a database document (DB-CREATE-01):
///
///   member_ids:   [employeeId, ...]           for the list query
///   access_index: { employeeId: [ { permission, start_date, end_date } ] }
///
/// Dates are Timestamps so Firestore rules can compare them with
/// `request.time`. Built from the grants every time they are written.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_window.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';

class DatabaseAccessIndexModel {
  const DatabaseAccessIndexModel._();

  static const String fAccessIndex = 'access_index';
  static const String fMemberIds = 'member_ids';
  static const String fPermission = 'permission';
  static const String fStartDate = 'start_date';
  static const String fEndDate = 'end_date';
  static const String fViewableFields = 'viewable_fields';

  /// Function Name: [fieldsFor]
  ///
  /// Purpose: The two index fields for a database whose grants are [grants].
  /// A grant with no permission level grants nothing and is left out.
  ///
  /// Parameters: [grants] every grant the database will have after the write.
  ///
  /// Returns: [Map<String, Object>] to spread into the document's set/update.
  static Map<String, Object> fieldsFor(Iterable<DatabaseAccessGrant> grants) {
    final Map<String, List<Map<String, Object?>>> index =
        <String, List<Map<String, Object?>>>{};
    for (final DatabaseAccessGrant grant in grants) {
      final DatabasePermissionLevel? permission = grant.permission;
      if (permission == null) continue;
      for (final DatabaseMember member in grant.members) {
        if (member.employeeId.isEmpty) continue;
        index
            .putIfAbsent(member.employeeId, () => <Map<String, Object?>>[])
            .add(
          <String, Object?>{
            fPermission: permission.storageKey,
            fStartDate: _timestamp(grant.startDate),
            fEndDate: _timestamp(grant.endDate),
            fViewableFields: grant.viewableFields,
          },
        );
      }
    }
    return <String, Object>{
      fAccessIndex: index,
      fMemberIds: index.keys.toList(growable: false),
    };
  }

  /// Function Name: [fromField]
  ///
  /// Purpose: Parse the stored `access_index`. Anything unreadable is skipped,
  /// which can only remove access, never add it.
  ///
  /// Parameters: [raw] the field's value as Firestore returned it.
  ///
  /// Returns: [Map<String, List<DatabaseAccessWindow>>] keyed by employee id.
  static Map<String, List<DatabaseAccessWindow>> fromField(Object? raw) {
    if (raw is! Map) return const <String, List<DatabaseAccessWindow>>{};
    final Map<String, List<DatabaseAccessWindow>> result =
        <String, List<DatabaseAccessWindow>>{};
    raw.forEach((Object? employeeId, Object? value) {
      if (employeeId is! String || value is! List) return;
      final List<DatabaseAccessWindow> windows = <DatabaseAccessWindow>[];
      for (final Object? item in value) {
        if (item is! Map) continue;
        final Object? key = item[fPermission];
        final DatabasePermissionLevel? permission =
            DatabasePermissionLevel.fromStorageKey(key is String ? key : null);
        if (permission == null) continue;
        windows.add(DatabaseAccessWindow(
          permission: permission,
          startDate: _date(item[fStartDate]),
          endDate: _date(item[fEndDate]),
          viewableFields: _strings(item[fViewableFields]),
        ));
      }
      if (windows.isNotEmpty) result[employeeId] = windows;
    });
    return result;
  }

  static List<String> _strings(Object? value) => value is List
      ? <String>[
          for (final Object? v in value)
            if (v is String) v
        ]
      : const <String>[];

  static Timestamp? _timestamp(DateTime? value) =>
      value == null ? null : Timestamp.fromDate(value);

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
