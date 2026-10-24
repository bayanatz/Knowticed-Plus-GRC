/// Module: database / db2_database_details / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: removed_access_member_model.dart
/// Description: Declares `RemovedAccessMemberModel`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// Firestore shape of a `RemovedAccessMember` — one entry in a grant's
/// removed-members history. Moved out of the domain entity (rule 1), with the
/// field keys as constants (rule 15).
library;

import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_member_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';

abstract final class RemovedAccessMemberModel {
  const RemovedAccessMemberModel._();

  static const String fMember = 'member';
  static const String fPermission = 'permission';
  static const String fStartDate = 'start_date';
  static const String fEndDate = 'end_date';
  static const String fRemovedAt = 'removed_at';
  static const String fDepartmentId = 'department_id';
  static const String fDepartmentNameEn = 'department_name_en';
  static const String fDepartmentNameAr = 'department_name_ar';

  /// Function Name: [toMap]
  ///
  /// Purpose: One removed-member entry as stored.
  ///
  /// Parameters: [removed].
  ///
  /// Returns: [Map<String, dynamic>].
  static Map<String, dynamic> toMap(RemovedAccessMember removed) =>
      <String, dynamic>{
        fMember: DatabaseMemberModel.toMap(removed.member),
        fPermission: removed.permission?.storageKey,
        fStartDate: removed.startDate?.toIso8601String(),
        fEndDate: removed.endDate?.toIso8601String(),
        fRemovedAt: removed.removedAt?.toIso8601String(),
        fDepartmentId: removed.departmentId,
        fDepartmentNameEn: removed.departmentNameEn,
        fDepartmentNameAr: removed.departmentNameAr,
      };

  /// Function Name: [fromMap]
  ///
  /// Purpose: Read one removed-member entry back.
  ///
  /// Parameters: [map] as Firestore returned it.
  ///
  /// Returns: [RemovedAccessMember].
  static RemovedAccessMember fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> rawMember =
        (map[fMember] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return RemovedAccessMember(
      member: DatabaseMemberModel.fromMap(rawMember),
      permission:
          DatabasePermissionLevel.fromStorageKey(map[fPermission] as String?),
      startDate: DateTime.tryParse((map[fStartDate] as String?) ?? ''),
      endDate: DateTime.tryParse((map[fEndDate] as String?) ?? ''),
      removedAt: DateTime.tryParse((map[fRemovedAt] as String?) ?? ''),
      departmentId: map[fDepartmentId] as String?,
      departmentNameEn: map[fDepartmentNameEn] as String?,
      departmentNameAr: map[fDepartmentNameAr] as String?,
    );
  }
}
