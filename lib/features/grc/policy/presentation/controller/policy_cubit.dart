/// Module: Policy Management
/// Description: BLoC Cubit that manages Policy and Control state for the
///              presentation layer. Delegates all operations to the
///              corresponding use cases and emits typed [PolicyState]
///              subclasses. Owns both Policy and Control operations (one
///              cubit for this feature) because the Create-Policy UI treats
///              "policy + its initial controls" as a single user action.
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
///                                fields into En/Ar, added standalone
///                                Control methods (createControl/
///                                updateControl/deleteControl/getAllControls)
library;

import 'dart:io';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';

import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/create_policy_usecase.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/update_policy_usecase.dart';
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
    required GetAllControlsUseCase getAllControlsUseCase,
  })  : _createUseCase = createPolicyUseCase,
        _getUseCase = getPolicyUseCase,
        _getAllUseCase = getAllPoliciesUseCase,
        _updateUseCase = updatePolicyUseCase,
        _deleteUseCase = deletePolicyUseCase,
        _restoreUseCase = restorePolicyUseCase,
        _createControlUseCase = createControlUseCase,
        _updateControlUseCase = updateControlUseCase,
        _deleteControlUseCase = deleteControlUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
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
  final GetAllControlsUseCase _getAllControlsUseCase;

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
            CreateControlParams(
              moduleId: moduleId,
              policyId: policy.id,
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
              controlsDocumentUrlEn: input.controlsDocumentUrlEn,
              controlsDocumentFileAr: input.controlsDocumentFileAr,
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

  // ================================================================
  // CONTROL (standalone — always against an existing Policy)
  // ================================================================

  Future<void> createControl({
    required String moduleId,
    required String policyId,
    required String controlsNameEn,
    required String controlsNameAr,
    required String controlsNumberEn,
    required String controlsNumberAr,
    required String controlsDescriptionEn,
    required String controlsDescriptionAr,
    required double controlsWeight,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> departments,
    required bool equalWeights,
    required int score,
    required ControlStatus status,
List<double>? departmentsWeights,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final result = await _createControlUseCase.call(
      CreateControlParams(
        moduleId: moduleId,
        policyId: policyId,
        editorId: _currentUserEmail,
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsWeight: controlsWeight,

        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        departments: departments,
        departmentsWeights: departmentsWeights,
        equalWeights: equalWeights,
        score: score,
        status: status,
        controlsDocumentFileEn: controlsDocumentFileEn,
        controlsDocumentUrlEn: controlsDocumentUrlEn,
        controlsDocumentFileAr: controlsDocumentFileAr,
        controlsDocumentUrlAr: controlsDocumentUrlAr,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (control) => emit(PolicyControlActionSuccess(control)),
    );
  }

  Future<void> updateControl({
    required String id,
    required String moduleId,
    required String policyId,
    String? controlsNameEn,
    String? controlsNameAr,
    String? controlsNumberEn,
    String? controlsNumberAr,
    String? controlsDescriptionEn,
    String? controlsDescriptionAr,
    double? controlsWeight,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? departments,
    bool? equalWeights,
    int? score,
    ControlStatus? status,
    List<double>? departmentsWeights,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final result = await _updateControlUseCase.call(
      UpdateControlParams(
        id: id,
        moduleId: moduleId,
        policyId: policyId,
        editorId: _currentUserEmail,
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsWeight: controlsWeight,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        
        departments: departments,
        departmentsWeights: departmentsWeights,
        equalWeights: equalWeights,
        score: score,
        status: status,
        controlsDocumentFileEn: controlsDocumentFileEn,
        controlsDocumentUrlEn: controlsDocumentUrlEn,
        controlsDocumentFileAr: controlsDocumentFileAr,
        controlsDocumentUrlAr: controlsDocumentUrlAr,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (control) => emit(PolicyControlActionSuccess(control)),
    );
  }

  Future<void> deleteControl({
    required String id,
    required String moduleId,
    required String policyId,
  }) async {
    emit(PolicyLoading());
    final result = await _deleteControlUseCase.call(
      DeleteControlParams(id: id, moduleId: moduleId, policyId: policyId),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (_) => emit(PolicyControlDeleted(id)),
    );
  }

  Future<void> getAllControls({
    required String moduleId,
    required String policyId,
  }) async {
    emit(PolicyLoading());
    final result = await _getAllControlsUseCase.call(
      moduleId: moduleId,
      policyId: policyId,
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (controls) => emit(PolicyControlsListLoaded(controls)),
    );
  }
}
