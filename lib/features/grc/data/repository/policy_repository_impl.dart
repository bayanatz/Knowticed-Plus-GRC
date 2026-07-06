/// Module: Policy Management
/// Description: Data-layer implementation of [PolicyRepository]. Combines
///              [PolicyFirebaseDataSource] (Firestore) and
///              [PolicyStorageDataSource] (Firebase Storage), and maps
///              between Models (persistence) and Entities (domain/UI).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, uuid, PolicyRepository, PolicyFirebaseDataSource,
///               PolicyStorageDataSource, PolicyModel, ControlModel
/// Revision History: 2026-07-5 - Initial creation
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/data/data_source/policy_firebase_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/policy_storage_data_source.dart';
import 'package:demo_app/features/grc/data/models/control_model.dart';
import 'package:demo_app/features/grc/data/models/policy_model.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';
import 'package:uuid/uuid.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_repository_impl.dart
/// Purpose: Contains the PolicyRepositoryImpl class, the concrete Data-layer
///          implementation of [PolicyRepository].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyRepositoryImpl]
///
/// purpose: implement [PolicyRepository] by orchestrating calls to the
///          Firestore data source (policy records) and the Storage data
///          source (images and documents), converting Models to Entities
///          before returning to the Domain/Presentation layers, and
///          wrapping every result in [Either<Failure, T>].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class PolicyRepositoryImpl implements PolicyRepository {
  PolicyRepositoryImpl({
    required PolicyFirebaseDataSource firebaseDataSource,
    required PolicyStorageDataSource storageDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _storageDataSource = storageDataSource;

  final PolicyFirebaseDataSource _firebaseDataSource;
  final PolicyStorageDataSource _storageDataSource;

  // ================================================================
  // CREATE
  // ================================================================

  /// function name: [createPolicy]
  ///
  /// purpose: generate a new id, upload any files to Storage, build
  ///          each Control as a [ControlModel] via [ControlModel.create],
  ///          build the first [PolicyModel] revision via
  ///          [PolicyModel.create], persist it, then return the mapped
  ///          [PolicyEntity].
  ///
  /// parameters: see [PolicyRepository.createPolicy]
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the created entity, or a [ServerFailure]
  @override
  Future<Either<Failure, PolicyEntity>> createPolicy({
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String editorId,
    required PolicyStatus status,
    required List<CreateControlParams> controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
  }) async {
    try {
      final policyId = const Uuid().v4();

      // -- upload policy-level files --
      final resolvedImage = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyImage(
          policyId: policyId,
          imageFile: imageFile!,
        ),
        file: imageFile,
        fallbackUrl: imageUrl,
      );

      final resolvedDocument = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: policyId,
          documentFile: policyDocumentFile!,
        ),
        file: policyDocumentFile,
        fallbackUrl: policyDocumentUrl,
      );

      // -- build each ControlModel (first revision per control) --
      final controlModels = await _buildControlModels(
        policyId: policyId,
        params: controls,
        editorId: editorId,
      );

      // -- build and persist the PolicyModel --
      final model = PolicyModel.create(
        id: policyId,
        image: resolvedImage ?? '',
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        policyDocument: resolvedDocument ?? '',
        controls: controlModels,
        editorId: editorId,
        status: status
      );

      final created = await _firebaseDataSource.create(model);
      return Right(created.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ================================================================
  // GET (single)
  // ================================================================

  /// function name: [getPolicy]
  ///
  /// purpose: fetch a Policy by id from Firestore and map it to its
  ///          latest [PolicyEntity] representation.
  ///
  /// parameters: see [PolicyRepository.getPolicy]
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the matching entity, a [NotFoundFailure], or a [ServerFailure]
  @override
  Future<Either<Failure, PolicyEntity>> getPolicy(String id) async {
    try {
      final model = await _firebaseDataSource.get(id);
      if (model == null) {
        return Left(ValidationError('Policy not found (id: $id)'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ================================================================
  // GET ALL
  // ================================================================

  /// function name: [getAllPolicies]
  ///
  /// purpose: fetch all Policies from Firestore and map each one to its
  ///          latest [PolicyEntity] representation.
  ///
  /// parameters: see [PolicyRepository.getAllPolicies]
  ///
  /// return type: [Future<Either<Failure, List<PolicyEntity>>>] - the list of entities, or a [ServerFailure]
  @override
  Future<Either<Failure, List<PolicyEntity>>> getAllPolicies({
    bool includeDeleted = false,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        includeDeleted: includeDeleted,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ================================================================
  // UPDATE
  // ================================================================

  /// function name: [updatePolicy]
  ///
  /// purpose: fetch the current PolicyModel, optionally upload new files
  ///          to Storage, rebuild the controls snapshot if controls changed,
  ///          append a new revision via [PolicyModel.copyWithUpdate], persist
  ///          it, then return the mapped [PolicyEntity].
  ///
  /// parameters: see [PolicyRepository.updatePolicy]
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the updated entity, a [NotFoundFailure], or a [ServerFailure]
  @override
  Future<Either<Failure, PolicyEntity>> updatePolicy({
    required String id,
    required String editorId,
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
    PolicyStatus? status,
  }) async {
    try {
      final currentModel = await _firebaseDataSource.get(id);
      if (currentModel == null) {
        return Left(ValidationError('Policy not found (id: $id)'));
      }

      // -- upload policy-level files if provided --
      final resolvedImage = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyImage(
          policyId: id,
          imageFile: imageFile!,
        ),
        file: imageFile,
        fallbackUrl: imageUrl,
      );

      final resolvedDocument = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: id,
          documentFile: policyDocumentFile!,
        ),
        file: policyDocumentFile,
        fallbackUrl: policyDocumentUrl,
      );

      // -- rebuild controls snapshot if controls changed --
      List<ControlModel>? controlModels;
      if (controls != null) {
        controlModels = await _buildControlModels(
          policyId: id,
          params: controls,
          editorId: editorId,
        );
      }

      final updatedModel = currentModel.copyWithUpdate(
        image: resolvedImage,
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        policyDocument: resolvedDocument,
        controls: controlModels,
        editorId: editorId,
      );

      final saved = await _firebaseDataSource.update(updatedModel);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ================================================================
  // DELETE  (soft)
  // ================================================================

  /// function name: [deletePolicy]
  ///
  /// purpose: soft-delete a Policy through the Firestore data source and
  ///          return the mapped [PolicyEntity].
  ///
  /// parameters: see [PolicyRepository.deletePolicy]
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the entity after the delete revision, or a [ServerFailure]
  @override
  Future<Either<Failure, PolicyEntity>> deletePolicy({
    required String id,
    required String editorId,
  }) async {
    try {
      final deleted = await _firebaseDataSource.delete(id, editorId: editorId);
      return Right(deleted.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ================================================================
  // RESTORE
  // ================================================================

  /// function name: [restorePolicy]
  ///
  /// purpose: restore a previously soft-deleted Policy through the
  ///          Firestore data source and return the mapped [PolicyEntity].
  ///
  /// parameters: see [PolicyRepository.restorePolicy]
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the entity after the restore revision, or a [ServerFailure]
  @override
  Future<Either<Failure, PolicyEntity>> restorePolicy({
    required String id,
    required String editorId,
  }) async {
    try {
      final restored =
          await _firebaseDataSource.restore(id, editorId: editorId);
      return Right(restored.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ================================================================
  // PRIVATE HELPERS
  // ================================================================

  /// function name: [_buildControlModels]
  ///
  /// purpose: convert a list of [CreateControlParams] into a list of
  ///          [ControlModel] instances (first revision each), uploading
  ///          any control document files to Storage along the way.
  ///
  /// parameters:
  ///            [String] policyId: id of the parent Policy (used for Storage path)
  ///            [List<CreateControlParams>] params: the control params to convert
  ///            [String] editorId: id of the user performing the action
  ///
  /// return type: [Future<List<ControlModel>>] - the list of built ControlModel instances
  Future<List<ControlModel>> _buildControlModels({
    required String policyId,
    required List<CreateControlParams> params,
    required String editorId,
  }) async {
    final controlModels = <ControlModel>[];

    for (final param in params) {
      final controlId = const Uuid().v4();

      final resolvedDocument = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadControlDocument(
          policyId: policyId,
          controlId: controlId,
          documentFile: param.controlsDocumentFile!,
        ),
        file: param.controlsDocumentFile,
        fallbackUrl: param.controlsDocumentUrl,
      );

      controlModels.add(
        ControlModel.create(
          id: controlId,
          controlsNameEn: param.controlsNameEn,
          controlsNameAr: param.controlsNameAr,
          controlsDescriptionEn: param.controlsDescriptionEn,
          controlsDescriptionAr: param.controlsDescriptionAr,
          controlsDocument: resolvedDocument ?? '',
          controlsWeight: param.controlsWeight,
          frequency: param.frequency,
          editorId: editorId,
        ),
      );
    }

    return controlModels;
  }

  /// function name: [_resolveFile]
  ///
  /// purpose: upload [file] to Storage via [uploadCallback] when provided
  ///          and return its download URL; otherwise fall back to
  ///          [fallbackUrl]; returns null when neither is provided (meaning
  ///          the field should stay unchanged on an update).
  ///
  /// parameters:
  ///            [Future<String> Function()] uploadCallback: the upload call to execute if [file] is not null
  ///            [File] file: local file to upload, if any
  ///            [String] fallbackUrl: already-hosted URL to use directly, if any
  ///
  /// return type: [Future<String?>] - the resolved URL, or null if nothing was provided
  Future<String?> _resolveFile({
    required Future<String> Function() uploadCallback,
    File? file,
    String? fallbackUrl,
  }) async {
    if (file != null) return uploadCallback();
    return fallbackUrl;
  }
}
