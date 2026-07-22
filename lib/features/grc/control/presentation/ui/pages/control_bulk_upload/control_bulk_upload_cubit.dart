/// Module: GRC Control Bulk Upload
/// Description: BLoC Cubit driving the Control bulk upload preview table:
///              owns the editable [ControlBulkUploadRows], forwards
///              row-management actions to it, and on submit calls
///              [CreateControlUseCase] once per row (best-effort), then
///              assigns each row's Control Champion/Owner emails via
///              [ChampionCubit]/[OwnerCubit] using the same
///              find-existing-or-create logic already built for
///              AddEditControlPage — see the plan's Global Constraints for
///              why this keeps its own local assignment snapshot instead
///              of re-reading championCubit.state/ownerCubit.state between
///              rows.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, get, CreateControlUseCase, ChampionCubit,
///               OwnerCubit, ControlBulkUploadRows
library;

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'control_bulk_upload_state.dart';

class ControlBulkUploadCubit extends Cubit<ControlBulkUploadState> {
  ControlBulkUploadCubit({
    required CreateControlUseCase createControlUseCase,
    required ChampionCubit championCubit,
    required OwnerCubit ownerCubit,
    required List<ControlBulkRow> parsedRows,
    required bool equalWeights,
    required DateTime policyStartDate,
    required DateTime policyEndDate,
  })  : _createUseCase = createControlUseCase,
        _championCubit = championCubit,
        _ownerCubit = ownerCubit,
        _equalWeights = equalWeights,
        _rows = ControlBulkUploadRows(
          parsedRows,
          knownEmployeeEmails: _resolveKnownEmployeeEmails(),
          knownDepartmentNames: _resolveKnownDepartmentNames(),
          equalWeights: equalWeights,
          policyStartDate: policyStartDate,
          policyEndDate: policyEndDate,
        ),
        super(ControlBulkUploadEditing());

  final CreateControlUseCase _createUseCase;
  final ChampionCubit _championCubit;
  final OwnerCubit _ownerCubit;
  final bool _equalWeights;
  final ControlBulkUploadRows _rows;

  /// The editable row collection backing the preview table.
  ControlBulkUploadRows get rowsData => _rows;

  /// Whether this batch uses equal department-weight splitting — the
  /// preview table uses this to render the Department Weight column
  /// read-only (its value is auto-computed, not user-entered) when true.
  bool get equalWeights => _equalWeights;

  static Set<String> _resolveKnownEmployeeEmails() {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return {};
    final employees = Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
    return employees.map((e) => e.email ?? '').where((e) => e.isNotEmpty).toSet();
  }

  static Set<String> _resolveKnownDepartmentNames() {
    if (!Get.isRegistered<MainCoreDepartmentController>()) return {};
    final departmentController = Get.find<MainCoreDepartmentController>();
    final names = <String>{};
    for (final id in departmentController.departmentIds) {
      final en =
          departmentController.getEnglishDepartmentNameFromDepartmentId(departmentId: id);
      final ar =
          departmentController.getArabicDepartmentNameFromDepartmentId(departmentId: id);
      if (en != null) names.add(en);
      if (ar != null) names.add(ar);
    }
    return names;
  }

  /// Resolves the currently logged-in user's email (same lookup as
  /// PolicyCubit/ChampionCubit/OwnerCubit).
  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  void toggleRowSelected(int index) {
    _rows.toggleSelected(index);
    emit(ControlBulkUploadEditing());
  }

  void addRow() {
    _rows.addBlankRow();
    emit(ControlBulkUploadEditing());
  }

  void removeSelectedRows() {
    _rows.removeSelected();
    emit(ControlBulkUploadEditing());
  }

  void duplicateSelectedRow() {
    _rows.duplicateSelected();
    emit(ControlBulkUploadEditing());
  }

  /// Re-runs validation for one row (called on every cell edit) and
  /// recomputes cross-row duplicate flags.
  void revalidateRow(int index) {
    _rows.revalidateRow(index);
    emit(ControlBulkUploadEditing());
  }

