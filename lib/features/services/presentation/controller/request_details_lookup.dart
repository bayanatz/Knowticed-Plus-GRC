/// Module: services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: request_details_lookup.dart
/// Purpose: Puts together what every request screen shows next to a request:
///          the requester's name, job title and department (from the
///          employee directory) and the current details of the service it
///          was made for (from the repository). Replaces the old
///          CreateServicesHelper, which read Firestore from the controller
///          folder with a hard-coded '/Demo/...' path.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/domain/entities/parent_service_details.dart';
import 'package:knowticed_plus/features/services/domain/entities/requester_info.dart';

export 'package:knowticed_plus/features/services/domain/entities/requester_info.dart';

/// Function Name: [requesterInfoFromEmployee]
///
/// Purpose: The names, job title and department of [employee], with the
/// department names read from [departments].
RequesterInfo requesterInfoFromEmployee(
  EmployeeEntityPro employee,
  MainCoreDepartmentCubit departments,
) {
  final departmentId = employee.departmentId;
  return RequesterInfo(
    nameEnglish:
        '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim(),
    nameArabic:
        '${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}'
            .trim(),
    departmentEnglish: departmentId == null
        ? ''
        : departments.getEnglishDepartmentNameFromDepartmentId(
              departmentId: departmentId,
            ) ??
            '',
    departmentArabic: departmentId == null
        ? ''
        : departments.getArabicDepartmentNameFromDepartmentId(
              departmentId: departmentId,
            ) ??
            '',
    jobTitleEnglish: employee.title ?? '',
    jobTitleArabic: employee.titleInArabic ?? '',
    gender: employee.gender ?? '',
  );
}

/// Requester plus parent-service details for one request.
class RequestDisplayDetails {
  const RequestDisplayDetails({
    this.requester = RequesterInfo.empty,
    this.service = ParentServiceDetails.empty,
  });

  final RequesterInfo requester;
  final ParentServiceDetails service;
}

/// Looks up the requester and the parent service of a request.
class RequestDetailsLookup {
  /// All dependencies are injected by the page that creates the cubit.
  const RequestDetailsLookup({
    required this.repository,
    required this.departments,
    required this.findEmployee,
  });

  final CreateServicesRepository repository;
  final MainCoreDepartmentCubit departments;

  /// Finds an employee in the directory by e-mail, or null.
  final EmployeeEntityPro? Function(String email) findEmployee;

  /// Function Name: [requesterInfo]
  ///
  /// Purpose: The requester's names, job title and department.
  ///
  /// Parameters:
  /// - [email]: the requester's e-mail.
  ///
  /// Returns: the info, or [RequesterInfo.empty] when the employee is unknown.
  RequesterInfo requesterInfo(String email) {
    if (email.isEmpty) return RequesterInfo.empty;
    final employee = findEmployee(email);
    if (employee == null) return RequesterInfo.empty;

    return requesterInfoFromEmployee(employee, departments);
  }

  /// Function Name: [load]
  ///
  /// Purpose: The requester info and the parent service's current details.
  /// A deleted service gives empty service details, never another
  /// service's (SVC-REQ-04).
  ///
  /// Parameters:
  /// - [parentServiceId]: the CreateServices id of the requested service.
  /// - [requesterEmail]: the requester's e-mail.
  ///
  /// Returns: the combined details. Read errors are thrown to the caller.
  Future<RequestDisplayDetails> load({
    required String parentServiceId,
    required String requesterEmail,
  }) async {
    final requester = requesterInfo(requesterEmail);
    final service = await repository.getParentServiceDetails(parentServiceId);
    return RequestDisplayDetails(requester: requester, service: service);
  }
}
