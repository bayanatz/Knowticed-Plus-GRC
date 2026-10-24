/// Module: database / db1_create_database / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: database_member_model.dart
/// Description: Declares `DatabaseMemberModel`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// Firestore shape of a `DatabaseMember`. Moved out of the domain entity
/// (rule 1: no serialization in `domain/`), with the field keys as constants
/// (rule 15).
library;

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';

abstract final class DatabaseMemberModel {
  const DatabaseMemberModel._();

  static const String fEmployeeId = 'employee_id';
  static const String fNameEn = 'name_en';
  static const String fNameAr = 'name_ar';
  static const String fEmail = 'email';
  static const String fDepartmentId = 'department_id';
  static const String fJobTitleEn = 'job_title_en';
  static const String fJobTitleAr = 'job_title_ar';
  static const String fPhotoUrl = 'photo_url';

  /// Function Name: [toMap]
  ///
  /// Purpose: The map stored inside a grant's `members` list.
  ///
  /// Parameters: [member].
  ///
  /// Returns: [Map<String, dynamic>].
  static Map<String, dynamic> toMap(DatabaseMember member) => <String, dynamic>{
        fEmployeeId: member.employeeId,
        fNameEn: member.nameEn,
        fNameAr: member.nameAr,
        fEmail: member.email,
        fDepartmentId: member.departmentId,
        fJobTitleEn: member.jobTitleEn,
        fJobTitleAr: member.jobTitleAr,
        fPhotoUrl: member.photoUrl,
      };

  /// Function Name: [fromMap]
  ///
  /// Purpose: Read one stored member back.
  ///
  /// Parameters: [map] as Firestore returned it.
  ///
  /// Returns: [DatabaseMember].
  static DatabaseMember fromMap(Map<String, dynamic> map) => DatabaseMember(
        employeeId: (map[fEmployeeId] as String?) ?? '',
        nameEn: (map[fNameEn] as String?) ?? '',
        nameAr: (map[fNameAr] as String?) ?? '',
        email: map[fEmail] as String?,
        departmentId: map[fDepartmentId] as String?,
        jobTitleEn: map[fJobTitleEn] as String?,
        jobTitleAr: map[fJobTitleAr] as String?,
        photoUrl: map[fPhotoUrl] as String?,
      );
}
