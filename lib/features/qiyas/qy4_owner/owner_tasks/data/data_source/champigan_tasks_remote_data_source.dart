import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/app_services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';

/// ********************* FILE INFO *********************
/// File Name: champigan_tasks_remote_data_source.dart
/// Author: Mohamed Elrashidy
/// Created At: 8/5/2025

class OwnerTasksRemoteDataSource {
  Future<Either<Failure, dynamic>> getTasksStatus({
    required String criteriaNumber,
    required String evidenceNumber,
  }) async {
    return await FirebaseRepository
        .getDocumentsWithTwoConditionsSortedByOneFieldWithLimitOne(
      collectionName:
          getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
      fieldName1: EvidenceSubmissionModel.criteriaNumberKey,
      fieldValue1: criteriaNumber,
      fieldName2: EvidenceSubmissionModel.evidenceNumberKey,
      fieldValue2: evidenceNumber,
      sortFieldName: EvidenceSubmissionModel.submissionDateKey,
    );
  }

  Future<Either<FirebaseFailure, String>> uploadEvidenceDocument(
      String path, String collectionPath) async {
    return await FirebaseRepository.uploadFile(
      filePath: path,
      collectionName:
          getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
      documentName: path.split('/').last,
    );
  }

  Future<Either<FirebaseFailure, void>> uploadEvidenceSubmission(
      EvidenceSubmissionModel model) async {
    return await FirebaseRepository.setDocumentWithId(
      collection: getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
      documentId: model.submissionId,
      data: model.toMap(),
    );
  }

  Future<Either<FirebaseFailure, dynamic>> getTaskSubmssions(
      {required String criteriaNumber,
      required String evidenceNumber,
      required String champiganId}) async {
    debugPrint("criteriaNumber: $criteriaNumber");
    debugPrint("evidenceNumber: $evidenceNumber");
    debugPrint("champiganId: $champiganId");
    return await FirebaseRepository
        .getDocumentsWithThreeConditionsSortedByOneField(
            collectionName:
                getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
            fieldName1: EvidenceSubmissionModel.criteriaNumberKey,
            fieldValue1: criteriaNumber.trim(),
            fieldName2: EvidenceSubmissionModel.evidenceNumberKey,
            fieldValue2: evidenceNumber.trim(),
            fieldName3: EvidenceSubmissionModel.submittedByKey,
            fieldValue3: champiganId.toLowerCase(),
            sortFieldName: EvidenceSubmissionModel.submissionDateKey);
  }

  Future<Either<FirebaseFailure, void>> updateTaskStatus(
      {required String submissionId,
      required EvidenceSubmissionStatus status,
      String? rejectNotes,
      required String ownerId}) async {
    return await FirebaseRepository.setDocumentWithId(
        collection: getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
        data: {
          EvidenceSubmissionModel.approvedByKey: ownerId,
          EvidenceSubmissionModel.approvedDateKey: Timestamp.now(),
          EvidenceSubmissionModel.submissionStatusKey: status.name,
          EvidenceSubmissionModel.rejectionReasonKey: rejectNotes,
        },
        documentId: submissionId);
  }
}
