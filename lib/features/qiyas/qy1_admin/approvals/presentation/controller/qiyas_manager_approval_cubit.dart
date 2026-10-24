import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/data/repository/qiyas_manager_approvals_repository.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/entities/task_overview.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/domain/use_cases/get_tasks_status_use_cases.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_pic.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';

part 'qiyas_manager_approval_state.dart';

class QiyasManagerApprovalCubit extends Cubit<QiyasManagerApprovalState> {
  QiyasManagerApprovalCubit() : super(QiyasManagerApprovalInitial());

  QiyasManagerApprovalsRepository qiyasManagerApprovalsRepository =
      QiyasManagerApprovalsRepository();

  Map<EvidenceSubmissionStatus, List<TaskOverview>> taskStatusMap = {};
  EvidenceSubmissionStatus selectedStatus = EvidenceSubmissionStatus.all;
  TaskOverview? selectedTask;
  bool isShowDiscissions = false;
  List<EvidenceSubmissionModel> evidenceSubmissions = [];
  List<QiyasChampionEntity> championTasks = [];
  TextEditingController searchController = TextEditingController();
  List<TaskOverview> filteredTasks = [];
  DateTime? filterDate;
  TextEditingController dateController = TextEditingController();
  TextEditingController rejectionController = TextEditingController();

  /// Store mapping of championId to email for quick lookup
  Map<String, String> championIdToEmailMap = {};

  /// Get MainCoreEmployeeController instance
  MainCoreEmployeeController get _employeeController =>
      Get.find<MainCoreEmployeeController>();

  /// Function Name: [extractEmailFromChampionId]
  ///
  /// purpose: Extracts clean email from championId which may have extra numbers
  ///
  /// parameters: [String] - [championId] The raw champion ID from database
  ///
  /// return: [String] - Clean email without extra numbers
  String extractEmailFromChampionId(String championId) {
    // ChampionId format: "email@domain.com1768741298153762"
    // We need to extract just the email part

    // Method 1: Split by @ and reconstruct
    if (championId.contains('@')) {
      List<String> parts = championId.split('@');
      if (parts.length >= 2) {
        String localPart = parts[0]; // "ahmed_sami_1901"
        String domainPart = parts[1]; // "knowticedplus.com1768741298153762"

        // Remove numbers from domain part
        String cleanDomain = domainPart.replaceAll(RegExp(r'\d+$'), '');

        String cleanEmail = '$localPart@$cleanDomain';
        //print("  Extracted email: $cleanEmail from $championId");
        return cleanEmail.toLowerCase().trim();
      }
    }

    return championId.toLowerCase().trim();
  }

  /// Function Name: [isChampionSupervisedByCurrentUser]
  ///
  /// purpose: Checks if the champion is supervised by the current logged-in user
  ///
  /// parameters: [String] - [championId] The champion's employee ID/email to check
  ///
  /// return: [bool] - true if the champion reports to current user, false otherwise
  bool isChampionSupervisedByCurrentUser(String? championId) {
    if (championId == null || championId.isEmpty) {
      //print("⚠️ ChampionId is null or empty");
      return false;
    }

    // Get current logged-in user
    final currentUser = _employeeController.employeeEntity;
    if (currentUser == null || currentUser.email == null) {
      //print("⚠️ Current user not found or email is null");
      return false;
    }

    // Extract clean email from championId
    String cleanChampionEmail = championIdToEmailMap[championId] ??
        extractEmailFromChampionId(championId);

    //print("🔍 Supervision Check:");
    //print("  Raw Champion ID: $championId");
    //print("  Clean Champion Email: $cleanChampionEmail");
    //print("  Current Manager: ${currentUser.email}");

    // Try to find champion employee with case-insensitive search
    EmployeeEntityPro? championEmployee;

    // First try direct lookup
    championEmployee =
        _employeeController.getLocaleEmployee(cleanChampionEmail);

    // If not found, try case-insensitive search through all employees
    if (championEmployee == null) {
      //print("  Direct lookup failed, trying case-insensitive search...");

      for (var employee in _employeeController.allEmployeesEntities ?? []) {
        if (employee.email?.toLowerCase().trim() ==
            cleanChampionEmail.toLowerCase()) {
          championEmployee = employee;
          //print("  ✓ Found via case-insensitive search!");
          break;
        }
      }
    }

    if (championEmployee == null) {
      //print("  ❌ Champion employee not found after all attempts");
      //print("  Available employees: ${_employeeController.mapOfEmployeesWithEmailKey.keys.toList()}");
      return false;
    }

    //print("  Champion Found: ${championEmployee.email}");
    //print("  Champion's Supervisor: ${championEmployee.supervisor}");

    // Case-insensitive supervisor comparison
    bool isSupervisor = championEmployee.supervisor?.toLowerCase().trim() ==
        currentUser.email?.toLowerCase().trim();

    //print("  Result: ${isSupervisor ? '✅ IS SUPERVISED' : '❌ NOT SUPERVISED'}");

    return isSupervisor;
  }

