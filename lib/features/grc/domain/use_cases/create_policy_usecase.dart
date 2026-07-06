/// Module: Policy Management
/// Description: Use case responsible for creating a new Policy record with
///              its initial Controls. Acts as the single entry point the
///              Presentation layer calls instead of the Repository directly.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, Failure, PolicyEntity, PolicyRepository
/// Revision History: 2026-07-5 - Initial creation
/// 
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';



/// ************************* FILE INFO *************************** ///
/// File Name: create_policy_usecase.dart
/// Purpose: Contains the CreatePolicyUseCase class and its Params.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [CreatePolicyParams]
///
/// purpose: groups every field needed to create a new Policy record
///          (including its initial Controls) into a single strongly-typed
///          object passed to [CreatePolicyUseCase].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class CreatePolicyParams {
  final String policyNameEn;
  final String policyNameAr;
  final String policyNumberEn;
  final String policyNumberAr;
  final String policyDescriptionEn;
  final String policyDescriptionAr;
  final DateTime startDate;
  final DateTime endDate;
  final double policyWeight;
  final String editorId;
  final List<CreateControlParams> controls;
  final PolicyStatus status;
  final File? imageFile;
  final String? imageUrl;
  final File? policyDocumentFile;
  final String? policyDocumentUrl;

  const CreatePolicyParams({
    required this.policyNameEn,
    required this.policyNameAr,
    required this.policyNumberEn,
    required this.policyNumberAr,
    required this.policyDescriptionEn,
    required this.policyDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.policyWeight,
    required this.editorId,
    required this.controls,
    required this.status,
    this.imageFile,
    this.imageUrl,
    this.policyDocumentFile,
    this.policyDocumentUrl,
  });
}

/// class name: [CreatePolicyUseCase]
///
/// purpose: encapsulate the "create a Policy" business action. The Bloc
///          calls this use case instead of [PolicyRepository] directly,
///          keeping the Presentation layer decoupled from the Data layer.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class CreatePolicyUseCase {
  const CreatePolicyUseCase(this._repository);

  final PolicyRepository _repository;

  /// function name: [call]
  ///
  /// purpose: forward the create request to [PolicyRepository.createPolicy].
  ///
  /// parameters:
  ///            [CreatePolicyParams] params: the data needed to create the new policy
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the created entity, or a Failure
  Future<Either<Failure, PolicyEntity>> call(CreatePolicyParams params) {
    return _repository.createPolicy(
      status: params.status,
      policyNameEn: params.policyNameEn,
      policyNameAr: params.policyNameAr,
      policyNumberEn: params.policyNumberEn,
      policyNumberAr: params.policyNumberAr,
      policyDescriptionEn: params.policyDescriptionEn,
      policyDescriptionAr: params.policyDescriptionAr,
      startDate: params.startDate,
      endDate: params.endDate,
      policyWeight: params.policyWeight,
      editorId: params.editorId,
      controls: params.controls,
      imageFile: params.imageFile,
      imageUrl: params.imageUrl,
      policyDocumentFile: params.policyDocumentFile,
      policyDocumentUrl: params.policyDocumentUrl,
    );
  }
}