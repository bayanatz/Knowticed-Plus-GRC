/// ************************* FILE INFO ************************* ///
/// File Name: get_evidence_submissions.dart
/// Purpose: Defines a use case for retrieving evidence submissions for a control champion.
/// Author: Mohamed Elrashidy
/// Created At: 19/7/2025
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/base_repository/qiyas_champion_repo.dart';

class GetEvidenceSubmissions {
  QiyasChampionRepo repository;

  GetEvidenceSubmissions({required this.repository});

  Future<Either<Failure, dynamic>> execute(
      {required String criteriaNumber,
      required String evidenceNumber,
      required String championNumber}) async {
    var result = await repository.getEvidenceSubmissions(
        criteriaNumber: criteriaNumber,
        evidenceNumber: evidenceNumber,
        championId: championNumber);
    if (result.isLeft()) return result;
    List<EvidenceSubmissionModel> evidenceSubmissions =
        result.fold((_) => [], (r) => r);
    Map<EvidenceSubmissionStatus, List<EvidenceSubmissionModel>>
        groupedSubmissions = {};

    for (var status in EvidenceSubmissionStatus.values) {
      groupedSubmissions.putIfAbsent(status, () => []);
    }

    for (var submission in evidenceSubmissions) {
      groupedSubmissions[submission.submissionStatus]!.add(submission);
      groupedSubmissions[EvidenceSubmissionStatus.all]!.add(submission);
    }

    return result = Right(groupedSubmissions);
  }
}
