import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/utils/task_helper.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/media_handler.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/controller/qiyas_dashboard_controller_cubit.dart';

extension UploadedDocumentController on QiyasDashboardControllerCubit {
  /// function name: [initUploadedDocumentController]
  ///
  /// purpose: Initializes the uploaded document controller.
  void initUploadedDocumentController() {
    departmentSubmissions = {};
    documentSubmissions = {};
    criteriaSubmissions = {};
    topicSubmissions = {};
    visionSubmissions = {};
    yearSubmissions = {};
    departmentIds = [];
  }

  /// function name: [getYears]
  ///
  /// purpose: Gets the years from the submissions.
  List<int> getYears() {
    List<int> years = [];
    for (EvidenceSubmissionModel element in submissions) {
      int year = element.submissionDate!.toDate().year;
      if (departmentIds.contains(
              TaskHelper().getChampionDepartmentId(element.submittedBy!)) &&
          !yearSubmissions.containsKey(year)) {
        years.add(year);
      }
    }
    return years.toSet().toList();
  }

  /// function name: [toggleYearSelection]
  ///
  /// purpose: Toggles the year selection.
  void toggleYearSelection(int year) {
    if (yearSubmissions.containsKey(year)) {
      yearSubmissions.remove(year);
      visionSubmissions.clear();
      topicSubmissions.clear();
      criteriaSubmissions.clear();
      documentSubmissions.clear();
    } else {
      yearSubmissions.putIfAbsent(year, () => []);
      yearSubmissions[year]!.addAll(submissions.where((element) {
        debugPrint("year is ${element.submissionDate!.toDate().year}");
        return element.submissionDate!.toDate().year == year;
      }));
      for (EvidenceSubmissionModel submission in yearSubmissions[year]!) {
        debugPrint(
            "vision name is ${getVisionNameFromVisionId(visionId(submission))}");
      }
      debugPrint("year submission length ${yearSubmissions[year]!.length}");
    }
  }

  /// function name: [getVisions]
  ///
  /// purpose: Gets the visions from the submissions.
  List<String> getVisions() {
    List<String> visions = [];
    for (int year in yearSubmissions.keys) {
      for (EvidenceSubmissionModel submission in yearSubmissions[year]!) {
        String id = visionId(submission);

        debugPrint("vision id $id");
        {
          visions.add(id);
        }
      }
    }
    return visions.toSet().toList();
  }

  /// function name: [getTopic]
  ///
  /// purpose: Gets the topic from the submissions
  List<String> getTopics() {
    List<String> topics = [];
    for (String vision in visionSubmissions.keys) {
      for (EvidenceSubmissionModel submission in visionSubmissions[vision]!) {
        String topic = topicId(submission);

        topics.add(topic);
      }
    }
    return topics.toSet().toList();
  }

  /// function name: [getCriteria]
  ///
  /// purpose: Gets the criteria from the submissions
  List<String> getCriteria() {
    List<String> criteria = [];
    for (String topic in topicSubmissions.keys) {
      for (EvidenceSubmissionModel submission in topicSubmissions[topic]!) {
        String cId = criteriaId(submission);
        criteria.add(cId);
      }
    }
    return criteria.toSet().toList();
  }

  /// function name: [getDocuments]
  ///
  /// purpose: Gets the documents from the submissions
  List<String> getDocuments() {
    List<String> documents = [];
    for (String criteria in criteriaSubmissions.keys) {
      debugPrint(
          "criteria submissions length ${criteriaSubmissions[criteria]!.length}");
      for (EvidenceSubmissionModel submission
          in criteriaSubmissions[criteria]!) {
        String document = documentId(submission);

        documents.add(document);
      }
    }
    debugPrint("document length ${documents.toSet().length}");
    return documents.toSet().toList();
  }

  /// function name: [toggleDepartmentSelection]
  ///
  /// purpose: Toggles the department selection
  void toggleDepartmentSelection(String department) {
    if (departmentIds.contains(department)) {
      departmentIds.remove(department);
      yearSubmissions.clear();
      visionSubmissions.clear();
      topicSubmissions.clear();
      criteriaSubmissions.clear();
      documentSubmissions.clear();
      departmentSubmissions.clear();
    } else {
      departmentIds.add(department);
    }
  }

  /// function name: [toggleVisionSelection]
  ///
  /// purpose: Toggles the vision selection
  ///
  /// parameters:
  /// [vision] - The vision to toggle the selection for
  void toggleVisionSelection(String vision) {
    debugPrint("selected vision $vision");
    if (visionSubmissions.containsKey(vision)) {
      visionSubmissions.remove(vision);
      topicSubmissions.clear();
      criteriaSubmissions.clear();
      documentSubmissions.clear();
    } else {
      visionSubmissions.putIfAbsent(vision, () => []);
      visionSubmissions[vision]!
          .addAll(submissions.where((element) => visionId(element) == vision));
    }
  }

  /// function name: [toggleTopicSelection]
  ///
  /// purpose: Toggles the topic selection
  void toggleTopicSelection(String topic) {
    if (topicSubmissions.containsKey(topic)) {
      topicSubmissions.remove(topic);
      criteriaSubmissions.clear();
      documentSubmissions.clear();
    } else {
      topicSubmissions.putIfAbsent(topic, () => []);
      topicSubmissions[topic]!
          .addAll(submissions.where((element) => topicId(element) == topic));
    }
  }