  /// Function Name: [getTasksStatus]
  ///
  /// purpose: Fetches the status of tasks assigned to any champion.
  ///          NOW FILTERS by supervisor relationship
  Future<void> getTasksStatus() async {
    //print("\n=== Starting getTasksStatus ===");

    final result = await GetTasksStatusUseCases(
            repository: qiyasManagerApprovalsRepository)
        .execute(championTasks: championTasks);

    if (result.isLeft()) {
      //print("❌ Error fetching task status");
      return;
    }

    Map<EvidenceSubmissionStatus, List<TaskOverview>> allTasks =
        result.fold((_) => {}, (r) => r);

    //print("✓ Fetched ${allTasks.length} status categories");

    // Filter tasks based on supervisor relationship
    taskStatusMap = {};

    for (var entry in allTasks.entries) {
      EvidenceSubmissionStatus status = entry.key;
      List<TaskOverview> tasks = entry.value;

      // Filter tasks where championId is supervised by current user
      List<TaskOverview> supervisedTasks = tasks.where((task) {
        return isChampionSupervisedByCurrentUser(task.championId);
      }).toList();

      taskStatusMap[status] = supervisedTasks;

      //print("  Status: ${status.value}");
      //print("    Before filter: ${tasks.length}");
      //print("    After filter: ${supervisedTasks.length}");
    }

    //print("\n📊 Filter Summary:");
    //print("  Total tasks before: $totalTasksBeforeFilter");
    //print("  Total tasks after: $totalTasksAfterFilter");
    //print("  Filtered out: ${totalTasksBeforeFilter - totalTasksAfterFilter}");
    //print("=== getTasksStatus Complete ===\n");

    searchTasks();
  }

  /// Function Name: [getTaskStatusByCriteriaNumber]
  ///
  /// purpose: show tasks with selected status type.
  ///
  /// parameters: [EvidenceSubmissionStatus] - [status] The criteria number to filter tasks.
  void updateSelectedStatus(EvidenceSubmissionStatus status) {
    selectedStatus = status;
    searchTasks();
  }

  /// Function Name: [selectTask]
  ///
  /// purpose: Selects a task from the list of tasks.
  ///
  /// parameters: [TaskOverview] - [task] The task to be selected.
  void selectTask(TaskOverview task) {
    selectedTask = task;
    getTaskSubmissions();
  }

  /// Function Name: [toggleDiscussionsVisibility]
  ///
  /// purpose: Toggles the visibility of discussions related to the selected task.
  ///
  /// parameters: [bool] - [value] The value to set the visibility of discussions.
  void toggleDiscussionsVisibility(bool value) {
    isShowDiscissions = value;
    emit(SectionViewUpdated());
  }

  Future<void> getTaskSubmissions() async {
    evidenceSubmissions = [];
    final response = await qiyasManagerApprovalsRepository.getTaskSubmissions(
      criteriaNumber: selectedTask!.criteriaNumber,
      evidenceNumber: selectedTask!.evidenceNumber,
    );
    if (response.isLeft()) return;
    evidenceSubmissions = List<EvidenceSubmissionModel>.from(
        response.fold((_) => List<EvidenceSubmissionModel>.from([]), (r) => r));
    //print('evidenceSubmissions: $evidenceSubmissions');
    emit(QiyasTasksSubmissionsUpdated());
  }

  Future<void> initCubit() async {
    selectedStatus =
        EvidenceSubmissionStatus.all; // ✅ Reset to all on every init
    searchController.clear(); // ✅ Also clear search
    filterDate = null; // ✅ Also clear date filter
    dateController.clear();
    await getAssignedTasks();
    await getTasksStatus();
    _watch();
  }

  final LiveRefresh _live = LiveRefresh();

