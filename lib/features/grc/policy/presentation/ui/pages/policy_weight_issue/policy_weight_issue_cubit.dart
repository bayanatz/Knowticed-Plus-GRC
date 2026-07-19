/// Module: Policy Management
/// Description: BLoC Cubit that manages the Policy Weight Issue page's
///              state: loading the Active/Scheduled policies (+ their
///              Controls count) that make up a module's weight total,
///              editing them (Equal Weight or by hand), and applying the
///              changed rows back through UpdatePolicyUseCase.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, GetAllPoliciesUseCase, GetAllControlsUseCase,
///               UpdatePolicyUseCase, PolicyWeightIssueRow/Rows
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/update_policy_usecase.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'policy_weight_issue_state.dart';

/// class name: [PolicyWeightIssueCubit]
///
/// purpose: manage all state for the Policy Weight Issue page: fetching the
///          Active+Scheduled policies for a module plus each one's Controls
///          count, editing their weights in memory, and persisting the
///          changed rows via [UpdatePolicyUseCase] on Apply Changes.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightIssueCubit extends Cubit<PolicyWeightIssueState> {
  PolicyWeightIssueCubit({
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required UpdatePolicyUseCase updatePolicyUseCase,
  })  : _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _updatePolicyUseCase = updatePolicyUseCase,
        super(PolicyWeightIssueInitial());

  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final UpdatePolicyUseCase _updatePolicyUseCase;

  PolicyWeightIssueRows? _rowsData;

  /// The current row/table data. Only valid once a
  /// [PolicyWeightIssueLoaded] state has been emitted at least once.
  PolicyWeightIssueRows get rowsData => _rowsData!;

  /// Whether [load] has ever completed successfully — false only before
  /// the very first load, or if that first load failed. Lets the page tell
  /// "failed before there was any data to show" apart from "failed midway
  /// through an edit session, but the table is still there."
  bool get hasRows => _rowsData != null;

  /// Resolves the currently logged-in user's email (same pattern as
  /// PolicyCubit._currentUserEmail).
  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  /// function name: [load]
  ///
  /// purpose: fetch every Active/Scheduled policy under [moduleId], resolve
  ///          each one's Controls count, and build fresh row data. Disposes
  ///          any previously held row data first.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<void>]
  Future<void> load(String moduleId) async {
    emit(PolicyWeightIssueLoading());

    final policiesResult = await _getAllPoliciesUseCase.call(moduleId: moduleId);
    final policies = policiesResult.fold((failure) {
      emit(PolicyWeightIssueFailure(failure.message));
      return null;
    }, (policies) => policies);
    if (policies == null) return;

    final scoped = policies
        .where((p) =>
            p.status == PolicyStatus.active || p.status == PolicyStatus.scheduled)
        .toList();

    final rows = <PolicyWeightIssueRow>[];
    for (final policy in scoped) {
      final controlsResult = await _getAllControlsUseCase.call(
        moduleId: moduleId,
        policyId: policy.id,
      );
      final noOfControls = controlsResult.fold((_) => 0, (controls) => controls.length);
      rows.add(PolicyWeightIssueRow.fromPolicy(policy, noOfControls: noOfControls));
    }

    _rowsData?.dispose();
    _rowsData = PolicyWeightIssueRows(rows);
    emit(PolicyWeightIssueLoaded(isEditing: false));
  }

  /// function name: [enterEditMode]
  ///
  /// purpose: switch the Policies Weight tab into edit mode (the "Edit"
  ///          button).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void enterEditMode() {
    emit(PolicyWeightIssueLoaded(isEditing: true));
  }

  /// function name: [discardChanges]
  ///
  /// purpose: revert every row and exit edit mode (the "Discard Changes"
  ///          button).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void discardChanges() {
    rowsData.discardChanges();
    emit(PolicyWeightIssueLoaded(isEditing: false));
  }

  /// function name: [applyEqualWeight]
  ///
  /// purpose: fill every row with an equal share of 100 (the "Equal Weight"
  ///          button). Stays in edit mode so the user can still hand-edit
  ///          afterward.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void applyEqualWeight() {
    rowsData.applyEqualWeight();
    emit(PolicyWeightIssueLoaded(isEditing: true));
  }

  /// function name: [revalidate]
  ///
  /// purpose: re-emit the current edit-mode state so the page rebuilds
  ///          (Total Weight box, Apply Changes enabled state) after a
  ///          hand-edited cell. Called from each cell's `onChanged`.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void revalidate() {
    emit(PolicyWeightIssueLoaded(isEditing: true));
  }

  /// function name: [applyChanges]
  ///
  /// purpose: persist every row whose weight actually changed via
  ///          [UpdatePolicyUseCase], one call per changed row. No-op if the
  ///          live total isn't exactly 100. On full success, reloads fresh
  ///          data and returns to view mode; on any failure, stops and
  ///          stays in edit mode so in-progress edits aren't lost.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<void>]
  Future<void> applyChanges(String moduleId) async {
    if (!rowsData.totalWeightValid) return;

    final changed = rowsData.changedRows;
    final editorId = _currentUserEmail;

    for (final row in changed) {
      final result = await _updatePolicyUseCase.call(
        UpdatePolicyParams(
          id: row.policyId,
          editorId: editorId,
          moduleId: moduleId,
          policyWeight: row.currentWeight,
        ),
      );
      final failureMessage = result.fold((failure) => failure.message, (_) => null);
      if (failureMessage != null) {
        // Emit Failure so the page's listener can show the error snackbar,
        // then immediately follow it with an editing Loaded state so the
        // builder keeps rendering the table in edit mode (rows/controllers
        // are untouched) instead of falling back to a bare error screen.
        emit(PolicyWeightIssueFailure(failureMessage));
        emit(PolicyWeightIssueLoaded(isEditing: true));
        return;
      }
    }

    emit(PolicyWeightIssueApplySuccess());
    await load(moduleId);
  }

  @override
  Future<void> close() {
    _rowsData?.dispose();
    return super.close();
  }
}
