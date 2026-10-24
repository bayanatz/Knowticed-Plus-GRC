/// ************************ FILE INFO ************************
/// File Name: qiyas_owner_core_cubit.dart
/// Author: Mohamed Elrashidy
/// Created At: 8/5/2025
library;

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_core/presentation/controller/owner_core_cubit.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/entities/task_overview.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_tasks/data/repository/champigan_tasks_repository.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_tasks/domain/use_cases/get_tasks_status_use_case.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';

part 'qiyas_owner_tasks_state.dart';

class QiyasOwnerTasksCubit extends Cubit<QiyasTasksState> {
  QiyasOwnerTasksCubit() : super(QiyasTasksInitial()) {
    initCubit();
  }
  OwnerCoreCubit ownerCoreCubit = sl();
  OwnerTasksRepository repository = OwnerTasksRepository();
  Map<EvidenceSubmissionStatus, List<TaskOverview>> taskStatusMap = {};
  EvidenceSubmissionStatus selectedStatus = EvidenceSubmissionStatus.all;
  TaskOverview? selectedTask;
  bool isShowDiscissions = false;
  TextEditingController rejectNotes = TextEditingController();
  List<EvidenceSubmissionModel> evidenceSubmissions = [];

  Future<void> initCubit() async {
    await getTasksStatus();
    _watch();
  }

  final LiveRefresh _live = LiveRefresh();

  /// Keeps the owner's task list (and an open task's submissions) live:
  /// the assignments, the submissions and the visions all feed it.
  void _watch() => _live.watchPaths([
        getBaseUrl(kQiyasChampionNameCollection),
        getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
        getBaseUrl(kVisionNameCollection),
      ], () async {
        await ownerCoreCubit.initCubit();
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

  /// Function Name: [getTasksStatus]
  ///
  /// purpose: Fetches the status of tasks assigned to the user in the Champigan system.
  Future<Either<Failure, dynamic>?> getTasksStatus() async {
    final response =
        await GetTasksStatusUseCase(ownerTasksRepository: repository).execute(
      tasks: ownerCoreCubit.ownerAccessList,
    );
    if (response.isLeft()) return response;
    taskStatusMap = response.getOrElse(() => null);
    debugPrint('taskStatusMap: $taskStatusMap');
    emit(QiyasTasksStatusUpdated());
    return null;
  }

  /// Function Name: [getTaskStatusByCriteriaNumber]
  ///
  /// purpose: show tasks with selected status type.
  ///
  /// parameters: [EvidenceSubmissionStatus] - [status] The criteria number to filter tasks.
  void updateSelectedStatus(EvidenceSubmissionStatus status) {
    selectedStatus = status;
    emit(QiyasTasksStatusUpdated());
  }

  /// Function Name: [selectTask]
  ///
  /// purpose: Selects a task from the list of tasks.
  ///
  /// parameters: [TaskOverview] - [task] The task to be selected.
  void selectTask(TaskOverview task) {
    selectedTask = task;
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
    //emit(QiyasChampiganTasksSubmissionsUpdated());
    //showLoadingIndicator();
    final response = await repository.getTaskSubmissions(
      criteriaNumber: selectedTask!.criteriaNumber,
      evidenceNumber: selectedTask!.evidenceNumber,
      champiganId: selectedTask!.championId!,
    );
    if (response.isLeft()) return;
    evidenceSubmissions = List<EvidenceSubmissionModel>.from(
        response.fold((_) => List<EvidenceSubmissionModel>.from([]), (r) => r));
    debugPrint('evidenceSubmissions: $evidenceSubmissions');
    //hideLoadingIndicator();
    emit(QiyasTasksSubmissionsUpdated());
  }

  Future<void> updateTaskStatus(
      {required String submissionId,
      required EvidenceSubmissionStatus status}) async {
    final response = await repository.updateTaskStatus(
      submissionId: submissionId,
      status: status,
      rejectNotes: (rejectNotes.text.isEmpty ||
              status != EvidenceSubmissionStatus.rejected)
          ? null
          : rejectNotes.text,
      ownerId: Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
    );

    if (response.isRight()) {
      emit(QiyasTasksInitial());
      getTaskSubmissions();
      getTasksStatus();
      Timer(const Duration(seconds: 2), () {
        emit(QiyasTasksInitial());
      });
    }
  }

  void initRejectionControllers() {
    rejectNotes.clear();
  }
}
