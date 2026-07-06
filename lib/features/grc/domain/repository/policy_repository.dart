/// Module: Policy Management
/// Description: Defines the Domain-layer repository contract for Policy
///              operations. The domain layer only knows about Entities and
///              Failures — no Firebase, no Models.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, Failure, PolicyEntity, ControlEntity
/// Revision History: 2026-07-5 - Initial creation

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';


/// ************************* FILE INFO *************************** ///
/// File Name: policy_repository.dart
/// Purpose: Contains the PolicyRepository abstract class (interface) that
///          the Data layer must implement and the Domain/Presentation layers
///          depend on.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyRepository]
///
/// purpose: define the contract for all Policy operations exposed to the
///          rest of the app. Uses Entities (not Models) and returns
///          [Either<Failure, T>] so callers handle success and failure
///          explicitly. Controls are managed as part of their parent Policy.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
abstract class PolicyRepository {
  // ================================================================
  // POLICY OPERATIONS
  // ================================================================

  /// function name: [createPolicy]
  ///
  /// purpose: create a new Policy record. Optionally uploads [imageFile]
  ///          and/or [policyDocumentFile] to Firebase Storage first and
  ///          uses their download URLs in the Firestore document.
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
  ///            [String] editorId: id of the user creating the policy
  ///            [List<CreateControlParams>] controls: initial controls to attach
  ///            [File] imageFile: local image file to upload, if any
  ///            [String] imageUrl: already-hosted image URL to use directly, if any
  ///            [File] policyDocumentFile: local document file to upload, if any
  ///            [String] policyDocumentUrl: already-hosted document URL to use directly, if any
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the created entity, or a Failure
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
    required List<CreateControlParams> controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
    required PolicyStatus status,
  });

  /// function name: [getPolicy]
  ///
  /// purpose: fetch a single Policy record by its id, mapped to its latest
  ///          Entity representation with all active Controls.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to fetch
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the matching entity, or a Failure
  Future<Either<Failure, PolicyEntity>> getPolicy(String id);

  /// function name: [getAllPolicies]
  ///
  /// purpose: fetch all Policy records mapped to their latest Entity
  ///          representation.
  ///
  /// parameters:
  ///            [bool] includeDeleted: when false (default), soft-deleted policies are excluded
  ///
  /// return type: [Future<Either<Failure, List<PolicyEntity>>>] - the list of entities, or a Failure
  Future<Either<Failure, List<PolicyEntity>>> getAllPolicies({
    bool includeDeleted = false,
  });

  /// function name: [updatePolicy]
  ///
  /// purpose: update an existing Policy record. Only non-null fields are
  ///          changed; everything else keeps its last value. Optionally
  ///          uploads new files to Storage before saving.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to update
  ///            [String] editorId: id of the user performing the update
  ///            [String] policyNameEn: new English policy name, if changed
  ///            [String] policyNameAr: new Arabic policy name, if changed
  ///            [String] policyNumberEn: new English policy number, if changed
  ///            [String] policyNumberAr: new Arabic policy number, if changed
  ///            [String] policyDescriptionEn: new English description, if changed
  ///            [String] policyDescriptionAr: new Arabic description, if changed
  ///            [DateTime] startDate: new start date, if changed
  ///            [DateTime] endDate: new end date, if changed
  ///            [double] policyWeight: new weight value, if changed
  ///            [List<CreateControlParams>] controls: new controls snapshot, if changed
  ///            [File] imageFile: new local image file to upload, if changed
  ///            [String] imageUrl: new already-hosted image URL, if changed
  ///            [File] policyDocumentFile: new local document file to upload, if changed
  ///            [String] policyDocumentUrl: new already-hosted document URL, if changed
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the updated entity, or a Failure
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
  });

  /// function name: [deletePolicy]
  ///
  /// purpose: soft-delete a Policy record (stays in the database, marked
  ///          as deleted) so it can be restored later.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to delete
  ///            [String] editorId: id of the user performing the delete
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the entity after the delete revision, or a Failure
  Future<Either<Failure, PolicyEntity>> deletePolicy({
    required String id,
    required String editorId,
  });

  /// function name: [restorePolicy]
  ///
  /// purpose: restore a previously soft-deleted Policy record.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to restore
  ///            [String] editorId: id of the user performing the restore
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the entity after the restore revision, or a Failure
  Future<Either<Failure, PolicyEntity>> restorePolicy({
    required String id,
    required String editorId,
  });
}

// ================================================================
// SHARED PARAMS
// ================================================================

/// class name: [CreateControlParams]
///
/// purpose: groups every field needed to create or snapshot a Control
///          within a Policy. Used both during Policy creation and when
///          updating the controls list on an existing Policy.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class CreateControlParams {
  final String controlsNameEn;
  final String controlsNameAr;
  final String controlsDescriptionEn;
  final String controlsDescriptionAr;
  final double controlsWeight;
  final String frequency;

  /// Optional file to upload to Storage — if provided, its download URL is
  /// stored in Controls_Document instead of [controlsDocumentUrl].
  final File? controlsDocumentFile;

  /// Already-hosted URL used directly when no [controlsDocumentFile] is given.
  final String? controlsDocumentUrl;

  const CreateControlParams({
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.controlsDescriptionEn,
    required this.controlsDescriptionAr,
    required this.controlsWeight,
    required this.frequency,
    this.controlsDocumentFile,
    this.controlsDocumentUrl,
  });
}