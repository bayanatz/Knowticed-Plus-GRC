import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/entities/task_overview.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/data/repository/qiyas_manager_approvals_repository.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';

class GetTasksStatusUseCases {
  QiyasManagerApprovalsRepository repository;

  GetTasksStatusUseCases({required this.repository});

  Future<Either<Failure, dynamic>> execute(
      {required List<QiyasChampionEntity> championTasks}) async {
    List<String> criteriaNumbers = [];
    List<String> evidenceNumbers = [];
    for (int i = 0; i < championTasks.length; i++) {
      criteriaNumbers.add(championTasks[i].criteriaId);
      evidenceNumbers.add(championTasks[i].documentNumber);
    }
    var result = await repository.getLastEvidenceStatus(
      criteriaNumbers: criteriaNumbers,
      evidenceNumbers: evidenceNumbers,
    );
    if (result.isLeft()) return result;
    List<EvidenceSubmissionModel?> evidenceSubmissions =
        result.fold((_) => [], (r) => r);

    List<TaskOverview> taskOverviews = [];
    for (int i = 0; i < championTasks.length; i++) {
      EvidenceSubmissionStatus? status;
      DateTime deadLineDate = championTasks[i].documentSubmissionDate;
      EvidenceSubmissionModel? submissionModel = evidenceSubmissions[i];
      status = submissionModel?.submissionStatus ??
          EvidenceSubmissionStatus.unCompleted;
      if ((status == EvidenceSubmissionStatus.rejected ||
              status == EvidenceSubmissionStatus.unCompleted) &&
          championTasks[i].documentSubmissionDate.isBefore(DateTime.now()
              .subtract(championTasks[i]
                  .lateUnit
                  .subtractValue(championTasks[i].lateUnitMultiplier)))) {
        status = EvidenceSubmissionStatus.late;
      }
      taskOverviews.add(TaskOverview(
          submissionDate: (submissionModel?.submissionDate == null)
              ? null
              : DateTime(
                  submissionModel!.submissionDate!.toDate().year,
                  submissionModel.submissionDate!.toDate().month,
                  submissionModel.submissionDate!.toDate().day),
          criteriaNumber: championTasks[i].criteriaId,
          evidenceNumber: championTasks[i].documentNumber,
          status: status,
          championId: championTasks[i].controlChampion,
          deadLineDate: deadLineDate));
    }
    Map<EvidenceSubmissionStatus, List<TaskOverview>> taskStatusMap = {};
    for (EvidenceSubmissionStatus status in EvidenceSubmissionStatus.values) {
      taskStatusMap[status] = [];
    }
    for (TaskOverview task in taskOverviews) {
      taskStatusMap[task.status]?.add(task);
      taskStatusMap[EvidenceSubmissionStatus.all]?.add(task);
    }
    return result = Right(taskStatusMap);
  }
}
