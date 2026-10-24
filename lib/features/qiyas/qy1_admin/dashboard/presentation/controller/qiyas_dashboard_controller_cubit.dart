import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/data/repository/dashboard_repository.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/domain/assing_status.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/utils/task_helper.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constants/dashboard_constants.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/utils/time_filter.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';

part 'qiyas_dashboard_controller_state.dart';

class QiyasDashboardControllerCubit
    extends Cubit<QiyasDashboardControllerState> {
  QiyasDashboardControllerCubit() : super(QiyasDashboardControllerInitial()) {
    initCubit();
  }
  Map<int, List<EvidenceSubmissionModel>> yearSubmissions = {};
  Map<String, List<EvidenceSubmissionModel>> visionSubmissions = {};
  Map<String, List<EvidenceSubmissionModel>> topicSubmissions = {};
  Map<String, List<EvidenceSubmissionModel>> criteriaSubmissions = {};
  Map<String, List<EvidenceSubmissionModel>> documentSubmissions = {};
  Map<String, List<EvidenceSubmissionModel>> departmentSubmissions = {};
  Map<String, AssignStatus> criteriaAssignStatus = {};
  // we are using late to simulate both
  EvidenceSubmissionStatus selectedStatus = EvidenceSubmissionStatus.late;
  List<String> departmentIds = [];

  DashboardRepository repository = DashboardRepository();
  List<QiyasChampionEntity> tasks = [];
  List<QiyasChampionEntity> inactiveTasks = [];
  List<EvidenceSubmissionModel> submissions = [];
  Map<String, EvidenceSubmissionStatus> topicColor = {};
  Map<String, EvidenceSubmissionStatus> criteriaColor = {};
  Map<String, AssignStatus> topicAssignStatus = {};

  List<String> selectedDepartmentsFilter = [];
  String? pieChartDepartmentId;
  String? barChartDepartmentId;
  Map<String, Map<String, List<EvidenceSubmissionModel>>>
      submissionsByEvidenceId = {}; // evidenceid { championId: [submissions] }
  bool isTabsSelected = true;
  TimeFilter timeFilter = TimeFilter.all;
  EvidenceSubmissionStatus submissionStatusFilter =
      EvidenceSubmissionStatus.submitted;
  Future<void> initCubit() async {
    await Future.wait([
      getAllActiveChampionTasks(),
      getAllSubmissions(),
      getAllInactiveChampionTasks(),
    ]);
    //print("qiyas dashboard init");
    if (isClosed) return;
    emit(QiyasDashboardControllerLoadedState());
    _watch();
  }

  final LiveRefresh _live = LiveRefresh();

  /// Keeps every dashboard chart/count live: re-reads the champion tasks and
  /// evidence submissions (silently, no loading state) whenever they change.
  void _watch() => _live.watchPaths([
        getBaseUrl(kQiyasChampionNameCollection),
        getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
      ], getAllChampionsAssignments);

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  Future<void> getAllChampionsAssignments() async {
    await Future.wait([
      getAllActiveChampionTasks(),
      getAllSubmissions(),
      getAllInactiveChampionTasks(),
    ]);

    // Regenerate all the maps and data
    generateSubmissionMap();
    getVisionAndCriteriaData();
    getTopicAssignStatus();

    if (isClosed) return;
    emit(QiyasDashboardControllerLoadedState());
  }

  /// function name: [isTabsSelectedState]
  ///
  /// purpose: Updates the state of the tab selection and triggers a ui refresh.
  ///          This function is used to change the tab selection status when the user selects a different tab.
  ///
  /// parameters:
  ///            [value] bool: the new state for the tab selection (true for selected, false for unselected).
  ///
  /// return type: [void]
  void isTabsSelectedState(bool value) {
    isTabsSelected = value;
    emit(QiyasDashboardTabsSelectedState());
  }

  Future<void> getAllActiveChampionTasks() async {
    final result = await repository.getAllChampionsActiveTasks();
    if (result.isLeft()) return;
    tasks = result.fold((_) => [], (r) => r);
    // //print('tasks length: ${tasks.length}');
  }

  /// function name: [getAllInactiveChampionTasks]
  ///
  /// purpose: Fetches all inactive champion tasks from the repository.
  Future<void> getAllInactiveChampionTasks() async {
    final result = await repository.getAllChampionsInactiveTasks();
    if (result.isLeft()) return;
    inactiveTasks = result.fold((_) => [], (r) => r);
    //print('inactive tasks length: ${inactiveTasks.length}');
  }

  /// function name: [getAllSubmissions]
  ///
  /// purpose: Fetches all submission statuses from the repository and generates a map of submissions by evidence ID.
  Future<void> getAllSubmissions() async {
    final result = await repository.getSubmissionStatus();
    if (result.isLeft()) return;
    submissions = result.fold((_) => [], (r) => r);
    //print('submissions length: ${submissions.length}');
    submissions.sort((a, b) => b.submissionDate!.compareTo(a.submissionDate!));
    //print("submissions length in dashboard is ${submissions.length}");
    generateSubmissionMap();
  }

  /// function name: [generateSubmissionMap]
  ///
  /// purpose: Generates a map of submissions grouped by evidence ID and champion ID.
  /// FIXED: Now uses lowercase emails consistently for case-insensitive matching
  void generateSubmissionMap() {
    submissionsByEvidenceId = {};
    //print('\n=== GENERATING SUBMISSION MAP ===');

    for (var submission in submissions) {
      String key =
          '${submission.criteriaNumber.trim()}-${submission.evidenceNumber.trim()}';

      // CRITICAL FIX: Store with lowercase email
      String championEmail = submission.submittedBy!.trim().toLowerCase();

      //print('📝 Submission:');
      //print('   Key: $key');
      //print('   Original Email: ${submission.submittedBy}');
      //print('   Normalized Email: $championEmail');
      //print('   Status: ${submission.submissionStatus.value}');

      submissionsByEvidenceId.putIfAbsent(key, () => {});
      submissionsByEvidenceId[key]!.putIfAbsent(championEmail, () => []);
      submissionsByEvidenceId[key]![championEmail]!.add(submission);
    }

    //print('\n📊 Submission Map Summary:');
    //print('Total evidence keys: ${submissionsByEvidenceId.length}');
    submissionsByEvidenceId.forEach((key, champions) {
      //print('  $key:');
      champions.forEach((email, submissions) {
        //print('    $email → ${submissions.length} submission(s)');
      });
    });

    // Sort lists from latest submission date to oldest
    for (var key in submissionsByEvidenceId.keys) {
      submissionsByEvidenceId[key]!.forEach((k, v) {
        v.sort((a, b) => b.submissionDate!.compareTo(a.submissionDate!));
      });
    }

    //print('=== END SUBMISSION MAP ===\n');
  }

  /// function name: [getSubmissionStatusCount]
  ///
  /// purpose: get dognuht chart data work on last state of document
  ///
  /// return type: [Map<EvidenceSubmissionStatus, int>]   evidence status and its number
  /// function name: [getSubmissionStatusCount]
  ///
  /// purpose: get doughnut chart data work on last state of document
  ///
  /// return type: [Map<EvidenceSubmissionStatus, int>]   evidence status and its number
  Map<EvidenceSubmissionStatus, int> getSubmissionStatusCount() {
    debugPrint('\n🔍 === PIE CHART DEBUG ===');
    debugPrint('Time filter: ${timeFilter.label}');
    debugPrint('Selected departments: $selectedDepartmentsFilter');
    debugPrint('Total tasks: ${tasks.length}');

    // ✅ ADD THIS DEBUG BLOCK AT THE TOP
    debugPrint('🔴🔴🔴 === DEPARTMENT NAME MATCHING DEBUG ===');
    debugPrint('🔴 Selected filters: $selectedDepartmentsFilter');

    Map<EvidenceSubmissionStatus, int> statusCount = {
      EvidenceSubmissionStatus.approved: 0,
      EvidenceSubmissionStatus.pending: 0,
      EvidenceSubmissionStatus.rejected: 0,
      EvidenceSubmissionStatus.unCompleted: 0,
      EvidenceSubmissionStatus.late: 0,
      EvidenceSubmissionStatus.submitted: 0,
    };

    Set<String> actualDepartmentNames = {};
    for (var task in tasks) {
      String deptName = TaskHelper()
          .getChampionDepartmentArabicName(task.controlChampion.toLowerCase());
      actualDepartmentNames.add(deptName);
    }
    debugPrint('🔴 Actual department names from tasks: $actualDepartmentNames');
    debugPrint('🔴🔴🔴 ================================');

    for (var task in tasks) {
      // Department filter
      if (selectedDepartmentsFilter.isNotEmpty &&
          !selectedDepartmentsFilter.contains(TaskHelper()
              .getChampionDepartmentArabicName(
                  task.controlChampion.toLowerCase()))) {
        continue;
      }

      EvidenceSubmissionModel? submissionModel = submissionsByEvidenceId[
                  '${task.criteriaId.trim()}-${task.documentNumber.trim()}']
              ?[task.controlChampion.trim().toLowerCase()]
          ?.firstOrNull;

      EvidenceSubmissionStatus status = submissionModel?.submissionStatus ??
          EvidenceSubmissionStatus.unCompleted;

      // Time filter validation
      bool isWithinTimeFilter = true;
      if (timeFilter == TimeFilter.month) {
        isWithinTimeFilter = validateTimeFilter(submissionModel,
            DateTime.now().subtract(const Duration(days: 30)), task);
      } else if (timeFilter == TimeFilter.quarter) {
        isWithinTimeFilter = validateTimeFilter(submissionModel,
            DateTime.now().subtract(const Duration(days: 90)), task);
      } else if (timeFilter == TimeFilter.year) {
        isWithinTimeFilter = validateTimeFilter(submissionModel,
            DateTime.now().subtract(const Duration(days: 365)), task);
      }

      if (!isWithinTimeFilter) continue;

      // ✅ If status is already set (rejected, approved, pending, submitted), keep it
      if (status == EvidenceSubmissionStatus.rejected ||
          status == EvidenceSubmissionStatus.approved ||
          status == EvidenceSubmissionStatus.pending ||
          status == EvidenceSubmissionStatus.submitted) {
        statusCount[status] = (statusCount[status] ?? 0) + 1;
        //print('  Task ${task.criteriaId}-${task.documentNumber}: ${status.value}');
        continue;
      }

      // ✅ Calculate LATE only for unCompleted tasks
      DateTime lateDeadline = task.documentSubmissionDate
          .subtract(task.lateUnit.subtractValue(task.lateUnitMultiplier));

      DateTime nowDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime lateDeadlineDate =
          DateTime(lateDeadline.year, lateDeadline.month, lateDeadline.day);
      DateTime submissionDeadlineDate = DateTime(
          task.documentSubmissionDate.year,
          task.documentSubmissionDate.month,
          task.documentSubmissionDate.day);

      bool isPastLateDeadline = nowDate.isAfter(lateDeadlineDate) ||
          nowDate.isAtSameMomentAs(lateDeadlineDate);
      bool isPastSubmissionDeadline = nowDate.isAfter(submissionDeadlineDate) ||
          nowDate.isAtSameMomentAs(submissionDeadlineDate);

      if (isPastLateDeadline || isPastSubmissionDeadline) {
        if (status == EvidenceSubmissionStatus.unCompleted) {
          status = EvidenceSubmissionStatus.late;
        }
      }

      statusCount[status] = (statusCount[status] ?? 0) + 1;
      //print('  Task ${task.criteriaId}-${task.documentNumber}: ${status.value}');
    }

    //print('Processed: $processedTasks tasks');
    //print('Status counts: $statusCount');
    //print('=======================\n');

    return statusCount;
  }

  List<String> get taskDepartmentNames {
    Set<String> names = {};
    for (var task in tasks) {
      String deptName = TaskHelper()
          .getChampionDepartmentArabicName(task.controlChampion.toLowerCase());
      if (deptName.isNotEmpty) {
        names.add(deptName);
      }
    }
    return names.toList();
  }

  /// function name: [getBarChartList]
  ///
  /// purpose: Generates a bar chart data map based on the submission status filter.
  /// FIXED: Now counts unique tasks (like pie chart) instead of all submissions
  ///
  /// return type: [Map<String, double>] - A map where keys are month names in Arabic and values are counts of submissions for that month.
  /// function name: [getBarChartList]
  ///
  /// purpose: Generates a bar chart data map based on the submission status filter.
  /// FIXED: Now counts unique tasks (like pie chart) instead of all submissions
  ///
  /// return type: [Map<String, double>] - A map where keys are month names in Arabic and values are counts of submissions for that month.
  Map<String, double> getBarChartList() {
    Map<String, double> barChartData = initMap();

    //print('\n🔍 === BAR CHART DEBUG ===');
    //print('Filter: ${submissionStatusFilter.value}');
    //print('Total tasks: ${tasks.length}');
    //print('Selected departments: $selectedDepartmentsFilter');

    // ✅ Loop through TASKS instead of submissions to avoid duplicates
    for (var task in tasks) {
      // Department filter
      if (selectedDepartmentsFilter.isNotEmpty &&
          !selectedDepartmentsFilter.contains(TaskHelper()
              .getChampionDepartmentArabicName(
                  task.controlChampion.toLowerCase()))) {
        continue;
      }

      // Get the LATEST submission for this task
      EvidenceSubmissionModel? submissionModel = submissionsByEvidenceId[
                  '${task.criteriaId.trim()}-${task.documentNumber.trim()}']
              ?[task.controlChampion.trim().toLowerCase()]
          ?.firstOrNull;

      // Get current status (same logic as pie chart)
      EvidenceSubmissionStatus status = submissionModel?.submissionStatus ??
          EvidenceSubmissionStatus.unCompleted;

      // ✅ Check if status is already final (not unCompleted)
      if (status == EvidenceSubmissionStatus.rejected ||
          status == EvidenceSubmissionStatus.approved ||
          status == EvidenceSubmissionStatus.pending ||
          status == EvidenceSubmissionStatus.submitted) {
        // Keep actual status
      } else {
        // ✅ Calculate LATE only for unCompleted
        DateTime lateDeadline = task.documentSubmissionDate
            .subtract(task.lateUnit.subtractValue(task.lateUnitMultiplier));

        DateTime nowDate = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        DateTime lateDeadlineDate =
            DateTime(lateDeadline.year, lateDeadline.month, lateDeadline.day);
        DateTime submissionDeadlineDate = DateTime(
            task.documentSubmissionDate.year,
            task.documentSubmissionDate.month,
            task.documentSubmissionDate.day);

        bool isPastLateDeadline = nowDate.isAfter(lateDeadlineDate) ||
            nowDate.isAtSameMomentAs(lateDeadlineDate);
        bool isPastSubmissionDeadline =
            nowDate.isAfter(submissionDeadlineDate) ||
                nowDate.isAtSameMomentAs(submissionDeadlineDate);

        if (isPastLateDeadline || isPastSubmissionDeadline) {
          if (status == EvidenceSubmissionStatus.unCompleted) {
            status = EvidenceSubmissionStatus.late;
          }
        }
      }

      // ✅ Only count if status matches the filter (skip if filter is not "all")
      if (submissionStatusFilter != EvidenceSubmissionStatus.all &&
          status != submissionStatusFilter) {
        continue;
      }

      // Determine which date to use
      DateTime? dateToUse;

      switch (submissionStatusFilter) {
        case EvidenceSubmissionStatus.submitted:
          if (submissionModel?.submissionDate != null) {
            dateToUse = submissionModel!.submissionDate!.toDate();
          }
          break;

        case EvidenceSubmissionStatus.pending:
          if (submissionModel?.approvedDate != null) {
            dateToUse = submissionModel!.approvedDate!.toDate();
          } else if (submissionModel?.submissionDate != null) {
            dateToUse = submissionModel!.submissionDate!.toDate();
          }
          break;

        case EvidenceSubmissionStatus.approved:
          if (submissionModel?.managerResponseTime != null) {
            dateToUse = submissionModel!.managerResponseTime!.toDate();
          } else if (submissionModel?.approvedDate != null) {
            dateToUse = submissionModel!.approvedDate!.toDate();
          }
          break;

        case EvidenceSubmissionStatus.rejected:
          if (submissionModel?.managerResponseTime != null) {
            dateToUse = submissionModel!.managerResponseTime!.toDate();
          } else if (submissionModel?.approvedDate != null) {
            dateToUse = submissionModel!.approvedDate!.toDate();
          }
          break;

        case EvidenceSubmissionStatus.late:
          if (submissionModel?.submissionDate != null) {
            dateToUse = submissionModel!.submissionDate!.toDate();
          } else {
            // Use task deadline for late tasks without submissions
            dateToUse = task.documentSubmissionDate;
          }
          break;

        case EvidenceSubmissionStatus.unCompleted:
          // Use task deadline for uncompleted tasks
          dateToUse = task.documentSubmissionDate;
          break;

        case EvidenceSubmissionStatus.all:
          // For "all" filter, determine date based on actual task status
          switch (status) {
            case EvidenceSubmissionStatus.approved:
              if (submissionModel?.managerResponseTime != null) {
                dateToUse = submissionModel!.managerResponseTime!.toDate();
              } else if (submissionModel?.approvedDate != null) {
                dateToUse = submissionModel!.approvedDate!.toDate();
              }
              break;
            case EvidenceSubmissionStatus.rejected:
              if (submissionModel?.managerResponseTime != null) {
                dateToUse = submissionModel!.managerResponseTime!.toDate();
              } else if (submissionModel?.approvedDate != null) {
                dateToUse = submissionModel!.approvedDate!.toDate();
              }
              break;
            case EvidenceSubmissionStatus.pending:
              if (submissionModel?.approvedDate != null) {
                dateToUse = submissionModel!.approvedDate!.toDate();
              } else if (submissionModel?.submissionDate != null) {
                dateToUse = submissionModel!.submissionDate!.toDate();
              }
              break;
            case EvidenceSubmissionStatus.submitted:
              if (submissionModel?.submissionDate != null) {
                dateToUse = submissionModel!.submissionDate!.toDate();
              }
              break;
            case EvidenceSubmissionStatus.late:
              if (submissionModel?.submissionDate != null) {
                dateToUse = submissionModel!.submissionDate!.toDate();
              } else {
                dateToUse = task.documentSubmissionDate;
              }
              break;
            case EvidenceSubmissionStatus.unCompleted:
              dateToUse = task.documentSubmissionDate;
              break;
            case EvidenceSubmissionStatus.all:
              // This shouldn't happen, but handle it anyway
              if (submissionModel?.submissionDate != null) {
                dateToUse = submissionModel!.submissionDate!.toDate();
              } else {
                dateToUse = task.documentSubmissionDate;
              }
              break;
          }
          break;
      }

      // Add to chart if we have a valid date
      if (dateToUse != null) {
        String monthName = DateFormat('MMMM', 'ar').format(dateToUse);

        if (barChartData.containsKey(monthName)) {
          barChartData[monthName] = (barChartData[monthName] ?? 0) + 1;

          //print('  ✓ Task ${task.criteriaId}-${task.documentNumber}: $monthName (${dateToUse.toString().split(' ')[0]}) - Status: ${status.value}');
        }
      }
    }

    //print('Processed: $processedCount tasks (should match pie chart if filter is not "all")');
    //print('Chart data: $barChartData');
    //print('=========================\n');

    return barChartData;
  }

  /// function name: [initMap]
  ///
  /// purpose: Initializes a map with month names in Arabic as keys and zero as values.
  ///
  /// return type: [Map<String, double>] - A map where keys are month names in Arabic and values are initialized to 0.
  /// function name: [initMap]
  ///
  /// purpose: Initializes a map with month names in Arabic as keys in chronological order
  ///
  /// return type: [Map<String, double>] - A map where keys are month names in Arabic and values are initialized to 0.
  Map<String, double> initMap() {
    Map<String, double> barChartData = {};

    // Get current date
    DateTime now = DateTime.now();

    // Generate last 12 months in chronological order
    for (int i = 11; i >= 0; i--) {
      DateTime monthDate = DateTime(now.year, now.month - i, 1);
      String monthName = DateFormat('MMMM', 'ar').format(monthDate);
      barChartData[monthName] = 0;
    }

    //print('📅 Initialized months: ${barChartData.keys.toList()}');

    return barChartData;
  }

  /// function name: [validateTimeFilter]
  ///
  /// purpose: Validates if the submission date or approved date of a task is within the specified time limitation.
  ///
  /// parameters:
  ///             [submissionModel] EvidenceSubmissionModel?: The submission model containing submission dates.
  ///             [timeLimitation] DateTime: The time limitation to check against.
  ///             [task] QiyasChampionEntity: The task entity containing document submission date.
  ///
  /// /// return type: [bool] - Returns true if the task's submission date or approved date is after the time limitation, false otherwise.
  bool validateTimeFilter(EvidenceSubmissionModel? submissionModel,
      DateTime timeLimitation, QiyasChampionEntity task) {
    bool isValid = true;
    DateTime filterDate = task.documentSubmissionDate;
    if (submissionModel != null) {
      filterDate = submissionModel.submissionDate!.toDate();
      if (submissionModel.approvedDate != null) {
        filterDate = submissionModel.approvedDate!.toDate();
      }
      if (submissionModel.managerResponseTime != null) {
        filterDate = submissionModel.managerResponseTime!.toDate();
      }
    }
    if (filterDate.isBefore(timeLimitation)) {
      isValid = false;
    }

    return isValid;
  }

  List<DepartmentPerformance> getEachDepartmentTasksStatus() {
    Map<String, Map<EvidenceSubmissionStatus, int>> departmentTasksStatus =
        {}; // departmentId: {status: count}

    for (QiyasChampionEntity task in tasks) {
      String departmentArabicName = TaskHelper()
          .getChampionDepartmentArabicName(task.controlChampion.toLowerCase());

      EvidenceSubmissionModel? submissionModel = submissionsByEvidenceId[
                  '${task.criteriaId.trim()}-${task.documentNumber.trim()}']
              ?[task.controlChampion.toLowerCase().trim()]
          ?.firstOrNull;

      //print('submissionModel: ${submissionModel?.toMap()}');
      EvidenceSubmissionStatus status = submissionModel?.submissionStatus ??
          EvidenceSubmissionStatus.unCompleted;

      // ✅ FIXED: Check actual status first BEFORE calculating LATE
      if (status != EvidenceSubmissionStatus.unCompleted) {
        // Keep rejected, approved, pending, submitted as-is
        departmentTasksStatus.putIfAbsent(
            departmentArabicName, () => <EvidenceSubmissionStatus, int>{});
        departmentTasksStatus[departmentArabicName]!
            .putIfAbsent(status, () => 0);
        departmentTasksStatus[departmentArabicName]![status] =
            (departmentTasksStatus[departmentArabicName]![status] ?? 0) + 1;
        continue;
      }

      // ✅ ONLY calculate LATE for unCompleted
      DateTime lateDeadline = task.documentSubmissionDate
          .subtract(task.lateUnit.subtractValue(task.lateUnitMultiplier));

      // Normalize dates to compare only date part (ignore time)
      DateTime nowDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime lateDeadlineDate =
          DateTime(lateDeadline.year, lateDeadline.month, lateDeadline.day);
      DateTime submissionDeadlineDate = DateTime(
          task.documentSubmissionDate.year,
          task.documentSubmissionDate.month,
          task.documentSubmissionDate.day);

      bool isPastLateDeadline = nowDate.isAfter(lateDeadlineDate) ||
          nowDate.isAtSameMomentAs(lateDeadlineDate);
      bool isPastSubmissionDeadline = nowDate.isAfter(submissionDeadlineDate) ||
          nowDate.isAtSameMomentAs(submissionDeadlineDate);

      if (isPastLateDeadline || isPastSubmissionDeadline) {
        if (status == EvidenceSubmissionStatus.unCompleted) {
          status = EvidenceSubmissionStatus.late;
        }
      }

      departmentTasksStatus.putIfAbsent(
          departmentArabicName, () => <EvidenceSubmissionStatus, int>{});
      departmentTasksStatus[departmentArabicName]!.putIfAbsent(status, () => 0);
      departmentTasksStatus[departmentArabicName]![status] =
          (departmentTasksStatus[departmentArabicName]![status] ?? 0) + 1;
    }

    List<DepartmentPerformance> departmentPerformanceList = [];
    // sort
    for (var department in departmentTasksStatus.keys) {
      String departmentName = department;
      List<int> values = [];
      for (var status in departmentStatus) {
        values.add((departmentTasksStatus[departmentName]?[status] ?? 0));
      }
      int total = values.reduce((value, element) => value + element);
      departmentPerformanceList.add(DepartmentPerformance(
          name: departmentName, values: values, number: total));
    }
    // Sort the list by total number of tasks in descending order
    departmentPerformanceList.sort((a, b) => b.number.compareTo(a.number));
    return departmentPerformanceList;
  }

  void updateSelectedDepartmentsFilter(String department) {
    if (selectedDepartmentsFilter.contains(department)) {
      selectedDepartmentsFilter.remove(department);
    } else {
      selectedDepartmentsFilter.add(department);
    }
    updateBarChartData();
    updatePieChartData();
  }

  void updatePieChartData() {
    emit(QiyasDashboardPieChartUpdated());
  }

  void updateBarChartData() {
    emit(QiyasDashboardBarChartUpdated());
  }

  void getVisionAndCriteriaData() {
    /// get number of evidence for each topic
    /// loop over tasks for this topic if number of active tasks is less than number of evidence then unassigned
    /// check for each task its evidence submission and record min status unassigned, late, uncompleted, rejected, submitted, pending, approved

    getTopicsColor();
    getCriteriaColors();
    getCriteriaAssignStatus(); // ✅ ADD THIS LINE
    emit(QiyasDashboardControllerVisionAndCriteriaDataLoaded());
  }

  void getTopicsColor() {
    topicColor = {};
    Map<String, int> topicEvidenceCount = getTopicCiriteriaEvidendnceCount();

    //print('\n🎨 === Calculating Topic Colors ===');

    for (QiyasChampionEntity task in tasks) {
      // ✅ Extract topic from task criteriaId
      List<String> parts = task.criteriaId.split('.');

      if (parts.length < 2) {
        //print('⚠️ Invalid task criteria: ${task.criteriaId}');
        continue;
      }

      String topicNumber = '${parts[0]}.${parts[1]}';

      topicEvidenceCount[topicNumber] =
          (topicEvidenceCount[topicNumber] ?? 0) - 1;

      EvidenceSubmissionStatus taskStatus = getTaskStatus(task);
      EvidenceSubmissionStatus? previousStatus = topicColor[topicNumber];

      if (previousStatus == null ||
          evidenceStatusPriority.indexOf(taskStatus) >
              evidenceStatusPriority.indexOf(previousStatus)) {
        topicColor[topicNumber] = taskStatus;
      }

      //print(
      //    '   Task: ${task.criteriaId} → Topic: $topicNumber → Status: ${taskStatus.value}');
    }

    removeUnassignedTopics(topicEvidenceCount);

    //print('🎨 Final Topic Colors: $topicColor');
    //print('====================================\n');
  }

  /// function name: [getTopicCiriteriaEvidendnceCount]
  ///
  /// purpose: Calculates the number of evidence for each topic based on the visions list.
  ///
  /// return type: [Map<String, int>] - A map where keys are topic numbers and values are the count of evidence for each topic.
  /// function name: [getTopicCiriteriaEvidendnceCount]
  ///
  /// purpose: Calculates the number of evidence for each topic
  ///
  /// FIXED: Extracts topic from CRITERION NUMBER instead of topicNumber field
  /// function name: [getTopicCiriteriaEvidendnceCount]
  ///
  /// purpose: Calculates the number of evidence for each topic
  ///
  /// FIXED: Extracts topic from CRITERION NUMBER instead of topicNumber field
  Map<String, int> getTopicCiriteriaEvidendnceCount() {
    Map<String, int> topicEvidenceCount = {};
    QiyasHomeCubit homeCubit = sl();

    //print('\n📊 === Counting Evidence for Topics ===');

    for (Visions vision in homeCubit.visionsList) {
      // ✅ FIX: Extract topic from criterion number
      String criterionNumber = vision.criterionNumber.trim();
      List<String> parts = criterionNumber.split('.');

      if (parts.length < 2) {
        //print('⚠️ Invalid criterion: $criterionNumber');
        continue;
      }

      String topicNumber = '${parts[0]}.${parts[1]}';

      int numberOfEvidence = homeCubit
          .getDocumentsNames(
              criterionName: vision.criterionName,
              topicName: vision.topicName,
              visionName: vision.visionName)
          .length;

      topicEvidenceCount[topicNumber] =
          (topicEvidenceCount[topicNumber] ?? 0) + numberOfEvidence;

      //print(
      // '   Criterion: $criterionNumber → Topic: $topicNumber (+$numberOfEvidence)');
    }

    //print('📊 Total Evidence Count: $topicEvidenceCount');
    //print('=====================================\n');

    return topicEvidenceCount;
  }

  EvidenceSubmissionStatus getTaskStatus(QiyasChampionEntity task) {
    EvidenceSubmissionModel? submissionModel = submissionsByEvidenceId[
                '${task.criteriaId.trim()}-${task.documentNumber.trim()}']
            ?[task.controlChampion.toLowerCase().trim()]
        ?.firstOrNull;

    EvidenceSubmissionStatus? status = EvidenceSubmissionStatus.unCompleted;
    if (submissionModel != null) status = submissionModel.submissionStatus;

    // ✅ FIXED: Don't override rejected, approved, pending, submitted
    if (status != EvidenceSubmissionStatus.unCompleted) {
      return status; // Keep actual status (rejected stays rejected!)
    }

    // ✅ ONLY calculate LATE for unCompleted
    DateTime lateDeadline = task.documentSubmissionDate
        .subtract(task.lateUnit.subtractValue(task.lateUnitMultiplier));

    // Normalize dates to compare only date part (ignore time)
    DateTime nowDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime lateDeadlineDate =
        DateTime(lateDeadline.year, lateDeadline.month, lateDeadline.day);
    DateTime submissionDeadlineDate = DateTime(task.documentSubmissionDate.year,
        task.documentSubmissionDate.month, task.documentSubmissionDate.day);

    bool isPastLateDeadline = nowDate.isAfter(lateDeadlineDate) ||
        nowDate.isAtSameMomentAs(lateDeadlineDate);
    bool isPastSubmissionDeadline = nowDate.isAfter(submissionDeadlineDate) ||
        nowDate.isAtSameMomentAs(submissionDeadlineDate);

    if (isPastLateDeadline || isPastSubmissionDeadline) {
      if (status == EvidenceSubmissionStatus.unCompleted) {
        status = EvidenceSubmissionStatus.late;
      }
    }

    return status;
  }

  void removeUnassignedTopics(Map<String, int> topicEvidenceCount) {
    topicEvidenceCount.forEach((topicNumber, count) {
      if (count > 0) {
        topicColor.remove(topicNumber);
      }
    });
    //print('topicColor: $topicColor');
  }

  void getCriteriaColors() {
    criteriaColor = {};
    Map<String, int> criteriaEvidenceCount = getCriteriaEvidenceCount();

    //print('\n🎨 === Calculating Criteria Colors ===');

    for (QiyasChampionEntity task in tasks) {
      String criteriaNumber = task.criteriaId.trim();

      criteriaEvidenceCount[criteriaNumber] =
          (criteriaEvidenceCount[criteriaNumber] ?? 0) - 1;

      EvidenceSubmissionStatus taskStatus = getTaskStatus(task);
      EvidenceSubmissionStatus? previousStatus = criteriaColor[criteriaNumber];

      if (previousStatus == null ||
          evidenceStatusPriority.indexOf(taskStatus) <
              evidenceStatusPriority.indexOf(previousStatus)) {
        criteriaColor[criteriaNumber] = taskStatus;
      }

      //print('   Task: $criteriaNumber → Status: ${taskStatus.value}');
    }

    removeUnassignedCriteria(criteriaEvidenceCount);

    //print('🎨 Final Criteria Colors: $criteriaColor');
    //print('======================================\n');
  }

  Map<String, int> getCriteriaEvidenceCount() {
    Map<String, int> criteriaEvidenceCount = {};
    QiyasHomeCubit homeCubit = sl();

    //print('\n📊 === Counting Evidence for Criteria ===');

    for (Visions vision in homeCubit.visionsList) {
      String criterionNumber = vision.criterionNumber.trim();

      int numberOfEvidence = homeCubit
          .getDocumentsNames(
              criterionName: vision.criterionName,
              topicName: vision.topicName,
              visionName: vision.visionName)
          .length;

      criteriaEvidenceCount[criterionNumber] =
          (criteriaEvidenceCount[criterionNumber] ?? 0) + numberOfEvidence;

      //print('   Criterion: $criterionNumber (+$numberOfEvidence docs)');
    }

    //print('📊 Total Criteria Count: $criteriaEvidenceCount');
    //print('========================================\n');

    return criteriaEvidenceCount;
  }

  void removeUnassignedCriteria(Map<String, int> criteriaEvidenceCount) {
    criteriaEvidenceCount.forEach((criteriaNumber, count) {
      if (count > 0) {
        criteriaColor.remove(criteriaNumber);
      }
    });
    //print('criteriaColor: $criteriaColor');
  }

  Map<String, Map<String, List<Map<String, String>>>> getCriteriaValuesMap() {
    Map<String, Map<String, List<Map<String, String>>>> criteriaValuesMap = {};
    QiyasHomeCubit homeCubit = sl();

    //print('\n🔍 === BUILDING CRITERIA MAP ===');

    for (Visions vision in homeCubit.visionsList) {
      // ✅ TRIM all strings to remove extra spaces
      String visionName = vision.visionName.trim();
      String topicName = vision.topicName.trim();
      String criteriaName = vision.criterionName.trim();
      String criteriaNumber = vision.criterionNumber.trim();

      //print('Vision: "$visionName" | Topic: "$topicName" | Criteria: "$criteriaNumber"');

      criteriaValuesMap.putIfAbsent(visionName, () => {});
      criteriaValuesMap[visionName]!.putIfAbsent(topicName, () => []);
      criteriaValuesMap[visionName]![topicName]!.add({
        criteriaName: criteriaNumber,
      });
    }

    //print('\n📊 Final Criteria Map Structure:');
    criteriaValuesMap.forEach((vision, topics) {
      //print('  Vision: "$vision" (${topics.length} topics)');
      topics.forEach((topic, criteria) {
        //print('    Topic: "$topic" (${criteria.length} criteria)');
      });
    });
    //print('=================================\n');

    return criteriaValuesMap;
  }

  /// function name: [getCriteriaVisionHeight]
  ///
  ///  purpose: Calculates the height of the criteria vision based on the number of criteria in each vision.
  double getCriteriaVisionHeight(
      Map<String, Map<String, List<Map<String, String>>>> criteriaMap) {
    int maxNumberOfCriteriaForTopic = 0;
    int maxCriteriaTextLength = 0;
    criteriaMap.forEach((visionName, topics) {
      topics.forEach((topicName, criteriaList) {
        if (criteriaList.length > maxNumberOfCriteriaForTopic) {
          maxNumberOfCriteriaForTopic = criteriaList.length;
        }
        for (var criteria in criteriaList) {
          String criteriaName = criteria.keys.first;
          if (criteriaName.length > maxCriteriaTextLength) {
            maxCriteriaTextLength = criteriaName.length;
          }
        }
      });
    });
    return maxNumberOfCriteriaForTopic *
            (20.sp + ((maxCriteriaTextLength + 39) / 40) * 18.sp).sp +
        30.sp +
        10.sp * (maxNumberOfCriteriaForTopic - 1) +
        60.sp;
  }

  /// function name: [getTopicAssignStatus]
  ///
  /// purpose: Determines assignment status for each topic based on champion assignments
  ///
  /// LOGIC:
  /// - UNASSIGNED (Grey): No champions assigned at all
  /// - IN_PROGRESS (Orange): Some evidence has champions, some doesn't
  /// - ASSIGNED (Yellow): All evidence has champions, but not all approved
  /// - APPROVED (Green): All evidence has champions AND all are approved
  /// function name: [getTopicAssignStatus]
  ///
  /// purpose: Determines assignment status for each topic based on champion assignments
  ///
  /// COMPLETE LOGIC:
  /// - Shows ALL topics (even with 0 assignments)
  /// - GREY border when no assignments
  /// - ORANGE border when partial assignments
  /// - YELLOW border when all assigned but not all approved
  /// - GREEN border when all assigned and all approved
  /// function name: [getTopicAssignStatus]
  ///
  /// purpose: Determines assignment status for each topic based on champion assignments
  ///
  /// COMPLETE LOGIC WITH FULL DEBUG TRACKING:
  /// - GREY border when no assignments
  /// - ORANGE border when partial assignments
  /// - YELLOW border when all assigned but not all approved
  /// - GREEN border when all assigned and all approved
  /// function name: [getTopicAssignStatus]
  ///
  /// purpose: Determines assignment status for each topic based on champion assignments
  ///
  /// FIXED: Extracts topic number from CRITERION NUMBER instead of topicNumber field
  /// to avoid confusion between 5.2 and 5.20
  ///
  void getTopicAssignStatus() {
    topicAssignStatus = {};

    // Group tasks by topic
    Map<String, List<QiyasChampionEntity>> tasksByTopic = {};
    Map<String, int> totalEvidenceByTopic = {};

    QiyasHomeCubit homeCubit = sl();

    //print('\n╔════════════════════════════════════════════════════════╗');
    //print('║  TOPIC ASSIGN STATUS - FIXED EXTRACTION (V7)          ║');
    //print('╚════════════════════════════════════════════════════════╝\n');

    // STEP 1: Count TOTAL evidence - Extract topic from CRITERION NUMBER
    //print('📋 STEP 1: Counting evidence (extracting from criterion)...');

    for (Visions vision in homeCubit.visionsList) {
      // ✅ FIX: Extract topic from criterion number (5.20.1 → 5.20)
      String criterionNumber = vision.criterionNumber.trim();
      List<String> parts = criterionNumber.split('.');

      if (parts.length < 2) {
        //print('⚠️ Invalid criterion number: $criterionNumber');
        continue;
      }

      String topicKey = '${parts[0]}.${parts[1]}'; // Extract first two parts

      List<String> documents = homeCubit.getDocumentsNames(
        criterionName: vision.criterionName,
        topicName: vision.topicName,
        visionName: vision.visionName,
      );

      totalEvidenceByTopic[topicKey] =
          (totalEvidenceByTopic[topicKey] ?? 0) + documents.length;

      //print(
      // '   Criterion: $criterionNumber → Topic: $topicKey (${documents.length} docs)');
    }

    //print('\n📊 Total Evidence By Topic: $totalEvidenceByTopic\n');

    // STEP 2: Count ASSIGNED evidence from ACTIVE TASKS
    //print('📋 STEP 2: Counting assigned tasks...');

    for (var task in tasks) {
      // ✅ FIX: Extract topic from task criteriaId (5.20.1 → 5.20)
      List<String> parts = task.criteriaId.split('.');

      if (parts.length < 2) {
        //print('⚠️ Invalid criteria ID: ${task.criteriaId}');
        continue;
      }

      String topicNumber = '${parts[0]}.${parts[1]}';

      tasksByTopic.putIfAbsent(topicNumber, () => []);
      tasksByTopic[topicNumber]!.add(task);

      //print('   Task: ${task.criteriaId} → Topic: $topicNumber');
    }

    //print(
    // '\n📊 Assigned Tasks By Topic: ${tasksByTopic.map((k, v) => MapEntry(k, v.length))}\n');

    // STEP 3: Determine status for EVERY topic
    //print('📋 STEP 3: Determining status for each topic...\n');

    totalEvidenceByTopic.forEach((topic, totalEvidence) {
      List<QiyasChampionEntity> topicTasks = tasksByTopic[topic] ?? [];
      int assignedCount = topicTasks.length;
      int unassignedCount = totalEvidence - assignedCount;

      //print('┌─────────────────────────────────────────────────────┐');
      //print('│ 📊 Topic: $topic');
      //print('├─────────────────────────────────────────────────────┤');
      //print('│ Total Evidence: $totalEvidence');
      //print('│ Assigned: $assignedCount');
      //print('│ Unassigned: $unassignedCount');
      //print('├─────────────────────────────────────────────────────┤');

      // STATE DETERMINATION LOGIC

      // CASE 1: UNASSIGNED - Zero assignments (GREY)
      if (assignedCount == 0) {
        topicAssignStatus[topic] = AssignStatus.unassigned;
        //print('│ ✅ Status: UNASSIGNED');
        //print('│ 🎨 Border: GREY');
      }
      // CASE 2: IN_PROGRESS - Partial assignments (ORANGE)
      else if (assignedCount > 0 && unassignedCount > 0) {
        topicAssignStatus[topic] = AssignStatus.inProgress;
        //print('│ ✅ Status: IN_PROGRESS ($assignedCount/$totalEvidence)');
        //print('│ 🎨 Border: ORANGE');
      }
      // CASE 3: All assigned - Check approval status
      else if (assignedCount == totalEvidence) {
        // Count submission statuses
        Map<EvidenceSubmissionStatus, int> statusCounts = {};

        for (var task in topicTasks) {
          EvidenceSubmissionStatus status = getTaskStatus(task);
          statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        }

        //print('│ Submissions: $statusCounts');

        int approvedCount =
            statusCounts[EvidenceSubmissionStatus.approved] ?? 0;

        // CASE 3A: APPROVED - All approved (GREEN)
        if (approvedCount == totalEvidence) {
          topicAssignStatus[topic] = AssignStatus.approved;
          //print('│ ✅ Status: APPROVED (all approved)');
          //print('│ 🎨 Border: GREEN');
        }
        // CASE 3B: ASSIGNED - All assigned, not all approved (YELLOW)
        else {
          topicAssignStatus[topic] = AssignStatus.assigned;
          //print(
          //      '│ ✅ Status: ASSIGNED ($approvedCount/$totalEvidence approved)');
          //print('│ 🎨 Border: YELLOW');
        }
      }
      // SAFETY: Should never happen
      else {
        //print('│ ⚠️  UNEXPECTED STATE!');
        topicAssignStatus[topic] = AssignStatus.unassigned;
      }

      //print('│ → Final: ${topicAssignStatus[topic]?.value}');
      //print('└─────────────────────────────────────────────────────┘\n');
    });

    // FINAL SUMMARY
    //print('╔════════════════════════════════════════════════════════╗');
    //print('║              FINAL STATUS MAP SUMMARY                  ║');
    //print('╠════════════════════════════════════════════════════════╣');

    topicAssignStatus.forEach((k, v) {
      switch (v) {
        case AssignStatus.unassigned:
          break;
        case AssignStatus.inProgress:
          break;
        case AssignStatus.assigned:
          break;
        case AssignStatus.approved:
          break;
      }
      //print('║ $statusEmoji $k → ${v.value}');
    });

    //print('╠════════════════════════════════════════════════════════╣');
    //print('║ 📊 Total Topics: ${topicAssignStatus.length}');
    //print('║ 📋 All Topic Keys: ${topicAssignStatus.keys.toList()}');
    //print('╚════════════════════════════════════════════════════════╝\n');

    emit(QiyasDashboardControllerVisionAndCriteriaDataLoaded());
  }

  /// function name: [getCriteriaAssignStatus]
  ///
  /// purpose: Determines assignment status for each criterion based on champion assignments
  ///
  /// LOGIC:
  /// - UNASSIGNED (Grey): No champions assigned
  /// - IN_PROGRESS (Orange): Some evidence assigned, some not
  /// - ASSIGNED (Yellow): All evidence assigned but not all approved
  /// - APPROVED (Green): All evidence assigned and all approved
  void getCriteriaAssignStatus() {
    criteriaAssignStatus = {};

    // Group tasks by criteria
    Map<String, List<QiyasChampionEntity>> tasksByCriteria = {};
    Map<String, int> totalEvidenceByCriteria = {};

    QiyasHomeCubit homeCubit = sl();

    //print('\n╔════════════════════════════════════════════════════════╗');
    //print('║  CRITERIA ASSIGN STATUS CALCULATION                    ║');
    //print('╚════════════════════════════════════════════════════════╝\n');

    // STEP 1: Count TOTAL evidence per criterion
    //print('📋 STEP 1: Counting evidence per criterion...');

    for (Visions vision in homeCubit.visionsList) {
      String criterionNumber = vision.criterionNumber.trim();

      List<String> documents = homeCubit.getDocumentsNames(
        criterionName: vision.criterionName,
        topicName: vision.topicName,
        visionName: vision.visionName,
      );

      totalEvidenceByCriteria[criterionNumber] =
          (totalEvidenceByCriteria[criterionNumber] ?? 0) + documents.length;

      //print('   Criterion: $criterionNumber (+${documents.length} docs)');
    }

    //print('\n📊 Total Evidence By Criteria: $totalEvidenceByCriteria\n');

    // STEP 2: Count ASSIGNED evidence from ACTIVE TASKS
    //print('📋 STEP 2: Counting assigned tasks per criterion...');

    for (var task in tasks) {
      String criteriaNumber = task.criteriaId.trim();

      tasksByCriteria.putIfAbsent(criteriaNumber, () => []);
      tasksByCriteria[criteriaNumber]!.add(task);

      //print('   Task: ${task.criteriaId} → Criterion: $criteriaNumber');
    }

    //print(
    //  '\n📊 Assigned Tasks By Criteria: ${tasksByCriteria.map((k, v) => MapEntry(k, v.length))}\n');

    // STEP 3: Determine status for EVERY criterion
    //print('📋 STEP 3: Determining status for each criterion...\n');

    totalEvidenceByCriteria.forEach((criterion, totalEvidence) {
      List<QiyasChampionEntity> criteriaTasks =
          tasksByCriteria[criterion] ?? [];
      int assignedCount = criteriaTasks.length;
      int unassignedCount = totalEvidence - assignedCount;

      //print('┌─────────────────────────────────────────────────────┐');
      //print('│ 📊 Criterion: $criterion');
      //print('├─────────────────────────────────────────────────────┤');
      //print('│ Total Evidence: $totalEvidence');
      //print('│ Assigned: $assignedCount');
      //print('│ Unassigned: $unassignedCount');
      //print('├─────────────────────────────────────────────────────┤');

      // STATE DETERMINATION LOGIC

      // CASE 1: UNASSIGNED - Zero assignments (GREY)
      if (assignedCount == 0) {
        criteriaAssignStatus[criterion] = AssignStatus.unassigned;
        //print('│ ✅ Status: UNASSIGNED');
        //print('│ 🎨 Border: GREY');
      }
      // CASE 2: IN_PROGRESS - Partial assignments (ORANGE)
      else if (assignedCount > 0 && unassignedCount > 0) {
        criteriaAssignStatus[criterion] = AssignStatus.inProgress;
        //print('│ ✅ Status: IN_PROGRESS ($assignedCount/$totalEvidence)');
        //print('│ 🎨 Border: ORANGE');
      }
      // CASE 3: All assigned - Check approval status
      else if (assignedCount == totalEvidence) {
        // Count submission statuses
        Map<EvidenceSubmissionStatus, int> statusCounts = {};

        for (var task in criteriaTasks) {
          EvidenceSubmissionStatus status = getTaskStatus(task);
          statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        }

        //print('│ Submissions: $statusCounts');

        int approvedCount =
            statusCounts[EvidenceSubmissionStatus.approved] ?? 0;

        // CASE 3A: APPROVED - All approved (GREEN)
        if (approvedCount == totalEvidence) {
          criteriaAssignStatus[criterion] = AssignStatus.approved;
          //print('│ ✅ Status: APPROVED (all approved)');
          //print('│ 🎨 Border: GREEN');
        }
        // CASE 3B: ASSIGNED - All assigned, not all approved (YELLOW)
        else {
          criteriaAssignStatus[criterion] = AssignStatus.assigned;
          //print(
          //   '│ ✅ Status: ASSIGNED ($approvedCount/$totalEvidence approved)');
          //print('│ 🎨 Border: YELLOW');
        }
      }
      // SAFETY: Should never happen
      else {
        //print('│ ⚠️  UNEXPECTED STATE!');
        criteriaAssignStatus[criterion] = AssignStatus.unassigned;
      }

      //print('│ → Final: ${criteriaAssignStatus[criterion]?.value}');
      //print('└─────────────────────────────────────────────────────┘\n');
    });

    // FINAL SUMMARY
    //print('╔════════════════════════════════════════════════════════╗');
    //print('║         CRITERIA STATUS MAP SUMMARY                    ║');
    //print('╠════════════════════════════════════════════════════════╣');

    criteriaAssignStatus.forEach((k, v) {
      switch (v) {
        case AssignStatus.unassigned:
          break;
        case AssignStatus.inProgress:
          break;
        case AssignStatus.assigned:
          break;
        case AssignStatus.approved:
          break;
      }
      //print('║ $statusEmoji $k → ${v.value}');
    });

    //print('╠════════════════════════════════════════════════════════╣');
    //print('║ 📊 Total Criteria: ${criteriaAssignStatus.length}');
    //print('║ 📋 All Criteria Keys: ${criteriaAssignStatus.keys.toList()}');
    //print('╚════════════════════════════════════════════════════════╝\n');

    emit(QiyasDashboardControllerVisionAndCriteriaDataLoaded());
  }

  Map<String, Map<EvidenceSubmissionStatus, int>> getAssignedTasksStatus(
      Map<String, int> topicEvidenceCount) {
    Map<String, Map<EvidenceSubmissionStatus, int>>
        topicAssignedTasksStatusCounter = {};
    //print("tasks length: ${tasks.length}");
    for (QiyasChampionEntity task in tasks) {
      String topicNumber =
          '${task.criteriaId.split('.').first}.${task.criteriaId.split('.')[1]}';
      topicEvidenceCount[topicNumber] =
          (topicEvidenceCount[topicNumber] ?? 0) - 1;

      EvidenceSubmissionStatus taskStatus = getTaskStatus(task);
      topicAssignedTasksStatusCounter.putIfAbsent(topicNumber, () => {});
      topicAssignedTasksStatusCounter[topicNumber]!
          .putIfAbsent(taskStatus, () => 0);
      topicAssignedTasksStatusCounter[topicNumber]![taskStatus] =
          (topicAssignedTasksStatusCounter[topicNumber]![taskStatus] ?? 0) + 1;
    }
    // //print('topic assigned $topicAssignedTasksStatusCounter');
    // //print(
    //     "topics status for 5.10 : ${topicAssignedTasksStatusCounter['5.10']}");
    return topicAssignedTasksStatusCounter;
  }

  /// CRITICAL FIX: Now uses lowercase for consistent email matching
  EvidenceSubmissionModel? getTaskLastSubmission(QiyasChampionEntity task) {
    String evidenceKey =
        '${task.criteriaId.trim()}-${task.documentNumber.trim()}';
    String championEmail = task.controlChampion.trim().toLowerCase();

    //print('\n🔍 SEARCHING FOR SUBMISSION:');
    //print('   Evidence Key: $evidenceKey');
    //print('   Champion Email (normalized): $championEmail');
    //print('   Task Criteria: ${task.criteriaId}');
    //print('   Task Document: ${task.documentNumber}');

    // Check if evidence key exists
    if (!submissionsByEvidenceId.containsKey(evidenceKey)) {
      //print('   ✗ Evidence key NOT found in map');
      //print('   Available keys: ${submissionsByEvidenceId.keys.toList()}');
      return null;
    }

    //print('   ✓ Evidence key found');
    //print(
    //   '   Champions for this evidence: ${submissionsByEvidenceId[evidenceKey]!.keys.toList()}');

    // Check if champion exists for this evidence
    if (!submissionsByEvidenceId[evidenceKey]!.containsKey(championEmail)) {
      //print('   ✗ Champion email NOT found for this evidence');
      return null;
    }

    EvidenceSubmissionModel? submissionModel =
        submissionsByEvidenceId[evidenceKey]![championEmail]?.firstOrNull;

    if (submissionModel != null) {
      //print('   ✓ Submission FOUND!');
      //print('   Submission ID: ${submissionModel.submissionId}');
      //print('   Status: ${submissionModel.submissionStatus.value}');
      //print('   Submitted By: ${submissionModel.submittedBy}');
    } else {
      //print('   ✗ No submission in list (empty list)');
    }

    return submissionModel;
  }
}
