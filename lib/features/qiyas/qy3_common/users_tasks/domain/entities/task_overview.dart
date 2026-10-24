import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/utils/task_helper.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';

class TaskOverview {
  String criteriaNumber;
  String evidenceNumber;
  EvidenceSubmissionStatus status;
  DateTime deadLineDate;
  DateTime? submissionDate;
  String? championId;
  TaskOverview(
      {required this.criteriaNumber,
      required this.evidenceNumber,
      required this.status,
      required this.deadLineDate,
      this.submissionDate,
      this.championId});

  String get visionName {
    return TaskHelper().visionName(criteriaNumber);
  }

  String get topicName {
    return TaskHelper().topicName(criteriaNumber);
  }

  String get criteriaName {
    return TaskHelper().criteriaName(criteriaNumber);
  }
}
