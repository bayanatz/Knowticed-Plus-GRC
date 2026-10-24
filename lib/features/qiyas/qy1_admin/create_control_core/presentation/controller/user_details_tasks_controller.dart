import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/table_text_info.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constants/create_control_constants.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/employee_name_and_image.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';

extension UserDetailsTasksController on QiyasCreateChampionControllerCubit {
  List<DataColumn> getUserDetailsTasksColumns(bool isOwner) {
    userTasksWidth = 60;
    List<String> headerStrings = Constants.userTasksChampionTableHeaders;
    calculateUserTasksWidth();
    List<DataColumn> header = headerStrings
        .map((header) => DataColumn(
              label: Text(
                header,
                style: StyleText.fontSize14Weight400.copyWith(
                    color: AppTheme.isDark ? AppColors.white : AppColors.white),
              ),
            ))
        .toList();
    if (selectedStatus != EvidenceSubmissionStatus.all) {
      header.removeAt(Constants.userTasksChampionTableHeaders.length - 2);
    }

    debugPrint("User Tasks Columns: ${header.length}");
    return header;
  }

  List<DataRow> getUserDetailsTasksRows(bool isOwner) {
    QiyasHomeCubit qiyasHomeCubit = sl();

    List<DataRow> rows = [];
    for (int i = 0; i < filteredTasks.length; i++) {
      DateTime deadline = getTaskDeadline(filteredTasks[i]);
      debugPrint(
          "evidenc numsber ${int.parse(filteredTasks[i].evidenceNumber)}");
      rows.add(
        DataRow(
          color: WidgetStateProperty.resolveWith<Color?>((states) {
            return i.isEven
                ? !AppTheme.isDark
                    ? AppColors.whiteDashboardTable
                    : AppColors.darkDashboardTable
                : !AppTheme.isDark
                    ? AppColors.white
                    : AppColors.black;
          }),
          cells: [
            if (selectedDocument == null)
              DataCell(
                TableTextInfo(
                  text: qiyasHomeCubit.getDocumentsNames(
                          criterionName: selectedCriterion!,
                          topicName: selectedTopic!,
                          visionName: selectedVision!)[
                      int.parse(filteredTasks[i].evidenceNumber)],
                  width: 400,
                ),
              ),
            if (selectedDocument != null)
              DataCell(
                TableTextInfo(
                  text: filteredTasks[i].fileName,
                  width: calculateFileNamesWidth(),
                ),
              ),
            DataCell(TableTextInfo(
              text: DateFormat('dd MMM yyyy', 'ar').format(deadline),
              width: 120,
            )),
            DataCell(TableTextInfo(
              text: (filteredTasks[i].submissionDate != null)
                  ? DateFormat('dd MMM yyyy', 'ar')
                      .format(filteredTasks[i].submissionDate!.toDate())
                  : '-',
              width: 120,
            )),
            DataCell(
              EmployeeNameAndImage(
                employeeId: filteredTasks[i].approvedBy,
              ),
            ),
            DataCell(
              EmployeeNameAndImage(
                employeeId: filteredTasks[i].managerId,
              ),
            ),
            if (selectedStatus == EvidenceSubmissionStatus.all)
              DataCell(
                TableTextInfo(
                  text: (filteredTasks[i].submissionStatus.value),
                  color: filteredTasks[i].submissionStatus.color,
                  width: 150.sp,
                ),
              ),
            DataCell(
              TableTextInfo(
                text: filteredTasks[i].managerResponseTime != null
                    ? DateFormat('dd MMM yyyy', 'ar')
                        .format(filteredTasks[i].managerResponseTime!.toDate())
                    : filteredTasks[i].approvedDate != null
                        ? DateFormat('dd MMM yyyy', 'ar')
                            .format(filteredTasks[i].approvedDate!.toDate())
                        : '-',
                width: 120,
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }

  void calculateUserTasksWidth() {}

  void filterTasks() {
    String searchText = tasksSearchController.text.toLowerCase().trim();
    debugPrint("search text is: $searchText");
    filteredTasks = [];
    for (EvidenceSubmissionModel task in tasks[selectedStatus] ?? []) {
      if (task.submittedBy!.toLowerCase().trim().contains(searchText) ||
          task.fileName.toLowerCase().trim().contains(searchText) ||
          (task.approvedBy != null &&
              task.approvedBy!.toLowerCase().trim().contains(searchText))) {
        if (filterDate == null ||
            (task.submissionDate?.toDate().day == filterDate?.day &&
                task.submissionDate?.toDate().month == filterDate?.month &&
                task.submissionDate?.toDate().year == filterDate?.year)) {
          filteredTasks.add(task);
        }
      }
    }
    if ((selectedStatus == EvidenceSubmissionStatus.all ||
            selectedStatus == EvidenceSubmissionStatus.unCompleted) &&
        selectedDocument != null) {
      filteredTasks.add(EvidenceSubmissionModel(
        submissionDate: null,
        submissionStatus: EvidenceSubmissionStatus.unCompleted,
        submissionId: '',
        evidenceNumber: getSelectedEvidenceNumber(),
        criteriaNumber: getSelectedCriteriaNumber(),
        submittedBy: null,
      ));
    }

    emitState(SectionViewUpdated());
  }

  void updateSelectedUserTaskStatus(EvidenceSubmissionStatus status) {
    selectedStatus = status;
    filterTasks();
  }

  double calculateFileNamesWidth() {
    userTasksWidth = 0;
    for (EvidenceSubmissionModel task in filteredTasks) {
      if (task.fileName.length > userTasksWidth) {
        userTasksWidth = task.fileName.length;
      }
    }
    userTasksWidth = userTasksWidth * 10;
    if (userTasksWidth < 100) {
      userTasksWidth = 100;
    }
    debugPrint("Calculated File Names Width: $userTasksWidth");
    return userTasksWidth.sp;
  }

  List<List<dynamic>> exportTasksToExcel() {
    QiyasHomeCubit qiyasHomeCubit = sl();
    List<List<dynamic>> excelData = [];
    List<String> headers =
        Constants.userTasksChampionTableHeaders.map((e) => e).toList();
    if (selectedStatus != EvidenceSubmissionStatus.all) {
      headers.removeAt(Constants.userTasksChampionTableHeaders.length - 2);
    }
    excelData.add(headers.reversed.toList());
    for (EvidenceSubmissionModel task in filteredTasks) {
      DateTime deadline = getTaskDeadline(task);
      List<dynamic> row = [];

      if (selectedDocument == null) {
        row.add(
          qiyasHomeCubit.getDocumentsNames(
            criterionName: selectedCriterion!,
            topicName: selectedTopic!,
            visionName: selectedVision!,
          )[int.parse(task.evidenceNumber)],
        );
      } else {
        row.add(task.fileName);
      }
      row.add(
        DateFormat('dd MMM yyyy', 'ar').format(deadline),
      );
      row.add(
        (task.submissionDate != null)
            ? DateFormat('dd MMM yyyy', 'ar')
                .format(task.submissionDate!.toDate())
            : '-',
      );
      row.add(task.approvedBy ?? '-');
      row.add(task.managerId ?? '-');
      if (selectedStatus == EvidenceSubmissionStatus.all) {
        row.add(task.submissionStatus.value);
      }
      row.add(
        task.managerResponseTime != null
            ? DateFormat('dd MMM yyyy', 'ar')
                .format(task.managerResponseTime!.toDate())
            : task.approvedDate != null
                ? DateFormat('dd MMM yyyy', 'ar')
                    .format(task.approvedDate!.toDate())
                : '-',
      );
      excelData.add(row.reversed.toList());
    }
    return excelData;
  }

  DateTime getTaskDeadline(EvidenceSubmissionModel filteredTask) {
    for (QiyasChampionEntity champion in qiyasChampions) {
      if (champion.controlChampion.toLowerCase().trim() ==
              personDetails!.id.toLowerCase().trim() &&
          champion.criteriaId == filteredTask.criteriaNumber &&
          champion.documentNumber == filteredTask.evidenceNumber) {
        debugPrint('🟢 DEADLINE MATCH: criteriaId=${champion.criteriaId}, '
            'docNumber=${champion.documentNumber}, '
            'deadline=${champion.documentSubmissionDate}');
        return champion.documentSubmissionDate;
      }
    }
    debugPrint(
        '🔴 NO DEADLINE MATCH for criteriaNumber=${filteredTask.criteriaNumber}, '
        'evidenceNumber=${filteredTask.evidenceNumber}');
    return DateTime.now();
  }
}
