/// *********************** FILE INFO ***********************
/// File Name: get_tasks_status_use_case.dart
/// Author: Mohamed Elrashidy
/// Created At: 8/5/2025
library;

import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/entities/task_overview.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_tasks/data/repository/champigan_tasks_repository.dart';

class GetTasksStatusUseCase {
  OwnerTasksRepository ownerTasksRepository;

  GetTasksStatusUseCase({required this.ownerTasksRepository});

  Future<Either<Failure, dynamic>> execute(
      {required List<QiyasChampionEntity> tasks}) async {
    var response = await ownerTasksRepository.getTasksStatus(
      criteriaNumbers: tasks.map((e) => e.criteriaId.trim()).toList(),
      evidenceNumber: tasks.map((e) => e.documentNumber.trim()).toList(),
    );
    if (response.isLeft()) return response;
    List<EvidenceSubmissionModel?> evidenceSubmissions =
        response.fold((_) => List<EvidenceSubmissionModel?>.from([]), (r) => r);
    List<TaskOverview> taskOverviews = [];
    for (int i = 0; i < tasks.length; i++) {
      debugPrint("has evidence: ${evidenceSubmissions[i] != null}");
      TaskOverview taskOverview = TaskOverview(
        championId: tasks[i].controlChampion.trim().toLowerCase(),
        deadLineDate: tasks[i].documentSubmissionDate,
        submissionDate: evidenceSubmissions[i]?.submissionDate?.toDate(),
        criteriaNumber: tasks[i].criteriaId.trim(),
        evidenceNumber: tasks[i].documentNumber.trim(),
        status: evidenceSubmissions[i]?.submissionStatus ??
            EvidenceSubmissionStatus.unCompleted,
      );
      if ((taskOverview.status == EvidenceSubmissionStatus.submitted ||
              taskOverview.status == EvidenceSubmissionStatus.unCompleted) &&
          tasks[i].documentSubmissionDate.isBefore(DateTime.now().subtract(
              tasks[i].lateUnit.subtractValue(tasks[i].lateUnitMultiplier)))) {
        taskOverview.status = EvidenceSubmissionStatus.late;
      }
      taskOverviews.add(taskOverview);
    }
    Map<EvidenceSubmissionStatus, List<TaskOverview>> taskStatusMap = {};
    for (EvidenceSubmissionStatus status in EvidenceSubmissionStatus.values) {
      taskStatusMap[status] = [];
    }
    for (var task in taskOverviews) {
      taskStatusMap[task.status]!.add(task);
      taskStatusMap[EvidenceSubmissionStatus.all]!.add(task);
    }

    return response = Right(taskStatusMap);
  }
}
