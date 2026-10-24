/// Module: knowledge_hub/data/utils
///
///*************************** FILE INFO ****************************///
/// File Name: kh_people.dart
/// Description: The signed-in employee plus the shared employee and
///              department lists, injected into the Knowledge Hub cubits so
///              widgets never look them up with Get.find (rule 3).
/// Author: Amr Mesbah
/// Created at: 20/10/2026
library;

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

/// Employee and department lookups for the Knowledge Hub.
///
/// Created once in `KnowledgeHubDI` (the only place that talks to the
/// locator) and passed to every Knowledge Hub cubit. Widgets reach it through
/// their cubit: `context.read<ApprovalsCubit>().people`.
class KhPeople {
  /// [employees] and [departments] return the controllers registered at app
  /// start, or null when they are not registered yet.
  const KhPeople({
    required MainCoreEmployeeController? Function() employees,
    required MainCoreDepartmentCubit? Function() departments,
  }) : _employees = employees,
       _departments = departments;

  final MainCoreEmployeeController? Function() _employees;
  final MainCoreDepartmentCubit? Function() _departments;

  /// The employee controller, or null before it is registered.
  MainCoreEmployeeController? get employeesOrNull => _employees();

  /// The department cubit, or null before it is registered.
  MainCoreDepartmentCubit? get departmentsOrNull => _departments();

  /// The employee controller. Throws (like `Get.find`) when not registered.
  MainCoreEmployeeController get employees => _employees()!;

  /// The department cubit. Throws (like `Get.find`) when not registered.
  MainCoreDepartmentCubit get departments => _departments()!;

  /// The signed-in employee, or null while it is not loaded.
  EmployeeEntityPro? get signedInEmployee => _employees()?.employeeEntity;

  /// The signed-in employee's e-mail, or '' while it is not loaded.
  String get signedInEmail => signedInEmployee?.email ?? '';
}
