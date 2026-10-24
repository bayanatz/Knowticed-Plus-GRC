import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/data/data_source/qiyas_manager_approvals_remote_data_source.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';

import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';

class QiyasManagerApprovalsRepository {
  QiyasManagerApprovalsRemoteDataSource qiyasManagerApprovalsRemoteDataSource =
      QiyasManagerApprovalsRemoteDataSource();

  Future<Either<Failure, dynamic>> getChampionAssignedTasks() async {
    var result =
        await qiyasManagerApprovalsRemoteDataSource.getChampionAssignedTasks();
    if (result.isLeft()) return result;
    List<Map<String, dynamic>> data = result.fold((_) => [], (r) => r);
    return result = Right(data
        .map((e) => QiyasChampionEntity.qiyasChampionFireBasetoEntity(
            QiyasChampionModel.fromMap(e)))
        .toList());
  }

  Future<Either<Failure, dynamic>> getLastEvidenceStatus(
      {required List<String> criteriaNumbers,
      required List<String> evidenceNumbers}) async {
    List<Future<Either<Failure, dynamic>>> results = [];
    debugPrint("criteriaNumbers: $criteriaNumbers");
    for (int i = 0; i < criteriaNumbers.length; i++) {
      results.add(qiyasManagerApprovalsRemoteDataSource.getTaskStatus(
        criteriaNumber: criteriaNumbers[i].trim(),
        evidenceNumber: evidenceNumbers[i].trim(),
      ));
    }
    List<Either<Failure, dynamic>> response = await Future.wait(results);
    List<EvidenceSubmissionModel?> evidenceSubmissions = [];
    debugPrint("length of response: ${response.length}");
    for (var res in response) {
      if (res.isLeft()) return res;
      List<Map<String, dynamic>>? data = res.fold((_) => null, (r) => r);
      if (data == null || data.isEmpty) {
        evidenceSubmissions.add(null);
      } else {
        evidenceSubmissions.add(EvidenceSubmissionModel.fromMap(data.first));
      }
    }
    debugPrint("evidenceSubmissions: $evidenceSubmissions");
    Either<Failure, dynamic> result = Right(evidenceSubmissions);
    return result;
  }

  Future<Either<Failure, dynamic>> getTaskSubmissions({
    required String criteriaNumber,
    required String evidenceNumber,
  }) async {
    var response =
        await qiyasManagerApprovalsRemoteDataSource.getTaskSubmssions(
      criteriaNumber: criteriaNumber,
      evidenceNumber: evidenceNumber,
    );
    if (response.isLeft()) return response;
    List<Map<String, dynamic>>? data = response.fold((_) => null, (r) => r);
    if (data == null || data.isEmpty) {
      return response = Right([]);
    } else {
      List<EvidenceSubmissionModel> submissions =
          data.map((e) => EvidenceSubmissionModel.fromMap(e)).toList();
      return response = Right(submissions);
    }
  }

  Future<Either<FirebaseFailure, void>> updateTaskStatus(
      {required String submissionId,
      required EvidenceSubmissionStatus status,
      required String currentUserId,
      String? reason}) async {
    return await qiyasManagerApprovalsRemoteDataSource.updateTaskStatus(
      submissionId: submissionId,
      status: status,
      reason: reason,
      currentUserId: currentUserId,
    );
  }
}
