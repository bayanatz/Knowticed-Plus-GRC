/// Module: Policy Management
/// Description: Use case responsible for updating an existing Policy record.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, Failure, PolicyEntity, PolicyRepository
/// Revision History: 2026-07-5 - Initial creation

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';



/// ************************* FILE INFO *************************** ///
/// File Name: update_policy_usecase.dart
/// Purpose: Contains the UpdatePolicyUseCase class and its Params.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [UpdatePolicyParams]
///
/// purpose: groups every field that can be changed on an existing Policy
///          record into a single object. Fields left null are not changed
///          and keep their last value.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class UpdatePolicyParams {
  final String id;
  final String editorId;
  final String? policyNameEn;
  final String? policyNameAr;
  final String? policyNumberEn;
  final String? policyNumberAr;
  final String? policyDescriptionEn;
  final String? policyDescriptionAr;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? policyWeight;
  final List<CreateControlParams>? controls;
  final File? imageFile;
  final String? imageUrl;
  final File? policyDocumentFile;
  final String? policyDocumentUrl;

  const UpdatePolicyParams({
    required this.id,
    required this.editorId,
    this.policyNameEn,
    this.policyNameAr,
    this.policyNumberEn,
    this.policyNumberAr,
    this.policyDescriptionEn,
    this.policyDescriptionAr,
    this.startDate,
    this.endDate,
    this.policyWeight,
    this.controls,
    this.imageFile,
    this.imageUrl,
    this.policyDocumentFile,
    this.policyDocumentUrl,
  });
}

/// class name: [UpdatePolicyUseCase]
///
/// purpose: encapsulate the "update a Policy" business action. The Bloc
///          calls this use case instead of [PolicyRepository] directly.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class UpdatePolicyUseCase {
  const UpdatePolicyUseCase(this._repository);

  final PolicyRepository _repository;

  /// function name: [call]
  ///
  /// purpose: forward the update request to [PolicyRepository.updatePolicy].
  ///
  /// parameters:
  ///            [UpdatePolicyParams] params: the id and the fields to be updated
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the updated entity, or a Failure
  Future<Either<Failure, PolicyEntity>> call(UpdatePolicyParams params) {
    return _repository.updatePolicy(
      id: params.id,
      editorId: params.editorId,
      policyNameEn: params.policyNameEn,
      policyNameAr: params.policyNameAr,
      policyNumberEn: params.policyNumberEn,
      policyNumberAr: params.policyNumberAr,
      policyDescriptionEn: params.policyDescriptionEn,
      policyDescriptionAr: params.policyDescriptionAr,
      startDate: params.startDate,
      endDate: params.endDate,
      policyWeight: params.policyWeight,
      controls: params.controls,
      imageFile: params.imageFile,
      imageUrl: params.imageUrl,
      policyDocumentFile: params.policyDocumentFile,
      policyDocumentUrl: params.policyDocumentUrl,
    );
  }
}