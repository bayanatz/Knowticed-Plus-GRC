/// Module: database / db1_create_database / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_grant_model.dart
/// Description: Declares `DatabaseAccessGrantModel`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// Firestore shape of a `DatabaseAccessGrant` — one document in a database's
/// or a table's `Access_Grants`. Moved out of the domain entity (rule 1), with
/// the field keys as constants (rule 15).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_member_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';

abstract final class DatabaseAccessGrantModel {
  const DatabaseAccessGrantModel._();

  static const String fDepartmentId = 'department_id';
  static const String fDepartmentNameEn = 'department_name_en';
  static const String fDepartmentNameAr = 'department_name_ar';
  static const String fPermission = 'permission';
  static const String fStartDate = 'start_date';
  static const String fEndDate = 'end_date';
  static const String fMembers = 'members';
  static const String fMemberCount = 'member_count';
  static const String fViewableFields = 'viewable_fields';

  /// Function Name: [toMap]
  ///
  /// Purpose: The grant document as stored.
  ///
  /// Parameters: [grant].
  ///
  /// Returns: [Map<String, dynamic>].
  static Map<String, dynamic> toMap(DatabaseAccessGrant grant) =>
      <String, dynamic>{
        fDepartmentId: grant.departmentId,
        fDepartmentNameEn: grant.departmentNameEn,
        fDepartmentNameAr: grant.departmentNameAr,
        fPermission: grant.permission?.storageKey,
        fStartDate: grant.startDate?.toIso8601String(),
        fEndDate: grant.endDate?.toIso8601String(),
        fMembers: grant.members
            .map(DatabaseMemberModel.toMap)
            .toList(growable: false),
        // Denormalised so the list screen can show a count without reading
        // every member row.
        fMemberCount: grant.members.length,
        fViewableFields: grant.viewableFields,
      };

  /// Function Name: [fromMap]
  ///
  /// Purpose: Read one grant document back.
  ///
  /// Parameters: [map] as Firestore returned it.
  ///
  /// Returns: [DatabaseAccessGrant].
  static DatabaseAccessGrant fromMap(Map<String, dynamic> map) {
    final List<Object?> rawMembers =
        (map[fMembers] as List<Object?>?) ?? const <Object?>[];

    return DatabaseAccessGrant(
      departmentId: map[fDepartmentId] as String?,
      departmentNameEn: map[fDepartmentNameEn] as String?,
      departmentNameAr: map[fDepartmentNameAr] as String?,
      permission: DatabasePermissionLevel.fromStorageKey(
        map[fPermission] as String?,
      ),
      startDate: _date(map[fStartDate]),
      endDate: _date(map[fEndDate]),
      members: rawMembers
          .whereType<Map<String, dynamic>>()
          .map(DatabaseMemberModel.fromMap)
          .toList(growable: false),
      // Absent on grants written before this field existed, which read back as an
      // empty list — "all fields", the access those grants actually gave.
      viewableFields:
          ((map[fViewableFields] as List<Object?>?) ?? const <Object?>[])
              .whereType<String>()
              .toList(growable: false),
    );
  }

  /// Grant dates were written as ISO strings while every other Database date
  /// is a Timestamp (DB-4); read either, and never throw on a wrong type.
  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
