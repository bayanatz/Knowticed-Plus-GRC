/// Module: services / sv2_create_single_services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: details_switch_cubit.dart
/// Purpose: Business logic for Details Switch Screen Created by: Amr Mesbah
///          Last Update: 01/12/2025
/// Updated: Migrated from ServicesManagerCubit to MainCoreEmployeeController
/// Author: Amr Mesbah
library;

import 'package:knowticed_plus/core/di/app_controllers.dart';

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/employee_services_permissions.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/data/models/details_switch_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/details_switch_state.dart';
import 'package:knowticed_plus/features/services/data/data_source/local_data_source/services_prefs_employee.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';

class DetailsSwitchCubit extends Cubit<DetailsSwitchState> {
  /// The key SharedPrefsApprovalHelper actually writes to.
  ///
  /// ✅ FIX (bug report p1/p10): this cubit used to read/remove a bare
  /// `'approval_cycle'` key that nothing ever wrote. The effect was that
  /// (a) the "clear stale cycle" calls were no-ops, so an approval cycle
  /// staged for one service leaked into the next, and (b) the "restore staged
  /// cycle" branches were dead code. Both are why editing a service's approval
  /// cycle appeared to do nothing.
  static const String _approvalCycleKey = 'approval_cycle_employees';

  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final DetailsSwitchModel model;
  final MainCoreEmployeeController employeeController = AppControllers.employee;

  /// Injected role data for the approver permission check.
  final RoleRepository roleRepository;
  final List<RoleHistoryModel> Function() roles;

  DetailsSwitchCubit({
    required this.roleRepository,
    required this.roles,
    ServicesHistoryModel? editingModel,
    String? docId,
  })  : model = DetailsSwitchModel(editingModel: editingModel, docId: docId),
        super(DetailsSwitchInitial());

  Future<void> loadEmployees() async {
    model.employeesLoadFailed = false;
    model.isLoading = true;
    try {
      var employees = employeeController.allEmployeesEntities;
      if (employees == null || employees.isEmpty) {
        employees = await employeeController.getAllNewEmployees();
      }

      if (employees != null && employees.isNotEmpty) {
        // SVC-CREATE-10: wait for the real role permissions before filtering
        // approvers; never guess from job titles.
        await EmployeeServicesPermissions.preload(
          employees,
          roles: roles(),
          repository: roleRepository,
        );
        model.allEmployees = employees;
        model.employeesLoadFailed = !EmployeeServicesPermissions.isReady ||
            EmployeeServicesPermissions.hasFailures;
        _updateFilteredEmployees();
      } else {
        model.employeesLoadFailed = true;
      }
    } catch (e) {
      // SVC-CREATE-08: show an error with Retry instead of an empty list.
      svcLog('DetailsSwitchCubit.loadEmployees failed: $e');
      model.employeesLoadFailed = true;
    }
    model.isLoading = false;
    _emitLoaded();
  }

