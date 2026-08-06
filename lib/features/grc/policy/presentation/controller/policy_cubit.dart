/// Module: Policy Management
/// Description: BLoC Cubit that manages Policy state for the presentation
///              layer. Delegates all operations to the corresponding use
///              cases and emits typed [PolicyState] subclasses. Still holds
///              a direct dependency on CreateControlUseCase/
///              UpdateControlUseCase/DeleteControlUseCase for
///              createPolicy/saveAsDraft/updatePolicyWithControls, which
///              treat "Policy + its bundled initial Controls" as one wizard
///              action — that's a Policy-workflow concern, not Control
///              state, so it stays here rather than moving to ControlCubit
///              (see docs/superpowers/specs/2026-07-28-control-cubit-extraction-design.md).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-05
/// Dependencies: flutter_bloc, use cases, PolicyEntity, ControlEntity
/// Revision History: 2026-07-05 - Initial creation
///                   2026-07-06 - Added saveAsDraft and status-aware methods
///                   2026-07-14 - Reworked for the new schema: Policy
///                                creation no longer bundles Controls at the
///                                repository level (see
///                                _createPolicyWithControls for the
///                                orchestration), split single document
///                                fields into En/Ar
///                   2026-07-28 - Extracted the standalone Control methods
///                                (createControl/updateControl/
///                                deleteControl/getAllControls) and the
///                                two ControlStatus business-rule helpers
///                                into ControlCubit/ControlStatus
library;

import 'dart:io';

import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/grc/control/domain/entities/control_entity.dart';
import 'package:grc_module/features/grc/control/domain/entities/control_status.dart';

import 'package:grc_module/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:grc_module/features/grc/policy/domain/entities/policy_status.dart';
import 'package:grc_module/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:grc_module/features/grc/policy/domain/use_cases/create_policy_usecase.dart';
import 'package:grc_module/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:grc_module/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:grc_module/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:grc_module/features/grc/policy/domain/use_cases/update_policy_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'policy_state.dart';

/// class name: [PendingControlInput]
///
/// purpose: groups the fields needed to create one Control alongside a new
///          Policy, before that Policy's id exists yet.
///          [PolicyCubit.createPolicy]/[PolicyCubit.saveAsDraft] resolve
///          moduleId/policyId/editorId for each of these once the Policy
///          itself has been created, then forward the rest to
///          [CreateControlUseCase].
class PendingControlInput {
  final String controlsNameEn;
  final String controlsNameAr;
  final String controlsNumberEn;
  final String controlsNumberAr;
  final String controlsDescriptionEn;
  final String controlsDescriptionAr;
  final double controlsWeight;
  final String frequency;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> departments;
  final bool equalWeights;
  final int score;
  final ControlStatus status;
  final File? controlsDocumentFileEn;
  final String? controlsDocumentUrlEn;
  final File? controlsDocumentFileAr;
  final String? controlsDocumentUrlAr;

  /// Non-null when this input represents a Control that already exists in
  /// Firestore — [PolicyCubit.updatePolicyWithControls] updates it in place
  /// via this id instead of creating a duplicate.
  final String? existingControlId;

  const PendingControlInput({
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.controlsNumberEn,
    required this.controlsNumberAr,
    required this.controlsDescriptionEn,
    required this.controlsDescriptionAr,
    required this.controlsWeight,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.departments,
    required this.equalWeights,
    required this.score,
    required this.status,
    this.controlsDocumentFileEn,
    this.controlsDocumentUrlEn,
    this.controlsDocumentFileAr,
    this.controlsDocumentUrlAr,
    this.existingControlId,
  });
}

/// class name: [PolicyCubit]
///
/// purpose: manage all Policy and Control UI state. Each public method maps
///          to one use case (or, for [createPolicy]/[saveAsDraft], two —
///          Policy then Controls) and follows the pattern: emit
///          [PolicyLoading] → call use case(s) → emit a success state or
///          [PolicyFailure].
class PolicyCubit extends Cubit<PolicyState> {
  PolicyCubit({
    required CreatePolicyUseCase createPolicyUseCase,
    required GetPolicyUseCase getPolicyUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required UpdatePolicyUseCase updatePolicyUseCase,
    required DeletePolicyUseCase deletePolicyUseCase,
    required RestorePolicyUseCase restorePolicyUseCase,
    required CreateControlUseCase createControlUseCase,
    required UpdateControlUseCase updateControlUseCase,
    required DeleteControlUseCase deleteControlUseCase,
  })  : _createUseCase = createPolicyUseCase,
        _getUseCase = getPolicyUseCase,
        _getAllUseCase = getAllPoliciesUseCase,
        _updateUseCase = updatePolicyUseCase,
        _deleteUseCase = deletePolicyUseCase,
        _restoreUseCase = restorePolicyUseCase,
        _createControlUseCase = createControlUseCase,
        _updateControlUseCase = updateControlUseCase,
        _deleteControlUseCase = deleteControlUseCase,
        super(PolicyInitial());

