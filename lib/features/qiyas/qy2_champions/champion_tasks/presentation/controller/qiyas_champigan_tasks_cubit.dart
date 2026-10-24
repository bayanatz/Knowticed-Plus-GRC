/// ************************ FILE INFO ************************
/// File Name: qiyas_owner_core_cubit.dart
/// Author: Mohamed Elrashidy
/// Created At: 8/5/2025
library;

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champigan_core/presentation/controller/champigan_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/data/repository/champigan_tasks_repository.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/domain/use_cases/get_tasks_status_use_case.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/entities/task_overview.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/utils/task_helper.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';
part 'qiyas_champigan_tasks_state.dart';

class QiyasChampiganTasksCubit extends Cubit<QiyasTasksState> {
  QiyasChampiganTasksCubit() : super(QiyasTasksInitial()) {
    initCubit();
  }
  ChampiganCoreCubit champiganCoreCubit = sl();
  ChampiganTasksRepository repository = ChampiganTasksRepository();
  Map<EvidenceSubmissionStatus, List<TaskOverview>> taskStatusMap = {};
  EvidenceSubmissionStatus selectedStatus = EvidenceSubmissionStatus.all;
  TaskOverview? selectedTask;
  bool isShowDiscissions = false;
  File? selectedFile;
  double? fileSize;
  TextEditingController uploadNotesController = TextEditingController();
  List<EvidenceSubmissionModel> evidenceSubmissions = [];

  Future<void> initCubit() async {
    await getTasksStatus();
    _watch();
  }

  final LiveRefresh _live = LiveRefresh();

