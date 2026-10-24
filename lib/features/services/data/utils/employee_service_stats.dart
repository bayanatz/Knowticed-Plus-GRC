/// Module: services / data / utils
///
///*************************** FILE INFO ****************************///
/// File Name: employee_service_stats.dart
/// Purpose: Per-employee numbers for a service (done, breached, hours worked)
///          shown on the service-details Employees tab. Moved out of the
///          sv5 widgets folder and freed from BuildContext (rules H6/H5):
///          the caller passes the language and the department names.
/// Author: Knowticed Team
/// Updated: 18/10/2026 by Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/approver_emails.dart';
import 'package:knowticed_plus/features/services/data/utils/dashboard_metrics.dart';

/// Function Name: [calculateStatsForEmployee]
///
/// Purpose: Counts the requests of [filteredItems] that [emp] HANDLED — as
/// the assigned provider (last Assigned_Provider_Email) or as an approver in
/// the request's approval cycle — that are done or breached, and the planned
/// hours of the done requests the employee provided (SVC-HOME-22: it used to
/// count the requests whose requester NAME equalled the employee's name).
///
/// Parameters:
/// - [emp]: the employee.
/// - [filteredItems]: the service's requests ({"model", "raw"} maps).
/// - [pick]: picks the reader's version of a bilingual value (the caller
///   passes context.svcPick, so this data helper has no language check).
/// - [departmentName]: the reader's name of a department id.
/// - [parentDuration]/[parentDurationUnit]: the service's own duration, used
///   when a request does not carry one.
///
/// Returns: a map with name, title, department, departmentId, done,
/// breached, hours and gender.
Map<String, dynamic> calculateStatsForEmployee(
  ServiceEmployeeModel emp,
  List<Map<String, dynamic>> filteredItems, {
  required String Function(String english, String arabic) pick,
  required String Function(String? departmentId) departmentName,
  String? parentDuration,
  String? parentDurationUnit,
}) {
  final fullName = pick(
    '${emp.firstName ?? ''} ${emp.lastName ?? ''}'.trim(),
    '${emp.firstNameInArabic ?? ''} ${emp.lastNameInArabic ?? ''}'.trim(),
  );

  int done = 0;
  int breached = 0;
  double totalMinutes = 0;

  final employeeController = AppControllers.employee;
  final String? email = emp.email;
  final departmentId = emp.departmentId ??
      (email != null
          ? employeeController.mapOfEmployeesWithEmailKey[email]?.departmentId
          : null);

  final department = departmentName(departmentId);

  final jobTitle = pick(emp.title ?? '', emp.titleInArabic ?? '');

  // SVC-HOME-22: compare e-mails, never names.
  final empEmail = (email ?? '').trim().toLowerCase();

  for (final item in filteredItems) {
    final model = item["model"] as ServicesHistoryModel;
    final data = item["raw"] as Map<String, dynamic>;

    if (empEmail.isEmpty) break;

    final providerEmail =
        _extractValue(data[ServicesHistoryKeys.kAssignedProviderEmail])
                .isNotEmpty
            ? _extractValue(data[ServicesHistoryKeys.kAssignedProviderEmail])
            : model.currentAssignedProviderEmail;
    final isProvider = providerEmail.trim().toLowerCase() == empEmail;
    final isApprover =
        (ApproverEmails.fromCycle(data[ApproverEmails.cycleField]) ??
                const <String>[])
            .contains(empEmail);

    final rawState = data["state"];
    final state = _extractValue(rawState).toLowerCase().trim();

    if (isProvider || isApprover) {
      if (state == 'done') done++;
      if (state == 'branchsla' || state == 'breached sla') breached++;

      // Planned hours (SVC-DASH-04): only completed requests the employee
      // provided, by the same rule as the dashboards.
      if (isProvider &&
          DashboardMetrics.completedStates.contains(
            DashboardMetrics.normalizeState(state),
          )) {
        // ✅ FIX: Try request doc → model → parent service duration
        final rawDuration = data['durationOfServices'] ??
            data['Duration_Of_Services'] ??
            (model.currentDurationOfServices.isNotEmpty
                ? model.currentDurationOfServices
                : null) ??
            parentDuration ??
            '0';
        final rawUnit = data['selectedDurationUnit'] ??
            data['Selected_Duration_Unit'] ??
            (model.currentSelectedDurationUnit.isNotEmpty
                ? model.currentSelectedDurationUnit
                : null) ??
            parentDurationUnit ??
            'minutes';

        final duration = double.tryParse(_extractValue(rawDuration)) ?? 0;
        // One unit parser for every screen (English or Arabic units).
        totalMinutes +=
            DashboardMetrics.toHours(duration, _extractValue(rawUnit)) * 60;
      }
    }
  }

  return {
    // Empty values are shown by the card as the translated "Not available"
    // (rule "All text in the translation files").
    "name": fullName,
    "title": jobTitle,
    "department": department,
    "departmentId": departmentId ?? '',
    "done": done,
    "breached": breached,
    "hours": totalMinutes / 60,
    "gender": emp.gender ?? 'male',
  };
}

String _extractValue(dynamic value) {
  if (value == null) return '';
  if (value is List) {
    for (int i = value.length - 1; i >= 0; i--) {
      final item = value[i]?.toString().trim() ?? '';
      if (item.isNotEmpty) return item;
    }
    return '';
  }
  if (value is Map && value.containsKey('value')) {
    return _extractValue(value['value']);
  }
  return value.toString().trim();
}
