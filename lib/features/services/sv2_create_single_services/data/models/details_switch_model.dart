/// Module: services / sv2_create_single_services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: details_switch_model.dart
/// Purpose: Data model for Details Switch Screen Created by: Amr Mesbah Last
///          Update: 01/12/2025
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

class DetailsSwitchModel {
  bool limitAvailability = false;
  bool requireApproval = false;
  // ✅ `shouldPreventAutoRequester` removed alongside the auto-select of the
  // current user as first approver — there is no auto-selection left to guard
  // against, so the flag had nothing to prevent.
  bool didInitFromEditModel = false;
  bool navigated = false;
  bool isLoading = true;

  /// SVC-CREATE-08: the employee list (or their role permissions) could not
  /// be loaded; the screen shows an error with Retry instead of spinning.
  bool employeesLoadFailed = false;

  /// SVC-CREATE-04: the saved approvers / departments of the service being
  /// edited could not be read. Saving is blocked so the service is never
  /// saved with them silently removed.
  bool loadFailed = false;

  List<String> selectedDepartments = [];
  List<EmployeeEntityPro> allEmployees = [];
  List<EmployeeEntityPro> filteredEmployees = [];
  List<EmployeeEntityPro> selectedEmployees = [];

  final ServicesHistoryModel? editingModel;
  final String? docId;
  final bool isEditMode;

  DetailsSwitchModel({this.editingModel, this.docId})
      : isEditMode = editingModel != null;
}