  /// Keeps the approvals list (and an open task's submissions) live without
  /// touching the filters the user picked.
  void _watch() => _live.watchPaths([
        getBaseUrl(kQiyasChampionNameCollection),
        getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
      ], () async {
        await getAssignedTasks();
        if (isClosed) return;
        await getTasksStatus();
        if (isClosed) return;
        if (selectedTask != null) await getTaskSubmissions();
      });

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  /// Function Name: [getAssignedTasks]
  ///
  /// purpose: Fetches the tasks assigned to champions.
  Future<void> getAssignedTasks() async {
    championTasks = [];
    championIdToEmailMap = {};

    final result =
        await qiyasManagerApprovalsRepository.getChampionAssignedTasks();
    if (result.isLeft()) return;

    championTasks =
        List<QiyasChampionEntity>.from(result.fold((_) => [], (r) => r));

    //print("\n=== Champion Tasks Loaded ===");
    //print("Total champions: ${championTasks.length}");

    // Build championId to email mapping
    for (var champion in championTasks) {
      String cleanEmail = extractEmailFromChampionId(champion.id);
      championIdToEmailMap[champion.id] = cleanEmail;

      //print("  Raw Champion ID: ${champion.id}");
      //print("  Clean Email: $cleanEmail");
    }

    //print("==============================\n");

    // Debug: //print current user and their supervised employees
    final currentUser = _employeeController.employeeEntity;
    if (currentUser != null) {
      //print("\n=== Current User Info ===");
      //print("Manager Email: ${currentUser.email}");
      //print("Supervised Employees:");

      for (var employee in _employeeController.allEmployeesEntities ?? []) {
        if (employee.supervisor?.toLowerCase().trim() ==
            currentUser.email?.toLowerCase().trim()) {
          //print("  - ${employee.email} (${employee.firstName} ${employee.lastName})");
        }
      }
      //print("=========================\n");
    }
  }

  /// Function Name: [searchTasks]
  ///
  /// purpose: Searches for tasks based on the provided search term.
  ///          NOW INCLUDES supervisor filtering
  ///
  /// parameters: [String] - [searchTerm] The term to search for in task titles.
  void searchTasks() {
    //print("\n=== Starting searchTasks ===");

    String searchTerm = searchController.text.trim().toLowerCase();
    //print("Search term: '$searchTerm'");
    //print("Selected status: ${selectedStatus.value}");
    //print("Filter date: ${filterDate != null ? DateFormat('yyyy-MM-dd').format(filterDate!) : 'None'}");

    filteredTasks = [];

    // Get tasks for selected status (already filtered by supervisor in getTasksStatus)
    List<TaskOverview> statusTasks = taskStatusMap[selectedStatus] ?? [];
    //print("Tasks for selected status: ${statusTasks.length}");

    // Apply search and date filters
    filteredTasks = statusTasks.where((task) {
      // Search filter
      bool matchesSearch = searchTerm.isEmpty ||
          task.visionName.toLowerCase().contains(searchTerm) ||
          task.criteriaName.toLowerCase().contains(searchTerm) ||
          task.topicName.toLowerCase().contains(searchTerm);

      // Date filter
      bool matchesDate = filterDate == null ||
          (task.submissionDate != null &&
              task.submissionDate!.year == filterDate!.year &&
              task.submissionDate!.month == filterDate!.month &&
              task.submissionDate!.day == filterDate!.day);

      return matchesSearch && matchesDate;
    }).toList();

    //print("Filtered tasks count: ${filteredTasks.length}");
    //print("=== searchTasks Complete ===\n");

    emit(QiyasTasksDataLoaded());
  }

  Future<void> selectDate(BuildContext context) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(
        context, [], DateTime.now(), CalendarDatePicker2Type.single);
    if (picked != null) {
      filterDate = picked.firstOrNull;
      if (filterDate != null) {
        filterDate = DateTime(
          filterDate!.year,
          filterDate!.month,
          filterDate!.day,
        );
      }

      dateController.text = DateFormat('d MMMM y', 'ar').format(filterDate!);
      searchTasks(); // Re-apply filters
    }
  }

  /// Function Name: [clearDateFilter]
  ///
  /// purpose: Clears the date filter and refreshes the task list
  void clearDateFilter() {
    filterDate = null;
    dateController.clear();
    searchTasks();
  }

  void initRejectionControllers() {
    rejectionController.text = '';
  }

  Future<void> updateTaskStatus({
    required String submissionId,
    required EvidenceSubmissionStatus status,
    String? reason,
  }) async {
    final result = await qiyasManagerApprovalsRepository.updateTaskStatus(
        submissionId: submissionId,
        status: status,
        reason: reason,
        currentUserId:
            Get.find<MainCoreEmployeeController>().employeeEntity!.email!);

    if (result.isRight()) {
      getTaskSubmissions();
      getTasksStatus();
    }
  }
}
