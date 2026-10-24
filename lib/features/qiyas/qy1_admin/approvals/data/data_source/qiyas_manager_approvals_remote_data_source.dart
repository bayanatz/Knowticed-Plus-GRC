import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/app_services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';

class QiyasManagerApprovalsRemoteDataSource {
  Future<Either<FirebaseFailure, dynamic>> getChampionAssignedTasks() async {
    return await FirebaseRepository.getDocumentsWithOneFilter(
        collectionPath: getBaseUrl(kQiyasChampionNameCollection),
        filterKey: QiyasChampionModel.statusKey,
        filterValue: 'active');
  }

  Future<Either<Failure, dynamic>> getTaskStatus(
      {required String criteriaNumber, required String evidenceNumber}) async {
    return await FirebaseRepository
        .getDocumentsWithTwoConditionsSortedByOneFieldWithLimitOne(
            collectionName:
                getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
            fieldName1: EvidenceSubmissionModel.criteriaNumberKey,
            fieldValue1: criteriaNumber,
            fieldName2: EvidenceSubmissionModel.evidenceNumberKey,
            fieldValue2: evidenceNumber,
            sortFieldName: EvidenceSubmissionModel.submissionDateKey);
  }

  Future<Either<FirebaseFailure, dynamic>> getTaskSubmssions({
    required String criteriaNumber,
    required String evidenceNumber,
  }) async {
    return await FirebaseRepository
        .getDocumentsWithTwoConditionsSortedByOneField(
            collectionName:
                getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
            fieldName1: EvidenceSubmissionModel.criteriaNumberKey,
            fieldValue1: criteriaNumber,
            fieldName2: EvidenceSubmissionModel.evidenceNumberKey,
            fieldValue2: evidenceNumber,
            sortFieldName: EvidenceSubmissionModel.submissionDateKey);
  }

  Future<Either<FirebaseFailure, void>> updateTaskStatus(
      {required String submissionId,
      required EvidenceSubmissionStatus status,
      String? reason,
      required String currentUserId}) async {
    return await FirebaseRepository.setDocumentWithId(
        collection: getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
        data: {
          EvidenceSubmissionModel.submissionStatusKey: status.name,
          EvidenceSubmissionModel.managerIdKey: currentUserId,
          EvidenceSubmissionModel.rejectionReasonKey: reason,
          EvidenceSubmissionModel.managerResponseTimeKey: Timestamp.now(),
        },
        documentId: submissionId);
  }
}