  Future<void> loadInitialData() async {
    try {
      // ✅ FIX: Clear stale SharedPrefs for fresh service creation
      if (model.editingModel == null && model.docId == null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('selected_departments');
        await prefs.remove(_approvalCycleKey);
        _emitLoaded();
        return;
      }

      if (model.editingModel != null) {
        if (model.editingModel!.currentApprovalCycle.isNotEmpty) {
          _loadFromEditingModel(model.editingModel!);

          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('selected_departments');

          // Seed the staged cycle with what this service currently has, so a
          // save that happens before the user reaches the approvals step
          // writes back this service's own cycle rather than a leftover one.
          await SharedPrefsApprovalHelper.saveApprovalCycle(
            model.editingModel!.currentApprovalCycle,
          );
          return;
        } else {
          final prefs = await SharedPreferences.getInstance();
          // Only restore a staged cycle when resuming the same draft. Without
          // the docId guard this would pick up a cycle staged for a different
          // service, now that the key finally matches what the helper writes.
          final savedApprovalCycleJson =
              model.docId == null ? null : prefs.getString(_approvalCycleKey);

          if (savedApprovalCycleJson != null) {
            final List<dynamic> decoded = jsonDecode(savedApprovalCycleJson);
            final savedApprovalCycle = decoded
                .map((e) => _employeeFromJson(e as Map<String, dynamic>))
                .toList();

            model.selectedEmployees = savedApprovalCycle
                .map(
                  (e) => model.allEmployees.firstWhere(
                    (a) => a.id == e.id,
                    orElse: () => EmployeeEntityPro(
                      id: e.id ?? '',
                      firstName: e.firstName,
                      lastName: e.lastName,
                      email: e.email,
                      role: e.role,
                      title: e.title,
                      titleInArabic: e.titleInArabic,
                    ),
                  ),
                )
                // SVC-CREATE-10: keep approvers already chosen for this service;
                // eligibility filtering applies to new picks only.
                .toList();

            model.requireApproval = savedApprovalCycle.isNotEmpty;
            _updateFilteredEmployees();
          } else {
            _loadFromEditingModel(model.editingModel!);
          }

          final savedDepartmentsJson = prefs.getString('selected_departments');
          if (model.editingModel!.currentSelectDepartment.isNotEmpty) {
            model.selectedDepartments = List<String>.from(
              model.editingModel!.currentSelectDepartment,
            );
            model.limitAvailability = model.selectedDepartments.isNotEmpty;
          } else if (savedDepartmentsJson != null) {
            final List<dynamic> decoded = jsonDecode(savedDepartmentsJson);
            model.selectedDepartments = decoded.cast<String>();
            model.limitAvailability = model.selectedDepartments.isNotEmpty;
          }

          _emitLoaded();
          return;
        }
      }

      // docId only (continuing a new service mid-flow)
      final prefs = await SharedPreferences.getInstance();
      final savedDepartmentsJson = prefs.getString('selected_departments');
      final savedApprovalCycleJson = prefs.getString(_approvalCycleKey);

      if (savedDepartmentsJson != null) {
        final List<dynamic> decoded = jsonDecode(savedDepartmentsJson);
        model.selectedDepartments = decoded.cast<String>();
      }

      if (savedApprovalCycleJson != null) {
        final List<dynamic> decoded = jsonDecode(savedApprovalCycleJson);
        final savedApprovalCycle = decoded
            .map((e) => _employeeFromJson(e as Map<String, dynamic>))
            .toList();

        model.selectedEmployees = savedApprovalCycle
            .map(
              (e) => model.allEmployees.firstWhere(
                (a) => a.id == e.id,
                orElse: () => EmployeeEntityPro(
                  id: e.id ?? '',
                  firstName: e.firstName,
                  lastName: e.lastName,
                  email: e.email,
                ),
              ),
            )
            // SVC-CREATE-10: keep approvers already chosen for this service;
            // eligibility filtering applies to new picks only.
            .toList();
      }

      model.limitAvailability = model.selectedDepartments.isNotEmpty;
      model.requireApproval = model.selectedEmployees.isNotEmpty;

      _updateFilteredEmployees();
      _emitLoaded();
    } catch (e) {
      // SVC-CREATE-04: keep what was loaded and block saving for an existing
      // service or draft, so it is never saved with its settings removed.
      svcLog('DetailsSwitchCubit.loadInitialData failed: $e');
      model.loadFailed = model.isEditMode || model.docId != null;
      _emitLoaded();
    }
  }

