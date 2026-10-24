import 'dart:ui';

import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

final List<String> dashboardDocumentStatusTexts = [
  "معتمد",
  "قيد الاعتماد",
  "مرفوض",
  "غير منجز",
];
final List<String> dashboardDocumentStatusValues = [
  "2",
  "2",
  "3",
  "2",
];
final List<String> dashboardDocumentTexts = [
  "يناير",
  "فبراير",
  "مارس",
  "ابريل",
];
final List<String> dashboardDocumentValues = [
  "79",
  "49",
  "282",
  "366",
];

class DepartmentPerformance {
  String name;
  List<int> values;
  int number;

  DepartmentPerformance(
      {required this.name, required this.values, required this.number});
}

final List<Color> departmentPerformanceColors = [
  AppColors.lightGreen,
  AppColors.orange,
  AppColors.block,
  AppColors.darkGrey,
];
List<EvidenceSubmissionStatus> get departmentStatus => [
      EvidenceSubmissionStatus.approved,
      EvidenceSubmissionStatus.pending,
      EvidenceSubmissionStatus.submitted,
      EvidenceSubmissionStatus.unCompleted,
      EvidenceSubmissionStatus.rejected,
      EvidenceSubmissionStatus.late,
    ];

List<EvidenceSubmissionStatus> evidenceRateStatus = [
  EvidenceSubmissionStatus.submitted,
  EvidenceSubmissionStatus.pending,
  EvidenceSubmissionStatus.approved,
  EvidenceSubmissionStatus.rejected,
];
List<EvidenceSubmissionStatus> evidenceStatusPriority = [
  EvidenceSubmissionStatus.late,
  EvidenceSubmissionStatus.unCompleted,
  EvidenceSubmissionStatus.submitted,
  EvidenceSubmissionStatus.pending,
  EvidenceSubmissionStatus.approved,
  EvidenceSubmissionStatus.rejected,
];
final List<DepartmentPerformance> departmentPerformanceList = [
  DepartmentPerformance(number: 50, name: "التسويق", values: [8, 12, 12, 18]),
  DepartmentPerformance(
      number: 110, name: "الموارد البشرية", values: [8, 12, 12, 18]),
  DepartmentPerformance(number: 110, name: "المالية", values: [8, 12, 12, 18]),
  DepartmentPerformance(number: 110, name: "المحاسبة", values: [8, 12, 12, 18]),
  DepartmentPerformance(
      number: 110, name: "البحث والتطوير", values: [8, 12, 12, 18]),
];
final List<String> departmentPerformanceStatusTitles = [
  "معتمد",
  "قيد الاعتماد",
  "مرفوض",
  "غير منجز",
];
