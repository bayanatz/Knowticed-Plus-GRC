/// Module: GRC Policy Bulk Upload
/// Description: BLoC Cubit driving the bulk upload preview table: owns the
///              editable [PolicyBulkUploadRows], forwards row-management
///              actions to it, and on submit calls the existing
///              [CreatePolicyUseCase] once per row, best-effort (one row's
///              failure doesn't stop the rest).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: flutter_bloc, get, CreatePolicyUseCase, PolicyBulkUploadRows
library;

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_policy_usecase.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_rows.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'policy_bulk_upload_state.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_upload_cubit.dart
/// Purpose: Contains PolicyBulkUploadCubit, the presentation-layer state
///          manager for the bulk upload preview table and its submit flow.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

/// class name: [PolicyBulkUploadCubit]
///
/// purpose: manage the bulk upload preview table's state and drive
///          best-effort creation of every valid row via [CreatePolicyUseCase].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkUploadCubit extends Cubit<PolicyBulkUploadState> {
  PolicyBulkUploadCubit({
    required CreatePolicyUseCase createPolicyUseCase,
    required List<PolicyBulkRow> parsedRows,
  })  : _createUseCase = createPolicyUseCase,
        _rows = PolicyBulkUploadRows(parsedRows),
        super(PolicyBulkUploadEditing());

  final CreatePolicyUseCase _createUseCase;
  final PolicyBulkUploadRows _rows;

  /// The editable row collection backing the preview table.
  PolicyBulkUploadRows get rowsData => _rows;

  /// Resolves the currently logged-in user's email (same lookup as [PolicyCubit]).
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
    emit(PolicyBulkUploadEditing());
  }

  void addRow() {
    _rows.addBlankRow();
    emit(PolicyBulkUploadEditing());
  }

  void removeSelectedRows() {
    _rows.removeSelected();
    emit(PolicyBulkUploadEditing());
  }

  void duplicateSelectedRow() {
    _rows.duplicateSelected();
    emit(PolicyBulkUploadEditing());
  }

  /// Re-runs validation for one row (called on every cell edit) and
  /// triggers a rebuild so the Error counter / Total Weight footer / row
  /// border stay in sync as the user types.
  void revalidateRow(int index) {
    _rows.rows[index].validate();
    emit(PolicyBulkUploadEditing());
  }

  /// function name: [submit]
  ///
  /// purpose: create every row as a real Policy via [CreatePolicyUseCase],
  ///          best-effort — one row's failure does not stop the others.
  ///          Rows that succeed are removed from [rowsData]; rows that fail
  ///          stay, in order, so [PolicyBulkUploadSubmitResult.failed] lines
  ///          up 1:1 with the remaining rows in [rowsData] afterward.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module every row is created under
  ///
  /// return type: [Future<void>]
  Future<void> submit({required String moduleId}) async {
    emit(PolicyBulkUploadSubmitting());

    var succeededCount = 0;
    final failed = <PolicyBulkRowFailure>[];
    final indexesToRemove = <int>[];
    final editorId = _currentUserEmail;

    for (var i = 0; i < _rows.rows.length; i++) {
      final row = _rows.rows[i];
      final start = parsePolicyBulkDate(row.startDateController.text);
      final endText = row.endDateController.text.trim();
      final end = endText.isEmpty ? start : parsePolicyBulkDate(endText);
      final weight = double.tryParse(row.policyWeightController.text.trim());

      if (start == null || end == null || weight == null) {
        failed.add(const PolicyBulkRowFailure(reason: 'Invalid row data'));
        continue;
      }

      final document = row.policyDocumentController.text.trim();
      final result = await _createUseCase.call(
        CreatePolicyParams(
          policyNameEn: row.policyNameEnController.text.trim(),
          policyNameAr: row.policyNameArController.text.trim(),
          policyNumberEn: row.policyNumberEnController.text.trim(),
          policyNumberAr: row.policyNumberArController.text.trim(),
          policyDescriptionEn: row.policyDescriptionEnController.text.trim(),
          policyDescriptionAr: row.policyDescriptionArController.text.trim(),
          startDate: start,
          endDate: end,
          policyWeight: weight,
          editorId: editorId,
          moduleId: moduleId,
          status: PolicyStatus.active,
          policyDocumentUrlAr: document.isEmpty ? null : document,
          policyDocumentUrlEn: document.isEmpty ? null : document,
        ),
      );

      result.fold(
        (failure) => failed.add(PolicyBulkRowFailure(reason: failure.message)),
        (_) {
          succeededCount++;
          indexesToRemove.add(i);
        },
      );
    }

    indexesToRemove.sort((a, b) => b.compareTo(a));
    for (final index in indexesToRemove) {
      _rows.removeAt(index);
    }

    emit(PolicyBulkUploadSubmitResult(
        succeededCount: succeededCount, failed: failed));
  }

  @override
  Future<void> close() {
    _rows.dispose();
    return super.close();
  }
}