  /// Keeps the champion's task list (and an open task's submissions) live:
  /// the assignments, the submissions and the visions all feed it.
  void _watch() => _live.watchPaths([
        getBaseUrl(kQiyasChampionNameCollection),
        getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
        getBaseUrl(kVisionNameCollection),
      ], () async {
        await champiganCoreCubit.initCubit();
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
            criteriaNumbers: champiganCoreCubit.champiganAccessList,
            champiganId:
                Get.find<MainCoreEmployeeController>().employeeEntity!.email!);
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

  /// Function Name: [initUploadControllers]
  ///
  /// purpose: Initializes the upload controllers by clearing the notes controller and resetting the selected file.
  void initUploadControllers() {
    uploadNotesController.clear();
    selectedFile = null;
  }

  /// Function Name: [selectDocument]
  ///
  void selectDocument() async {
    FilePickerResult? file = await FilePicker.platform.pickFiles();
    if (file != null) {
      selectedFile = File(file.files.single.path!);
      int size = await selectedFile!.length();
      fileSize = size / (1024 * 1024);
    } else {
      selectedFile = null;
    }

    emit(QiyasTasksFileSelected());
  }

  /// Function Name: [removeSelectedFile]
  ///
  /// purpose: Removes the currently selected file.
  ///
  void removeSelectedFile() {
    selectedFile = null;
    fileSize = null;
    emit(QiyasTasksFileSelected());
  }

  /// Function Name: [submitEvidence]
  ///
  /// purpose: Uploads the evidence for the selected task.

  /// Function Name: [submitEvidence]
  ///
  /// purpose: Uploads the evidence for the selected task and sends notification to manager.
  /// Function Name: [submitEvidence]
  ///
  /// purpose: Uploads the evidence for the selected task and sends notification to manager.
  Future<void> submitEvidence() async {
    if (selectedFile == null) {
      debugPrint('❌ No file selected');
      return;
    }

    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════╗');
    debugPrint('║              SUBMITTING EVIDENCE                         ║');
    debugPrint('╚══════════════════════════════════════════════════════════╝');

    // Step 1: Show loading state
    debugPrint('🔄 Step 1: Emitting loading state...');
    emit(QiyasTasksUploading());

    // Step 2: Upload file
    debugPrint('🔄 Step 2: Uploading file to Firebase Storage...');
    debugPrint('   File: ${selectedFile!.path}');
    debugPrint('   Criteria: ${selectedTask!.criteriaNumber}');
    debugPrint('   Evidence: ${selectedTask!.evidenceNumber}');

    final response = await repository.uploadEvidence(
      criteriaNumber: selectedTask!.criteriaNumber,
      evidenceNumber: selectedTask!.evidenceNumber,
      file: selectedFile!,
      notes: uploadNotesController.text,
      championId: Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
    );

    // Step 3: Check response
    if (response.isLeft()) {
      debugPrint('❌ Upload failed!');
      final failure = response.fold((l) => l, (r) => null);
      debugPrint('   Error: ${failure?.message}');
      emit(QiyasTasksUploadError(failure?.message ?? 'Upload failed'));
      return;
    }

    debugPrint('✅ Upload successful!');

    // Step 4: Refresh submissions FIRST (before showing dialog)
    debugPrint('🔄 Step 3: Refreshing submissions...');
    await getTaskSubmissions();
    debugPrint('✅ Submissions refreshed: ${evidenceSubmissions.length} found');

    // Step 5: Refresh task status
    debugPrint('🔄 Step 4: Refreshing task status...');
    await getTasksStatus();
    debugPrint('✅ Task status refreshed');

    // Step 6: Send notification (async, don't block UI)
    debugPrint('🔄 Step 5: Sending notification to manager...');
    _sendEvidenceSubmittedNotification().then((_) {
      debugPrint('✅ Notification sent');
    }).catchError((e) {
      debugPrint('⚠️ Notification error (non-blocking): $e');
    });

    // Step 7: Clear upload form
    debugPrint('🔄 Step 6: Clearing upload form...');
    initUploadControllers();

    // Step 8: Emit success state (THIS is what triggers the dialog)
    debugPrint('🔄 Step 7: Emitting success state...');
    emit(QiyasTasksEvidenceSubmitted());

    debugPrint('╔══════════════════════════════════════════════════════════╗');
    debugPrint('║           EVIDENCE SUBMISSION COMPLETE                   ║');
    debugPrint('╚══════════════════════════════════════════════════════════╝');
    debugPrint('');

    // Step 9: Reset to initial state after dialog has shown
    Timer(const Duration(seconds: 3), () {
      debugPrint('🔄 Resetting to initial state...');
      emit(QiyasTasksInitial());
    });
  }

  /// ✅ NEW: Send notification to manager when evidence is submitted
  Future<void> _sendEvidenceSubmittedNotification() async {
    try {
      debugPrint('');
      debugPrint(
          '╔══════════════════════════════════════════════════════════╗');
      debugPrint('║     EVIDENCE SUBMITTED — SENDING NOTIFICATION           ║');
      debugPrint(
          '╚══════════════════════════════════════════════════════════╝');

      // ✅ Step 1: Get champion (sender) email
      debugPrint('🔄 Step 1: Getting champion (sender) email...');
      final String championEmail =
          Get.find<MainCoreEmployeeController>().employeeEntity!.email!;
      debugPrint('✅ Champion email: $championEmail');

      // ✅ Step 2: Get manager (receiver) email
      debugPrint('');
      debugPrint('🔄 Step 2: Getting manager (receiver) email...');
      final String managerEmail =
          TaskHelper().getManagerId(championEmail) ?? '';
      debugPrint('   Manager email from TaskHelper: $managerEmail');

      if (managerEmail.isEmpty) {
        debugPrint(
            '❌ ABORT: Manager email is empty — cannot send notification');
        debugPrint('   Champion email used for lookup: $championEmail');
        debugPrint(
            '╚══════════════════════════════════════════════════════════╝');
        return;
      }
      debugPrint('✅ Manager email: $managerEmail');

      // ✅ Step 3: Get document/evidence name
      debugPrint('');
      debugPrint('🔄 Step 3: Getting document name...');
      String documentName = '';
      try {
        documentName = TaskHelper().getEvidenceName(
          criteriaNumber: selectedTask!.criteriaNumber,
          evidenceNumber: selectedTask!.evidenceNumber,
        );
        debugPrint('✅ Document name: $documentName');
      } catch (e) {
        debugPrint('⚠️ Error getting evidence name: $e');
        documentName = 'مستند ${selectedTask!.evidenceNumber}';
        debugPrint('   Using fallback name: $documentName');
      }

      // ✅ Step 4: Load notification template
      debugPrint('');
      debugPrint('🔄 Step 4: Loading notification template...');
      String notificationTitleAr = 'تم إرسال الدليل للمراجعة';
      String notificationBodyAr =
          'تم تقديم المستند $documentName بنجاح من قبل سفير التحول الرقمي المعيّن وهو حالياً قيد المراجعة الرسمية من قبل المشرف المختص. سيتم إرسال تذكير تلقائي في حال عدم اتخاذ أي إجراء خلال المدة المحددة.';

      try {
        final templateService = NotificationTemplateService();
        final template = await templateService.getTemplate(
          module: 'qiyas',
          eventType: 'evidence_submitted_for_review',
        );

        if (template != null) {
          debugPrint('✅ Template loaded from Firebase');
          debugPrint('   Subject AR: ${template.pushTitleAr}');
          debugPrint('   Body AR: ${template.pushBodyAr}');
          debugPrint('   Is Enabled: ${template.isEnabled}');
          debugPrint(
              '   Selected Types: ${template.selectedNotificationTypes}');

          if (!template.isEnabled) {
            debugPrint('⚠️ Notification DISABLED for this event — skipping');
            debugPrint(
                '╚══════════════════════════════════════════════════════════╝');
            return;
          }

          notificationTitleAr = template.pushTitleAr;
          notificationBodyAr = template.pushBodyAr
              .replaceAll('{DocumentName}', documentName)
              .replaceAll('{{DocumentName}}', documentName);

          debugPrint('✅ Variables replaced in template');
          debugPrint('   Title: $notificationTitleAr');
          debugPrint('   Body: $notificationBodyAr');
        } else {
          debugPrint('⚠️ No template found — using hardcoded defaults');
        }
      } catch (e) {
        debugPrint('❌ Error loading template: $e — using defaults');
      }

      // ✅ Step 5: Build and upload Firestore notification
      debugPrint('');
      debugPrint('🔄 Step 5: Building and uploading notification...');
      final notificationModel = NotificationModelSystem(
        title: notificationTitleAr,
        body: notificationBodyAr,
        nameOfModule: 'qiyas',
        senderEmail: championEmail,
        receiverEmail: managerEmail,
        nameOfPage: 'ChampiganTaskDetails',
        isPinned: false,
        isRead: false,
        isClean: false,
      );

      debugPrint('   Title: ${notificationModel.title}');
      debugPrint('   Body: ${notificationModel.body}');
      debugPrint('   Sender (Champion): ${notificationModel.senderEmail}');
      debugPrint('   Receiver (Manager): ${notificationModel.receiverEmail}');
      debugPrint('   Module: ${notificationModel.nameOfModule}');
      debugPrint('   Page: ${notificationModel.nameOfPage}');

      try {
        final notificationService = FirestoreNotificationService();
        final docId =
            await notificationService.uploadNotification(notificationModel);

        if (docId != null) {
          debugPrint('✅ Firestore notification uploaded! Doc ID: $docId');
        } else {
          debugPrint('❌ Firestore notification upload returned null');
        }
      } catch (e) {
        debugPrint('❌ Error uploading Firestore notification: $e');
      }

      // ✅ Step 6: Send FCM push notification
      debugPrint('');
      debugPrint('🔄 Step 6: Sending FCM push notification...');
      try {
        await NotificationServiceApp.sendNotification(
          notificationTitleAr,
          notificationBodyAr,
          managerEmail,
        );
        debugPrint('✅ FCM push notification sent to manager: $managerEmail');
      } catch (e) {
        debugPrint('❌ Error sending FCM push: $e');
      }

      debugPrint('');
      debugPrint(
          '╔══════════════════════════════════════════════════════════╗');
      debugPrint(
          '║     EVIDENCE SUBMITTED NOTIFICATION COMPLETE             ║');
      debugPrint(
          '╚══════════════════════════════════════════════════════════╝');
      debugPrint('');
    } catch (e) {
      debugPrint('❌ Error in _sendEvidenceSubmittedNotification: $e');
    }
  }

  Future<void> getTaskSubmissions() async {
    evidenceSubmissions = [];
    //emit(QiyasChampiganTasksSubmissionsUpdated());
    //showLoadingIndicator();
    final response = await repository.getTaskSubmissions(
      criteriaNumber: selectedTask!.criteriaNumber,
      evidenceNumber: selectedTask!.evidenceNumber,
      champiganId:
          Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
    );
    if (response.isLeft()) return;
    evidenceSubmissions = List<EvidenceSubmissionModel>.from(
        response.fold((_) => List<EvidenceSubmissionModel>.from([]), (r) => r));
    debugPrint('evidenceSubmissions: $evidenceSubmissions');
    //hideLoadingIndicator();
    emit(QiyasTasksSubmissionsUpdated());
  }
}
