import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/late_unit_enum.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/base_repository/qiyas_champion_repo.dart';

import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';

class GetCriterieDocumentsStatusUseCase {
  QiyasChampionRepo repository;
  GetCriterieDocumentsStatusUseCase({required this.repository});
  Future<Either<Failure, dynamic>> execute(
      {required List<String> criteriaNumbers,
      required List<String> evidenceNumbers,
      required String championId,
      required List<DateTime> deadLines,
      required List<int> lateUnitMultiplier,
      required List<LateUnitEnum> lateUnit}) async {
    Either<Failure, dynamic> result;
    Map<EvidenceSubmissionStatus, List<EvidenceSubmissionModel>>
        evidenceStatusMap = {};
    for (var status in EvidenceSubmissionStatus.values) {
      evidenceStatusMap.putIfAbsent(status, () => []);
    }

    for (int index = 0; index < criteriaNumbers.length; index++) {
      String criteriaNumber = criteriaNumbers[index];
      String evidenceNumber = evidenceNumbers[index];
      result = await repository.getEvidenceStatus(
        criteriaNumber: criteriaNumber,
        evidenceNumber: evidenceNumber,
        championId: championId,
      );
      if (result.isLeft()) return result;
      EvidenceSubmissionModel? evidenceSubmissionModel =
          result.fold((_) => null, (r) => r);
      evidenceSubmissionModel ??= EvidenceSubmissionModel(
        criteriaNumber: criteriaNumber,
        evidenceNumber: evidenceNumber,
        submissionStatus: EvidenceSubmissionStatus.unCompleted,
        submittedBy: championId,
        submissionDate: Timestamp.now(),
        submissionId: '',
      );

      if (evidenceSubmissionModel.submissionStatus ==
              EvidenceSubmissionStatus.unCompleted ||
          evidenceSubmissionModel.submissionStatus ==
              EvidenceSubmissionStatus.rejected) {
        if (deadLines[index]
            .isBefore(DateTime.now().subtract(lateUnit[index].subtractValue(
          lateUnitMultiplier[index],
        )))) {
          evidenceSubmissionModel.submissionStatus =
              EvidenceSubmissionStatus.late;
        }
      }
      evidenceStatusMap[evidenceSubmissionModel.submissionStatus]!
          .add(evidenceSubmissionModel);
      evidenceStatusMap[EvidenceSubmissionStatus.all]!
          .add(evidenceSubmissionModel);
    }
    return result = Right(evidenceStatusMap);
  }
}