  /// Helper method to create EmployeeEntityPro from JSON
  EmployeeEntityPro _employeeFromJson(Map<String, dynamic> json) {
    return EmployeeEntityPro(
      id: json['id'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      firstNameInArabic: json['firstNameInArabic'] as String?,
      lastNameInArabic: json['lastNameInArabic'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      title: json['title'] as String?,
      titleInArabic: json['titleInArabic'] as String?,
      gender: json['gender'] as String?,
      photo: json['photo'] as String?,
      departmentId: json['departmentId'] as String?,
    );
  }

  void _loadFromEditingModel(ServicesHistoryModel editingModel) {
    try {
      final currentSelectDepartment = editingModel.currentSelectDepartment;
      final currentApprovalCycle = editingModel.currentApprovalCycle;

      model.selectedDepartments = List<String>.from(currentSelectDepartment);

      // SVC-CREATE-10: keep the saved approvers as they are; dropping
      // them on edit because of a job-title guess silently changed the
      // service's approval chain.
      model.selectedEmployees = currentApprovalCycle
          .map(
            (approver) => EmployeeEntityPro(
              id: approver.id,
              firstName: approver.firstName,
              lastName: approver.lastName,
              firstNameInArabic: approver.firstNameInArabic,
              lastNameInArabic: approver.lastNameInArabic,
              email: approver.email,
              role: approver.role,
              title: approver.title,
              titleInArabic: approver.titleInArabic,
              gender: approver.gender,
              photo: approver.photo,
              departmentId: approver.departmentId,
            ),
          )
          .toList();

      model.limitAvailability = currentSelectDepartment.isNotEmpty;
      model.requireApproval = currentApprovalCycle.isNotEmpty;

      _updateFilteredEmployees();
      _emitLoaded();
    } catch (e) {
      // SVC-CREATE-04: never replace the saved settings with defaults because
      // a read failed. Keep what the model has and block saving.
      svcLog('DetailsSwitchCubit: reading the saved service failed: $e');
      model.loadFailed = true;
      _emitLoaded();
    }
  }

  /// "Not eligible to approve", from the employee's ROLE only — the
  /// "Approval Permissions" section and "Approve And Reject" switch.
  /// SVC-CREATE-10: the job-title keyword fallback was removed; until the
  /// permissions are loaded nobody is offered (and the screen says why).
  bool _isRegularEmployee(EmployeeEntityPro employee) =>
      !EmployeeServicesPermissions.canApprove(employee);

  // Add this field at the top of the cubit
  String _currentSearchQuery = '';

  /// Department id the approver list is filtered by, or null for "all".
  /// ✅ NEW (bug report p29): the Add Approvals picker had search only.
  String? _departmentFilterId;

  String? get departmentFilterId => _departmentFilterId;

  /// Department ids that the eligible approvers actually belong to.
  ///
  /// Mirrors the dashboard fix: only offer departments that have something to
  /// show, rather than every department in the tenant.
  List<String> get approverDepartmentIds {
    final ids = <String>{};
    for (final e in model.allEmployees) {
      if (_isRegularEmployee(e)) continue;
      final id = e.departmentId;
      if (id != null && id.isNotEmpty) ids.add(id);
    }
    return ids.toList();
  }

  void updateSearch(String query) {
    _currentSearchQuery = query; // ✅ Save it
    _updateFilteredEmployees(); // reuse the same logic
    _emitLoaded();
  }

  /// Filters the approver grid by department. Pass null to clear the filter.
  void updateDepartmentFilter(String? departmentId) {
    _departmentFilterId =
        (departmentId == null || departmentId.isEmpty) ? null : departmentId;
    _updateFilteredEmployees();
    _emitLoaded();
  }

  void toggleLimitAvailability(bool value) {
    if (!value) {
      model.selectedDepartments.clear();
    }
    model.limitAvailability = value;
    _emitLoaded();
  }

  void toggleRequireApproval(bool value) {
    model.requireApproval = value;
    if (!value) {
      model.selectedEmployees.clear();
    }
    _emitLoaded();
  }

  void addDepartment(
    String val,
    bool isEnglish,
    List<String> en,
    List<String> ar,
  ) {
    if (isEnglish) {
      if (!model.selectedDepartments.contains(val)) {
        model.selectedDepartments.add(val);
      }
    } else {
      final idx = ar.indexOf(val);
      final enName = idx >= 0 ? en[idx] : val;
      if (!model.selectedDepartments.contains(enName)) {
        model.selectedDepartments.add(enName);
      }
    }
    model.limitAvailability = model.selectedDepartments.isNotEmpty;
    _emitLoaded();
  }

  void removeDepartment(
    String val,
    bool isEnglish,
    List<String> en,
    List<String> ar,
  ) {
    if (isEnglish) {
      model.selectedDepartments.remove(val);
    } else {
      final idx = ar.indexOf(val);
      final enName = idx >= 0 ? en[idx] : val;
      model.selectedDepartments.remove(enName);
    }
    model.limitAvailability = model.selectedDepartments.isNotEmpty;
    _emitLoaded();
  }

  bool isSelected(EmployeeEntityPro employee) {
    return model.selectedEmployees.any((e) => e.id == employee.id);
  }

  void toggleEmployeeSelection(EmployeeEntityPro employee) {
    if (isSelected(employee)) {
      model.selectedEmployees.removeWhere((e) => e.id == employee.id);
    } else {
      model.selectedEmployees.add(employee);
    }
    _updateFilteredEmployees();
    _emitLoaded();
  }

  void removeEmployeeAt(int index) {
    model.selectedEmployees.removeAt(index);
    _updateFilteredEmployees();
    _emitLoaded();
  }

  void _updateFilteredEmployees() {
    final q = _currentSearchQuery.trim().toLowerCase(); // add this field
    var eligibleEmployees =
        model.allEmployees.where((e) => !_isRegularEmployee(e)).toList();

    // ✅ NEW (bug report p29): narrow the picker to one department when the
    // dropdown filter is set. Applied before search so the two combine.
    // Already-selected approvers are kept visible regardless, otherwise
    // switching department would appear to drop the current selection.
    if (_departmentFilterId != null) {
      eligibleEmployees = eligibleEmployees.where((e) {
        final isAlreadySelected = model.selectedEmployees.any(
          (s) => s.id == e.id,
        );
        return isAlreadySelected || e.departmentId == _departmentFilterId;
      }).toList();
    }

    final sel = eligibleEmployees
        .where((e) => model.selectedEmployees.any((s) => s.id == e.id))
        .toList();

    if (q.isEmpty) {
      final rest = eligibleEmployees.where((e) => !sel.contains(e)).toList();
      model.filteredEmployees = [...sel, ...rest];
    } else {
      model.filteredEmployees = eligibleEmployees.where((e) {
        final enFirst = (e.firstName ?? '').trim().toLowerCase();
        final enLast = (e.lastName ?? '').trim().toLowerCase();
        final arFirst = (e.firstNameInArabic ?? '').trim().toLowerCase();
        final arLast = (e.lastNameInArabic ?? '').trim().toLowerCase();
        return enFirst.contains(q) ||
            enLast.contains(q) ||
            '$enFirst $enLast'.contains(q) ||
            arFirst.contains(q) ||
            arLast.contains(q) ||
            '$arFirst $arLast'.contains(q);
      }).toList();
    }
  }

  void checkAndLoadFromEditingModel() {
    if (!model.didInitFromEditModel && model.isEditMode) {
      _loadFromEditingModel(model.editingModel!);
      model.didInitFromEditModel = true;
    }
  }

  // ✅ REMOVED: checkAndAutoSelectRequester().
  //
  // Turning on "require approval" used to silently drop the current user into
  // the approval cycle as the first approver. Nobody picked them, so the
  // selection was a default nobody asked for — and because it looked like a
  // real choice it was easy to save a service with the requester approving
  // their own request.
  //
  // The approval cycle now starts empty and stays empty until an approver is
  // tapped. validateForm() already blocks moving on with
  // `requireApproval && selectedEmployees.isEmpty`, so the user is told to
  // choose rather than having one chosen for them.

  void updateEmployeesFromController(List<EmployeeEntityPro>? employees) {
    if (employees != null && employees.isNotEmpty) {
      model.allEmployees = employees;

      checkAndLoadFromEditingModel();

      _updateFilteredEmployees();
      _emitLoaded();
    }
  }

  void setNavigated(bool value) {
    model.navigated = value;
  }

  bool validateForm() {
    // SVC-CREATE-04: the saved approvers/departments could not be read, so
    // continuing would save the service without them.
    if (model.loadFailed) {
      emit(
        DetailsSwitchValidationError(
          title: 'validationError',
          message: 'loadFailed',
          lottiePath: ServicesLottie.rejected,
        ),
      );
      return false;
    }

    if (model.limitAvailability && model.selectedDepartments.isEmpty) {
      emit(
        DetailsSwitchValidationError(
          title: 'validationError',
          message: 'mustSelectDepartment',
          lottiePath: ServicesLottie.warningRed,
        ),
      );
      return false;
    }

    if (model.requireApproval && model.selectedEmployees.isEmpty) {
      emit(
        DetailsSwitchValidationError(
          title: 'validationError',
          message: 'mustSelectApprovalEmployees',
          lottiePath: ServicesLottie.rejected,
        ),
      );
      return false;
    }

    return true;
  }

  void _emitLoaded() {
    emit(
      DetailsSwitchLoaded(
        allEmployees: model.allEmployees,
        filteredEmployees: model.filteredEmployees,
        selectedEmployees: model.selectedEmployees,
        selectedDepartments: model.selectedDepartments,
        limitAvailability: model.limitAvailability,
        requireApproval: model.requireApproval,
        isLoading: model.isLoading,
      ),
    );
  }
}