  final CreatePolicyUseCase _createUseCase;
  final GetPolicyUseCase _getUseCase;
  final GetAllPoliciesUseCase _getAllUseCase;
  final UpdatePolicyUseCase _updateUseCase;
  final DeletePolicyUseCase _deleteUseCase;
  final RestorePolicyUseCase _restoreUseCase;
  final CreateControlUseCase _createControlUseCase;
  final UpdateControlUseCase _updateControlUseCase;
  final DeleteControlUseCase _deleteControlUseCase;

  /// Resolves the currently logged-in user's email.
  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  // ================================================================
  // GET ALL / GET SINGLE
  // ================================================================

  Future<void> getAllPolicies({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    emit(PolicyLoading());
    final result = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policies) => emit(PolicyListLoaded(policies)),
    );
  }

  Future<void> getPolicy(String id, {required String moduleId}) async {
    emit(PolicyLoading());
    final result = await _getUseCase.call(id, moduleId: moduleId);
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicySingleLoaded(policy)),
    );
  }

  // ================================================================
  // CREATE (Active / Publish) and SAVE AS DRAFT
  // ================================================================

  /// function name: [createPolicy]
  ///
  /// purpose: create a new Policy with [PolicyStatus.active] (Publish),
  ///          then create every [controls] entry against the new Policy's
  ///          id. See [_createPolicyWithControls] for state semantics.
  Future<void> createPolicy({
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String moduleId,
    List<PendingControlInput> controls = const [],
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    await _createPolicyWithControls(
      status: PolicyStatus.active, // Publish = Active
      policyNameEn: policyNameEn,
      policyNameAr: policyNameAr,
      policyNumberEn: policyNumberEn,
      policyNumberAr: policyNumberAr,
      policyDescriptionEn: policyDescriptionEn,
      policyDescriptionAr: policyDescriptionAr,
      startDate: startDate,
      endDate: endDate,
      policyWeight: policyWeight,
      moduleId: moduleId,
      controls: controls,
      imageFile: imageFile,
      imageUrl: imageUrl,
      policyDocumentFileEn: policyDocumentFileEn,
      policyDocumentUrlEn: policyDocumentUrlEn,
      policyDocumentFileAr: policyDocumentFileAr,
      policyDocumentUrlAr: policyDocumentUrlAr,
    );
  }

  /// function name: [saveAsDraft]
  ///
  /// purpose: create a new Policy with [PolicyStatus.draft] (Save For
  ///          Later), then create every [controls] entry (may be empty).
  Future<void> saveAsDraft({
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String moduleId,
    List<PendingControlInput> controls = const [],
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    await _createPolicyWithControls(
      status: PolicyStatus.draft, // Save For Later = Draft
      policyNameEn: policyNameEn,
      policyNameAr: policyNameAr,
      policyNumberEn: policyNumberEn,
      policyNumberAr: policyNumberAr,
      policyDescriptionEn: policyDescriptionEn,
      policyDescriptionAr: policyDescriptionAr,
      startDate: startDate,
      endDate: endDate,
      policyWeight: policyWeight,
      moduleId: moduleId,
      controls: controls,
      imageFile: imageFile,
      imageUrl: imageUrl,
      policyDocumentFileEn: policyDocumentFileEn,
      policyDocumentUrlEn: policyDocumentUrlEn,
      policyDocumentFileAr: policyDocumentFileAr,
      policyDocumentUrlAr: policyDocumentUrlAr,
    );
  }

  /// function name: [_createPolicyWithControls]
  ///
  /// purpose: shared orchestration for [createPolicy]/[saveAsDraft]. Creates
  ///          the Policy first (repository/use-case layer knows nothing
  ///          about Controls); if that fails, emits [PolicyFailure] and
  ///          stops — no Control is ever attempted without a persisted
  ///          Policy. On Policy success, creates every [controls] entry
  ///          against the new `policy.id`, collecting failures instead of
  ///          throwing, then emits [PolicyActionSuccess] if all controls
  ///          succeeded (or there were none) or
  ///          [PolicyActionPartialSuccess] if some failed.
  Future<void> _createPolicyWithControls({
    required PolicyStatus status,
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String moduleId,
    required List<PendingControlInput> controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final editorId = _currentUserEmail;
    final result = await _createUseCase.call(
      CreatePolicyParams(
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        editorId: editorId,
        moduleId: moduleId,
        status: status,
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFileEn: policyDocumentFileEn,
        policyDocumentUrlEn: policyDocumentUrlEn,
        policyDocumentFileAr: policyDocumentFileAr,
        policyDocumentUrlAr: policyDocumentUrlAr,
      ),
    );

    await result.fold(
      (failure) async => emit(PolicyFailure(failure.message)),
      (policy) async {
        if (controls.isEmpty) {
          emit(PolicyActionSuccess(policy));
          return;
        }

        final failedControls = <({PendingControlInput input, String message})>[];
        for (final input in controls) {
          final controlResult = await _createControlUseCase.call(
            _buildCreateControlParams(
              moduleId: moduleId,
              policyId: policy.id,
              editorId: editorId,
              input: input,
              controlsDocumentUrlEn: input.controlsDocumentUrlEn,
              controlsDocumentUrlAr: input.controlsDocumentUrlAr,
            ),
          );
          controlResult.fold(
            (failure) =>
                failedControls.add((input: input, message: failure.message)),
            (_) {},
          );
        }

        if (failedControls.isEmpty) {
          emit(PolicyActionSuccess(policy));
        } else {
          emit(PolicyActionPartialSuccess(policy, failedControls));
        }
      },
    );
  }

  // ================================================================
  // UPDATE / DELETE / RESTORE (Policy)
  // ================================================================

  Future<void> updatePolicy({
    required String id,
    required String moduleId,
    PolicyStatus? status,
    String? policyNameEn,
    String? policyNameAr,
    String? policyNumberEn,
    String? policyNumberAr,
    String? policyDescriptionEn,
    String? policyDescriptionAr,
    DateTime? startDate,
    DateTime? endDate,
    double? policyWeight,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final result = await _updateUseCase.call(
      UpdatePolicyParams(
        id: id,
        editorId: _currentUserEmail,
        moduleId: moduleId,
        status: status,
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFileEn: policyDocumentFileEn,
        policyDocumentUrlEn: policyDocumentUrlEn,
        policyDocumentFileAr: policyDocumentFileAr,
        policyDocumentUrlAr: policyDocumentUrlAr,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }

  /// function name: [updatePolicyWithControls]
  ///
  /// purpose: update an existing Policy (used when resuming a Draft from
  ///          the Create New Policy wizard) and reconcile its Controls in
  ///          the same call: [removedControlIds] are deleted, each
  ///          [controls] entry with an [PendingControlInput.existingControlId]
  ///          is updated in place, and each without one is created fresh.
  ///          Mirrors [_createPolicyWithControls]'s one-Loading/one-final-
  ///          state contract.
  ///
  /// parameters:
  ///            [String] id: the existing Policy's id
  ///            [String] moduleId: the parent GRC Module's id
  ///            [PolicyStatus] status: [PolicyStatus.draft] for Save For
  ///            Later, [PolicyStatus.active] for Publish
  ///            [List<PendingControlInput>] controls: every touched control
  ///            card from the wizard (existing or new)
  ///            [List<String>] removedControlIds: ids of previously-saved
  ///            controls no longer present/touched in the wizard
  ///
  /// return type: [Future<void>]
  Future<void> updatePolicyWithControls({
    required String id,
    required String moduleId,
    required PolicyStatus status,
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required List<PendingControlInput> controls,
    required List<String> removedControlIds,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final editorId = _currentUserEmail;

    final result = await _updateUseCase.call(UpdatePolicyParams(
      id: id,
      editorId: editorId,
      moduleId: moduleId,
      status: status,
      policyNameEn: policyNameEn,
      policyNameAr: policyNameAr,
      policyNumberEn: policyNumberEn,
      policyNumberAr: policyNumberAr,
      policyDescriptionEn: policyDescriptionEn,
      policyDescriptionAr: policyDescriptionAr,
      startDate: startDate,
      endDate: endDate,
      policyWeight: policyWeight,
      imageFile: imageFile,
      imageUrl: imageUrl,
      policyDocumentFileEn: policyDocumentFileEn,
      policyDocumentUrlEn: policyDocumentUrlEn,
      policyDocumentFileAr: policyDocumentFileAr,
      policyDocumentUrlAr: policyDocumentUrlAr,
    ));

    await result.fold(
      (failure) async => emit(PolicyFailure(failure.message)),
      (policy) async {
        for (final controlId in removedControlIds) {
          final deleteResult = await _deleteControlUseCase.call(
            DeleteControlParams(id: controlId, moduleId: moduleId, policyId: id),
          );
          if (deleteResult.isLeft()) {
            emit(PolicyFailure(
              deleteResult.fold((failure) => failure.message, (_) => ''),
            ));
            return;
          }
        }

        final failedControls =
            <({PendingControlInput input, String message})>[];
        for (final input in controls) {
          final controlResult = await _upsertControlForUpdate(
            input: input,
            moduleId: moduleId,
            policyId: id,
            editorId: editorId,
          );
          controlResult.fold(
            (failure) =>
                failedControls.add((input: input, message: failure.message)),
            (_) {},
          );
        }

        if (failedControls.isEmpty) {
          emit(PolicyActionSuccess(policy));
        } else {
          emit(PolicyActionPartialSuccess(policy, failedControls));
        }
      },
    );
  }

  /// function name: [_buildCreateControlParams]
  ///
  /// purpose: shared builder for the [CreateControlParams] assembled from a
  ///          [PendingControlInput] in both [_createPolicyWithControls] and
  ///          [updatePolicyWithControls]. Faithful DRY extraction of the two
  ///          previously copy-pasted field-mapping blocks: every control field
  ///          is taken from [input]; the ids ([moduleId]/[policyId]/[editorId])
  ///          and the two document URLs vary per call site and so are passed
  ///          in. The create-during-update path passes no URLs, preserving its
  ///          original behavior of leaving them null.
  CreateControlParams _buildCreateControlParams({
    required String moduleId,
    required String policyId,
    required String editorId,
    required PendingControlInput input,
    String? controlsDocumentUrlEn,
    String? controlsDocumentUrlAr,
  }) {
    return CreateControlParams(
      moduleId: moduleId,
      policyId: policyId,
      editorId: editorId,
      controlsNameEn: input.controlsNameEn,
      controlsNameAr: input.controlsNameAr,
      controlsNumberEn: input.controlsNumberEn,
      controlsNumberAr: input.controlsNumberAr,
      controlsDescriptionEn: input.controlsDescriptionEn,
      controlsDescriptionAr: input.controlsDescriptionAr,
      controlsWeight: input.controlsWeight,
      frequency: input.frequency,
      startDate: input.startDate,
      endDate: input.endDate,
      departments: input.departments,
      equalWeights: input.equalWeights,
      score: input.score,
      status: input.status,
      controlsDocumentFileEn: input.controlsDocumentFileEn,
      controlsDocumentUrlEn: controlsDocumentUrlEn,
      controlsDocumentFileAr: input.controlsDocumentFileAr,
      controlsDocumentUrlAr: controlsDocumentUrlAr,
    );
  }

  /// function name: [_upsertControlForUpdate]
  ///
  /// purpose: per-control decision for [updatePolicyWithControls] — update the
  ///          control in place when [PendingControlInput.existingControlId] is
  ///          set, otherwise create it fresh. Extracted from the loop's inline
  ///          ternary to reduce nesting; behavior is unchanged (the update
  ///          branch still omits departments/equalWeights/score/URLs and the
  ///          create branch still passes no document URLs).
  Future<Either<Failure, ControlEntity>> _upsertControlForUpdate({
    required PendingControlInput input,
    required String moduleId,
    required String policyId,
    required String editorId,
  }) {
    if (input.existingControlId != null) {
      return _updateControlUseCase.call(UpdateControlParams(
        id: input.existingControlId!,
        moduleId: moduleId,
        policyId: policyId,
        editorId: editorId,
        controlsNameEn: input.controlsNameEn,
        controlsNameAr: input.controlsNameAr,
        controlsNumberEn: input.controlsNumberEn,
        controlsNumberAr: input.controlsNumberAr,
        controlsDescriptionEn: input.controlsDescriptionEn,
        controlsDescriptionAr: input.controlsDescriptionAr,
        controlsWeight: input.controlsWeight,
        frequency: input.frequency,
        startDate: input.startDate,
        endDate: input.endDate,
        status: input.status,
        controlsDocumentFileEn: input.controlsDocumentFileEn,
        controlsDocumentFileAr: input.controlsDocumentFileAr,
      ));
    }
    return _createControlUseCase.call(_buildCreateControlParams(
      moduleId: moduleId,
      policyId: policyId,
      editorId: editorId,
      input: input,
    ));
  }

  Future<void> deletePolicy({
    required String id,
    required String moduleId,
  }) async {
    emit(PolicyLoading());
    final result = await _deleteUseCase.call(
      DeletePolicyParams(id: id, editorId: _currentUserEmail, moduleId: moduleId),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }

  Future<void> restorePolicy({
    required String id,
    required String moduleId,
  }) async {
    emit(PolicyLoading());
    final result = await _restoreUseCase.call(
      RestorePolicyParams(id: id, editorId: _currentUserEmail, moduleId: moduleId),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }

}
