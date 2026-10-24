/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_directory.dart
/// Description: The one place the Form Builder reads the signed-in employee,
///              the employee list and the department names from the app-wide
///              controllers. Mappers and factories call this instead of
///              `Get.find`, so the domain layer stays free of GetX.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:get/get.dart';

/// Read-only access to the signed-in user, the employee list and departments.
class FormBuilderDirectory {
  const FormBuilderDirectory._();

  /// Email of the signed-in employee, or '' before sign-in.
  static String get currentUserEmail => AppControllers.isEmployeeRegistered
      ? (AppControllers.employee.employeeEntity?.email ?? '')
      : '';

  /// Id of the signed-in employee, or '' before sign-in.
  static String get currentUserId => AppControllers.isEmployeeRegistered
      ? (AppControllers.employee.employeeEntity?.id ?? '')
      : '';

  /// Method Name: [employeeByEmail]
  ///
  /// Purpose: safe lookup of an employee by email.
  ///
  /// Parameters:
  /// - [email]: the employee's email.
  ///
  /// Returns: the employee, or null when the email is not in the list.
  static EmployeeEntityPro? employeeByEmail(String email) {
    if (!AppControllers.isEmployeeRegistered) return null;
    return AppControllers.employee.getLocaleEmployee(email);
  }

  /// Every employee currently loaded (empty before the list arrives).
  static List<EmployeeEntityPro> get allEmployees =>
      AppControllers.isEmployeeRegistered
          ? (AppControllers.employee.allEmployeesEntities ?? const [])
          : const [];

  /// Method Name: [departmentName]
  ///
  /// Purpose: the department's name, never throwing.
  ///
  /// Parameters:
  /// - [departmentId]: the department id.
  /// - [english]: true for the English name, false for the Arabic one.
  ///
  /// Returns: the name, or '' when the department is unknown.
  static String departmentName(String departmentId, {required bool english}) {
    if (departmentId.isEmpty || !Get.isRegistered<MainCoreDepartmentCubit>()) {
      return '';
    }
    try {
      return Get.find<MainCoreDepartmentCubit>()
          .getDepartmentName(departmentId, english);
    } catch (_) {
      return '';
    }
  }

  /// Method Name: [ensureDepartmentsLoaded]
  ///
  /// Purpose: loads the department list if it is still empty.
  ///
  /// Returns: false when the list could not be loaded (FB-RESULT-07: the
  /// caller shows a warning instead of staying silent).
  static Future<bool> ensureDepartmentsLoaded() async {
    if (!Get.isRegistered<MainCoreDepartmentCubit>()) return false;
    try {
      final MainCoreDepartmentCubit departments =
          Get.find<MainCoreDepartmentCubit>();
      if (departments.departmentModels.isEmpty) {
        await departments.getAllDepartments();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