  /// function name: [toggleCriteriaSelection]
  ///
  /// purpose: Toggles the criteria selection
  void toggleCriteriaSelection(String criteria) {
    if (criteriaSubmissions.containsKey(criteria)) {
      criteriaSubmissions.remove(criteria);
      documentSubmissions.clear();
    } else {
      criteriaSubmissions.putIfAbsent(criteria, () => []);
      criteriaSubmissions[criteria]!.addAll(
          submissions.where((element) => criteriaId(element) == criteria));
    }
  }

  /// function name: [toggleDocumentSelection]
  ///
  /// purpose: Toggles the document selection
  void toggleDocumentSelection(String document) {
    if (documentSubmissions.containsKey(document)) {
      documentSubmissions.remove(document);
    } else {
      documentSubmissions.putIfAbsent(document, () => []);
      documentSubmissions[document]!.addAll(
          submissions.where((element) => documentId(element) == document));
    }
  }

  /// function name: [visionId]
  ///
  /// purpose: Gets the vision id from the submission
  ///
  /// parameters:
  /// [submission] - The submission to get the vision id from
  String visionId(EvidenceSubmissionModel submission) {
    int year = submission.submissionDate!.toDate().year;
    String visionNumber = submission.criteriaNumber.split('.').first;
    return '$year-$visionNumber';
  }

  /// function name: [topicId]
  ///
  /// purpose: Gets the topic id from the submission
  ///
  /// parameters:
  /// [submission] - The submission to get the topic id from
  String topicId(EvidenceSubmissionModel submission) {
    int year = submission.submissionDate!.toDate().year;
    String visionNumber = submission.criteriaNumber.split('.').first;
    String topicNumber = submission.criteriaNumber.split('.')[1];
    return '$year-$visionNumber.$topicNumber';
  }

  /// function name: [criteriaId]
  ///
  /// purpose: Gets the criteria id from the submission
  ///
  /// parameters:
  /// [submission] - The submission to get the criteria id from
  String criteriaId(EvidenceSubmissionModel submission) {
    int year = submission.submissionDate!.toDate().year;
    String criteriaNumber = submission.criteriaNumber;
    return '$year-$criteriaNumber';
  }

  /// function name: [documentId]
  ///
  /// purpose: Gets the document id from the submission
  ///
  /// parameters:
  /// [submission] - The submission to get the document id from
  String documentId(EvidenceSubmissionModel submission) {
    int year = submission.submissionDate!.toDate().year;
    String criteriaNumber = submission.criteriaNumber;
    String documentNumber = submission.evidenceNumber;
    return '$year-$criteriaNumber.$documentNumber';
  }

  /// function name: [getVisionNameFromVisionId]
  ///
  /// purpose: Gets the vision name from the vision id
  ///
  /// parameters:
  /// [visionId] - The vision id to get the vision name from
  String getVisionNameFromVisionId(String visionId) {
    QiyasHomeCubit qiyasHomeCubit = sl();
    String visionNumber = visionId.split('-').last;
    String criteriaNumber = submissions
        .firstWhere((element) =>
            element.criteriaNumber.split('.').first == visionNumber)
        .criteriaNumber;
    return qiyasHomeCubit.getVisionName(criteriaNumber);
  }

  String getTopicName(String topic) {
    QiyasHomeCubit qiyasHomeCubit = sl();
    String criteriaNumber = submissions
        .firstWhere((element) => topicId(element) == topic)
        .criteriaNumber;
    return qiyasHomeCubit.getTopicName(criteriaNumber);
  }

  String getCriteriaName(String criteria) {
    QiyasHomeCubit qiyasHomeCubit = sl();
    String criteriaNumber = submissions
        .firstWhere((element) => criteriaId(element) == criteria)
        .criteriaNumber;
    return qiyasHomeCubit.getCriteriaName(criteriaNumber);
  }

  Future<void> downloadDocuments() async {
    Set<String> evidenceIds = {};
    for (String critria in criteriaSubmissions.keys) {
      for (EvidenceSubmissionModel submission
          in criteriaSubmissions[critria]!) {
        String id = documentId(submission);
        if (!evidenceIds.contains(id) &&
            EvidenceSubmissionStatus.late != submission.submissionStatus &&
            (submission.submissionStatus == selectedStatus ||
                selectedStatus == EvidenceSubmissionStatus.late)) {
          evidenceIds.add(id);
          // make file name year/departmentNameInArabic/visions/topic/criteria/fileName
          String year = submission.submissionDate!.toDate().year.toString();
          String departmentName = TaskHelper()
              .getChampionDepartmentArabicName(submission.submittedBy!);
          String vision = getVisionNameFromVisionId(visionId(submission));
          String topic = getTopicName(topicId(submission));
          String criteria = getCriteriaName(criteriaId(submission));
          String path =
              '/Qiyas Submissions/$year/$departmentName/$vision/$topic/$criteria';
          if (selectedStatus == EvidenceSubmissionStatus.approved ||
              selectedStatus == EvidenceSubmissionStatus.rejected) {
          } else {
            path = '$path/${submission.submissionStatus.value}';
          }
          await MediaHandler().downloadFile(
              submission.filePath, submission.fileName,
              path: path);
        }
      }
    }
  }
}
