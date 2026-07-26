/// Shared lookups used by every GRC champion/owner assignment page —
/// resolving the current user's email, finding a cached employee by email,
/// and finding a control inside an already-loaded policy->controls map.
/// Extracted because control_champion and control_owner each duplicated
/// these four functions verbatim across their cubit + 3 page files.
library;

import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Resolves the signed-in user's email for GRC assignment flows, falling
/// back from [Constant.emailUser] to the cached employee controller when
/// the constant hasn't been populated yet. Returns '' if neither is set.
String currentGrcUserEmail() {
  final fromConstant = Constant.emailUser;
  if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
  if (Get.isRegistered<MainCoreEmployeeController>()) {
    final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
    if (email != null && email.isNotEmpty) return email;
  }
  return '';
}

/// Looks up an employee by email from the globally cached employee list.
/// Returns null if the controller isn't registered or no match exists.
EmployeeEntityPro? findEmployeeByEmail(String email) {
  if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
  final employees =
      Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
  for (final e in employees) {
    if (e.email == email) return e;
  }
  return null;
}

/// Localized display name for [email], falling back to the raw email when
/// no matching employee is cached.
String employeeDisplayName(BuildContext context, String email) {
  final employee = findEmployeeByEmail(email);
  if (employee == null) return email;
  return EmployeeHelper.getEmployeeLocalizedName(
      employee: employee, context: context);
}

/// Finds the [ControlEntity] for [controlId] under [policyId] inside
/// [policyControls] — the policy-id -> controls map every champion/owner
/// assignment page already loads via GetAllControlsUseCase.
ControlEntity? findControlInPolicy(
  Map<String, List<ControlEntity>> policyControls,
  String policyId,
  String controlId,
) {
  final list = policyControls[policyId];
  if (list == null) return null;
  for (final c in list) {
    if (c.id == controlId) return c;
  }
  return null;
}
