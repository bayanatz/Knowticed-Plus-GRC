/// Module: Policy Management
/// Description: BLoC Cubit that manages Policy state for the presentation
///              layer. Delegates all operations to the corresponding use
///              cases and emits typed [PolicyState] subclasses.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-05
/// Dependencies: flutter_bloc, use cases, PolicyEntity, PolicyStatus
/// Revision History: 2026-07-05 - Initial creation
///                   2026-07-06 - Added saveAsDraft and status-aware methods
///                                (Mohamed Elrashidy)
library;

import 'dart:io';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_policy_usecase.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/grc/domain/use_cases/update_policy_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'policy_state.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_cubit.dart
/// Purpose: Contains the PolicyCubit class, the presentation-layer state
///          manager for all Policy CRUD operations.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyCubit]
///
/// purpose: manage all Policy UI state. Each public method maps to one
///          use case and follows the pattern: emit [PolicyLoading] → call
///          use case → emit success state or [PolicyFailure].
///
///          Status-aware methods:
///           - [createPolicy] → publishes with [PolicyStatus.active]
///           - [saveAsDraft]  → persists with [PolicyStatus.draft]
///           - [updatePolicy] → accepts an optional new status
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class PolicyCubit extends Cubit<PolicyState> {
  PolicyCubit({
    required CreatePolicyUseCase createPolicyUseCase,
    required GetPolicyUseCase getPolicyUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required UpdatePolicyUseCase updatePolicyUseCase,
    required DeletePolicyUseCase deletePolicyUseCase,
    required RestorePolicyUseCase restorePolicyUseCase,
  })  : _createUseCase = createPolicyUseCase,
        _getUseCase = getPolicyUseCase,
        _getAllUseCase = getAllPoliciesUseCase,
        _updateUseCase = updatePolicyUseCase,
        _deleteUseCase = deletePolicyUseCase,
        _restoreUseCase = restorePolicyUseCase,
        super(PolicyInitial());

  final CreatePolicyUseCase _createUseCase;
  final GetPolicyUseCase _getUseCase;
  final GetAllPoliciesUseCase _getAllUseCase;
  final UpdatePolicyUseCase _updateUseCase;
  final DeletePolicyUseCase _deleteUseCase;
  final RestorePolicyUseCase _restoreUseCase;

  /// Resolves the currently logged-in user's id.
  String get _currentUserId {
    final fromConstant = Constant.idUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final id = Get.find<MainCoreEmployeeController>().employeeEntity?.id;
      if (id != null && id.isNotEmpty) return id;
    }
    return '';
  }

  // ================================================================
  // GET ALL
  // ================================================================

  /// function name: [getAllPolicies]
  ///
  /// purpose: fetch all Policy records and emit [PolicyListLoaded] on
  ///          success or [PolicyFailure] on failure.
  ///
  /// parameters:
  ///            [bool] includeDeleted: include soft-deleted policies (default: false)
  ///
  /// return type: [Future<void>]
  Future<void> getAllPolicies({bool includeDeleted = false}) async {
    emit(PolicyLoading());
    final result = await _getAllUseCase.call(includeDeleted: includeDeleted);
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policies) => emit(PolicyListLoaded(policies)),
    );
  }

  // ================================================================
  // GET SINGLE
  // ================================================================

  /// function name: [getPolicy]
  ///
  /// purpose: fetch a single Policy by [id] and emit [PolicySingleLoaded]
  ///          on success or [PolicyFailure] on failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to fetch
  ///
  /// return type: [Future<void>]
  Future<void> getPolicy(String id) async {
    emit(PolicyLoading());
    final result = await _getUseCase.call(id);
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicySingleLoaded(policy)),
    );
  }

  // ================================================================
  // CREATE  (Active / Publish)
  // ================================================================

  /// function name: [createPolicy]
  ///
  /// purpose: create a new Policy with [PolicyStatus.active] (Publish).
  ///          Emits [PolicyActionSuccess] on success or [PolicyFailure]
  ///          on failure.
  ///
  /// parameters:
  ///            [String] policyNameEn: English policy name
  ///            [String] policyNameAr: Arabic policy name
  ///            [String] policyNumberEn: English policy number
  ///            [String] policyNumberAr: Arabic policy number
  ///            [String] policyDescriptionEn: English description
  ///            [String] policyDescriptionAr: Arabic description
  ///            [DateTime] startDate: policy start date
  ///            [DateTime] endDate: policy end date
  ///            [double] policyWeight: policy weight value
  ///            [List<CreateControlParams>] controls: initial controls to attach
  ///            [File] imageFile: local image file to upload, if any
  ///            [String] imageUrl: already-hosted image URL, if any
  ///            [File] policyDocumentFile: local document file to upload, if any
  ///            [String] policyDocumentUrl: already-hosted document URL, if any
  ///
  /// return type: [Future<void>]
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
    required List<CreateControlParams> controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
  }) async {
    emit(PolicyLoading());
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
        editorId: _currentUserId,
        controls: controls,
        status: PolicyStatus.active, // Publish = Active
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFile: policyDocumentFile,
        policyDocumentUrl: policyDocumentUrl,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }

  // ================================================================
  // SAVE AS DRAFT
  // ================================================================

  /// function name: [saveAsDraft]
  ///
  /// purpose: create a new Policy with [PolicyStatus.draft] (Save For Later).
  ///          Controls may be empty or partially filled.
  ///          Emits [PolicyActionSuccess] on success or [PolicyFailure]
  ///          on failure.
  ///
  /// parameters:
  ///            [String] policyNameEn: English policy name
  ///            [String] policyNameAr: Arabic policy name
  ///            [String] policyNumberEn: English policy number
  ///            [String] policyNumberAr: Arabic policy number
  ///            [String] policyDescriptionEn: English description
  ///            [String] policyDescriptionAr: Arabic description
  ///            [DateTime] startDate: policy start date
  ///            [DateTime] endDate: policy end date
  ///            [double] policyWeight: policy weight value
  ///            [List<CreateControlParams>] controls: controls snapshot (can be empty)
  ///            [File] imageFile: local image file to upload, if any
  ///            [String] imageUrl: already-hosted image URL, if any
  ///            [File] policyDocumentFile: local document file to upload, if any
  ///            [String] policyDocumentUrl: already-hosted document URL, if any
  ///
  /// return type: [Future<void>]
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
    required List<CreateControlParams> controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
  }) async {
    emit(PolicyLoading());
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
        editorId: _currentUserId,
        controls: controls,
        status: PolicyStatus.draft, // Save For Later = Draft
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFile: policyDocumentFile,
        policyDocumentUrl: policyDocumentUrl,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }

  // ================================================================
  // UPDATE
  // ================================================================

  /// function name: [updatePolicy]
  ///
  /// purpose: update an existing Policy. Accepts an optional [status] to
  ///          change the lifecycle (e.g. Active → Inactive).
  ///          Emits [PolicyActionSuccess] on success or [PolicyFailure]
  ///          on failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to update
  ///            [PolicyStatus] status: new lifecycle status, if changed
  ///            [String] policyNameEn: new English name, if changed
  ///            [String] policyNameAr: new Arabic name, if changed
  ///            [String] policyNumberEn: new English number, if changed
  ///            [String] policyNumberAr: new Arabic number, if changed
  ///            [String] policyDescriptionEn: new English description, if changed
  ///            [String] policyDescriptionAr: new Arabic description, if changed
  ///            [DateTime] startDate: new start date, if changed
  ///            [DateTime] endDate: new end date, if changed
  ///            [double] policyWeight: new weight, if changed
  ///            [List<CreateControlParams>] controls: new controls snapshot, if changed
  ///            [File] imageFile: new local image file to upload, if changed
  ///            [String] imageUrl: new already-hosted image URL, if changed
  ///            [File] policyDocumentFile: new local document file, if changed
  ///            [String] policyDocumentUrl: new already-hosted document URL, if changed
  ///
  /// return type: [Future<void>]
  Future<void> updatePolicy({
    required String id,
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
    List<CreateControlParams>? controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
  }) async {
    emit(PolicyLoading());
    final result = await _updateUseCase.call(
      UpdatePolicyParams(
        id: id,
        editorId: _currentUserId,
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
        controls: controls,
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFile: policyDocumentFile,
        policyDocumentUrl: policyDocumentUrl,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }

  // ================================================================
  // DELETE  (soft)
  // ================================================================

  /// function name: [deletePolicy]
  ///
  /// purpose: soft-delete a Policy and emit [PolicyActionSuccess] on
  ///          success or [PolicyFailure] on failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to delete
  ///
  /// return type: [Future<void>]
  Future<void> deletePolicy({required String id}) async {
    emit(PolicyLoading());
    final result = await _deleteUseCase.call(
      DeletePolicyParams(id: id, editorId: _currentUserId),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }

  // ================================================================
  // RESTORE
  // ================================================================

  /// function name: [restorePolicy]
  ///
  /// purpose: restore a soft-deleted Policy and emit [PolicyActionSuccess]
  ///          on success or [PolicyFailure] on failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to restore
  ///
  /// return type: [Future<void>]
  Future<void> restorePolicy({required String id}) async {
    emit(PolicyLoading());
    final result = await _restoreUseCase.call(
      RestorePolicyParams(id: id, editorId: _currentUserId),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }
}