  /// function name: [submit]
  ///
  /// purpose: create every row as a real Control via [CreateControlUseCase],
  ///          best-effort, then assign that row's Champion/Owner emails.
  ///          Rows that succeed are removed from [rowsData]; rows that fail
  ///          stay, in order, so [ControlBulkUploadSubmitResult.failed]
  ///          lines up 1:1 with the remaining rows afterward.
  Future<void> submit({required String moduleId, required String policyId}) async {
    emit(ControlBulkUploadSubmitting());

    var succeededCount = 0;
    final failed = <ControlBulkRowFailure>[];
    final indexesToRemove = <int>[];
    final editorId = _currentUserEmail;

    // Snapshot the current Champion/Owner assignments once, before any
    // row's create/assign runs, into a local mutable map this loop keeps
    // updated — championCubit.state/ownerCubit.state change away from
    // ChampionListLoaded/OwnerListLoaded after every createChampion/
    // updateChampion/createOwner/updateOwner call, so re-reading them
    // mid-loop would miss earlier rows' assignments to the same email.
    final championState = _championCubit.state;
    final championAssignments = <String, List<AssigningControlEntity>>{
      if (championState is ChampionListLoaded)
        for (final c in championState.champions)
          c.championEmail: List.of(c.assigningControls),
    };
    final ownerState = _ownerCubit.state;
    final ownerAssignments = <String, List<AssigningControlEntity>>{
      if (ownerState is OwnerListLoaded)
        for (final o in ownerState.owners) o.ownerEmail: List.of(o.assigningControls),
    };

    for (var i = 0; i < _rows.rows.length; i++) {
      final row = _rows.rows[i];
      final start = parsePolicyBulkDate(row.startDateController.text);
      final endText = row.endDateController.text.trim();
      final end = endText.isEmpty ? start : parsePolicyBulkDate(endText);
      final weight = double.tryParse(row.controlWeightController.text.trim());

      if (start == null || end == null || weight == null || row.resolvedFrequency == null) {
        failed.add(const ControlBulkRowFailure(reason: 'Invalid row data'));
        continue;
      }

      final result = await _createUseCase.call(
        CreateControlParams(
          moduleId: moduleId,
          policyId: policyId,
          editorId: editorId,
          controlsNameEn: row.controlNameEnController.text.trim(),
          controlsNameAr: row.controlNameArController.text.trim(),
          controlsNumberEn: row.controlNumberEnController.text.trim(),
          controlsNumberAr: row.controlNumberArController.text.trim(),
          controlsDescriptionEn: row.controlDescriptionEnController.text.trim(),
          controlsDescriptionAr: row.controlDescriptionArController.text.trim(),
          controlsWeight: weight,
          frequency: row.resolvedFrequency!,
          startDate: start,
          endDate: end,
          departments: row.departmentNames,
          // Always a list (never null) — ControlModel asserts
          // departmentWeights != null whenever equalWeights is false, even
          // when departments is empty, so an empty-departments row must
          // pass [] here, not null. row.departmentWeights already defaults
          // to [] when the row has no departments.
          departmentsWeights: row.departmentWeights,
          equalWeights: _equalWeights,
          score: 0,
          status: ControlStatus.active,
        ),
      );

      final control = result.fold((failure) {
        failed.add(ControlBulkRowFailure(reason: failure.message));
        return null;
      }, (created) => created);

      if (control == null) continue;

      for (final email in row.championEmails) {
        final pair = AssigningControlEntity(policyId: policyId, controlId: control.id);
        final existing = championAssignments[email];
        final updated = [...?existing, pair];
        championAssignments[email] = updated;
        if (existing != null) {
          await _championCubit.updateChampion(
            championEmail: email,
            moduleId: moduleId,
            assigningControls: updated,
          );
        } else {
          await _championCubit.createChampion(
            moduleId: moduleId,
            championEmail: email,
            assigningControls: updated,
          );
        }
      }

      for (final email in row.ownerEmails) {
        final pair = AssigningControlEntity(policyId: policyId, controlId: control.id);
        final existing = ownerAssignments[email];
        final updated = [...?existing, pair];
        ownerAssignments[email] = updated;
        if (existing != null) {
          await _ownerCubit.updateOwner(
            ownerEmail: email,
            moduleId: moduleId,
            assigningControls: updated,
          );
        } else {
          await _ownerCubit.createOwner(
            moduleId: moduleId,
            ownerEmail: email,
            assigningControls: updated,
          );
        }
      }

      succeededCount++;
      indexesToRemove.add(i);
    }

    indexesToRemove.sort((a, b) => b.compareTo(a));
    for (final index in indexesToRemove) {
      _rows.removeAt(index);
    }

    emit(ControlBulkUploadSubmitResult(succeededCount: succeededCount, failed: failed));
  }

  @override
  Future<void> close() {
    _rows.dispose();
    return super.close();
  }
}
