/// Module: services / data / data_source / local_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: services_prefs_employee.dart
/// Purpose: Services prefs employee — declares SharedPrefsEmployeeHelper,
///          SharedPrefsApprovalHelper.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';

/// Module-local copies of the employee / approval prefs helpers, using the
/// module's real ServiceEmployeeModel. Bundled so the services-management
/// module is self-contained and portable; core/utils/shared.dart keeps its
/// own (stub-typed) versions for non-module code.
class SharedPrefsEmployeeHelper {
  static const String _key = 'selected_employees';

  static Future<void> saveSelectedEmployees(
    List<ServiceEmployeeModel> employees,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final employeeJson = employees.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(employeeJson));
  }

  static Future<List<ServiceEmployeeModel>> getSelectedEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => ServiceEmployeeModel.fromJson(e)).toList();
  }

  static Future<void> clearSelectedEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class SharedPrefsApprovalHelper {
  static const _approvalKey = 'approval_cycle_employees';

  static Future<void> saveApprovalCycle(
    List<ServiceEmployeeModel> employees,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final employeeJson = employees.map((e) => e.toJson()).toList();
    await prefs.setString(_approvalKey, jsonEncode(employeeJson));
  }

  static Future<List<ServiceEmployeeModel>> getApprovalCycle() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_approvalKey);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => ServiceEmployeeModel.fromJson(e)).toList();
  }

  static Future<void> clearApprovalCycle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_approvalKey);
  }
}
