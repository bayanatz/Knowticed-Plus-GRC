/// Module: database / db1_create_database / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: database_directory_repository.dart
/// Description: Declares `DatabaseDirectoryRepository`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// Reuses the roles feature's employee and department controllers, reached
/// through `AppControllers` — the app's one seam to the GetX locator —
/// rather than opening a second set of Firestore queries: those two are the
/// single source for the org chart and are already warm by the time any
/// screen is reachable. Registered once in `main.dart`.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_directory_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_department.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_directory.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class DatabaseDirectoryRepository implements DatabaseDirectoryBaseRepository {
  const DatabaseDirectoryRepository();

  @override
  Future<Either<Failure, DatabaseDirectory>> loadDirectory() async {
    try {
      final List<EmployeeEntityPro> employees =
          (await AppControllers.employee.getAllNewEmployees()) ??
              <EmployeeEntityPro>[];
      final List<DepartmentModelPro> departments =
          await AppControllers.departments.getAllDepartments();

      return Right<Failure, DatabaseDirectory>(DatabaseDirectory(
        members: employees
            .map(_memberFromEmployee)
            .where((DatabaseMember m) => m.employeeId.isNotEmpty)
            .toList(growable: false),
        departments: departments
            .map(_departmentFromModel)
            .where((DatabaseDepartment d) => d.id.isNotEmpty)
            .toList(growable: false),
      ));
    } catch (error) {
      // `Get.find` throws when a controller was never registered; the cause
      // goes to the debug log, a translated sentence to the screen.
      if (kDebugMode) {
        debugPrint('🔴 [DatabaseDirectoryRepository] directory failed: $error');
      }
      return Left<Failure, DatabaseDirectory>(
        FeatureFailure(S.current.dbEmployeeListLoadFailed),
      );
    }
  }

  @override
  Future<Either<Failure, DatabaseMember?>> findMember(String employeeId) async {
    if (employeeId.isEmpty) return const Right<Failure, DatabaseMember?>(null);
    try {
      final List<EmployeeEntityPro> employees =
          (await AppControllers.employee.getAllNewEmployees()) ??
              <EmployeeEntityPro>[];
      for (final EmployeeEntityPro e in employees) {
        if (e.id == employeeId) {
          return Right<Failure, DatabaseMember?>(_memberFromEmployee(e));
        }
      }
      return const Right<Failure, DatabaseMember?>(null);
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
            '🔴 [DatabaseDirectoryRepository] member lookup failed: $error');
      }
      return Left<Failure, DatabaseMember?>(
        FeatureFailure(S.current.dbEmployeeListLoadFailed),
      );
    }
  }

  /// Narrows a ~70-field employee record to the eight fields the access list
  /// needs. See `DatabaseMember`'s header for why the full entity is not
  /// carried through the flow.
  DatabaseMember _memberFromEmployee(EmployeeEntityPro e) {
    String join(String? first, String? last) => <String?>[first, last]
        .whereType<String>()
        .where((String s) => s.isNotEmpty)
        .join(' ');

    return DatabaseMember(
      employeeId: e.id ?? '',
      nameEn: join(e.firstName, e.lastName),
      nameAr: join(e.firstNameInArabic, e.lastNameInArabic),
      email: e.email,
      departmentId: e.departmentId,
      jobTitleEn: e.title,
      jobTitleAr: e.titleInArabic,
      photoUrl: e.photo,
    );
  }

  DatabaseDepartment _departmentFromModel(DepartmentModelPro d) =>
      DatabaseDepartment(
        id: d.departmentID ?? '',
        nameEn: d.departmentName ?? '',
        nameAr: d.departmentNameInArabic ?? '',
      );
}
