import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';

import 'package:knowticed_plus/features/qiyas/helpers/constant/employee_keys.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/qiyas_person_entity.dart';

mixin EmployeeEntityDetailsController on ControlCoreCubit {
  /// function name: [getEmployeeFromEmail]
  ///
  /// purpose: Retrieves a specific employee's details by their email.
  ///          This function is used to get an employee's full details using the email address.
  ///
  /// parameters:
  ///            [email] String: The email address of the employee.
  ///
  /// return type: [EmployeeEntity?]: Returns the employee entity if found, otherwise null.
  QiyasPersonEntity? getEmployeeFromEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final matchingEmployees = showEmployees.where(
      (emp) => (emp.id.trim().toLowerCase()) == normalizedEmail,
    );
    if (matchingEmployees.isEmpty) return null;
    return matchingEmployees.first;
  }

  /// function name: [getEmployeeDetailsFromEmail]
  ///
  /// purpose: Retrieves detailed information about an employee from their email address.
  ///          This function is used to fetch additional data such as phone number, job title, and department.
  ///
  /// parameters:
  ///            [email] String: The email address of the employee.
  ///
  /// return type: [Map<String, dynamic>?]: Returns a map of the employee's details or null if not found.
  Map<String, dynamic>? getEmployeeDetailsFromEmail(String email) {
    final matchedEmployee = getEmployeeFromEmail(email);
    debugPrint("🔍 Looking for email: $email");
    for (var emp in showEmployees) {
      debugPrint("Checking: ${emp.id}");

      return {
        EmployeeKeys.email: matchedEmployee?.id,
        EmployeeKeys.phone: matchedEmployee?.phone,
        EmployeeKeys.jobTitle: matchedEmployee?.title,
        EmployeeKeys.department: createModuleController
            .getDepartmentNameInArabic(matchedEmployee!.department),
        EmployeeKeys.photo: matchedEmployee.image,
      };
    }
    return null;
  }

  /// function name: [getEmployeesFromEmails]
  ///
  /// purpose: Filters the employee list based on the provided emails.
  ///          This function is used to retrieve employee details by their email addresses.
  ///
  /// parameters:
  ///            [emails] List`<String>`: A list of email addresses to search for.
  ///
  /// return type: [List<EmployeeEntity>]: Returns a list of employee entities that match the emails.
  List<QiyasPersonEntity> getEmployeesFromEmails(List<String> emails) {
    emails = emails.map((e) => e.trim().toLowerCase()).toList();
    return showEmployees.where((e) => emails.contains(e.id)).toList();
  }
}
