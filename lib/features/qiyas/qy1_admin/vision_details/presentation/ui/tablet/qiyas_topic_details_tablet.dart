/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_topic_details_tablet.dart
/// Purpose: Displays the "Qiyas Topic Details" screen for pages layout with responsive features such as dynamic filtering,
///          approval details, and expandable content. It adapts to both portrait and landscape orientations for a user-friendly interface.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Modified: Jan/19/2026 - Added comprehensive debugging for status display
/// Modified: Feb/22/2026 - Added onSuccess callback to AssignEvidenceToChampionDialog for auto-refresh
/// Modified: Apr/30/2026 - Fixed accordion expand/collapse state to be independent per tab
/// Modified: Apr/30/2026 - Swapped تاريخ الاعتماد with الموعد النهائي للتسليم, added custom underline to toggle text
/// Description: This widget renders the pages layout for the "Qiyas Topic Details" screen, displaying topic details, transformation vision data,
///              approval containers, and metadata. It includes dynamic filtering, expandable sections, and responsive document display for different devices.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/employee_name_and_image.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/controller/qiyas_dashboard_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/vision_details/presentation/controller/vision_details_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/utils/task_helper.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/presentation/ui/widgets/qiyas_approvals_container_details.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/vision_details/presentation/ui/widgets/assign_evidenc_to_champion_dialog.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/vision_details/presentation/ui/widgets/tablet/qiyas_custom_row_vision_details.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';
import 'package:knowticed_plus/core/custom/cards/custom_title_value_widget.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class QiyasTopicDetailsTablet extends StatelessWidget {
  const QiyasTopicDetailsTablet(
      {super.key,
      required this.visionName,
      required this.topicName,
      required this.dashboardCubit});

  final String topicName;
  final String visionName;
  final QiyasDashboardControllerCubit dashboardCubit;

  void _openAssignDialog({
    required BuildContext context,
    required VisionDetailsCubit controller,
    required int documentationIndex,
  }) {
    final championCubit = sl<QiyasCreateChampionControllerCubit>();
    championCubit.clearAllControllers();
    championCubit.visionControllersList.last.text = visionName;
    championCubit.topicControllersList.last.text = topicName;
    championCubit.criterionControllersList.last.text =
        controller.selectedTopicCriteria[controller.selectedQiyasScreenIndex];
    championCubit.documentControllersList.last.text =
        controller.getDocuments()[documentationIndex];

    final String documentName = controller.getDocuments()[documentationIndex];

    final String expectedCriteriaId = sl<QiyasHomeCubit>()
        .getCriterionNumberByCriterionName(
            visionName: visionName,
            topicName: topicName,
            criteriaName: controller
                .selectedTopicCriteria[controller.selectedQiyasScreenIndex]);

    AssignEvidenceToChampionDialog().show(
      context,
      onSuccess: () async {
        debugPrint('');
        debugPrint(
            '╔══════════════════════════════════════════════════════════╗');
        debugPrint(
            '║     CHAMPION ASSIGNED — SENDING NOTIFICATION            ║');
        debugPrint(
            '╚══════════════════════════════════════════════════════════╝');

        // ✅ Step 0: Capture champion email BEFORE initCubit resets it
        debugPrint('🔄 Step 0: Capturing champion email before reset...');
        String capturedChampionEmail = '';
        try {
          final cubit = sl<QiyasCreateChampionControllerCubit>();
          if (cubit.selectedPerson != null &&
              cubit.selectedPerson!.id.isNotEmpty) {
            capturedChampionEmail = cubit.selectedPerson!.id;
            debugPrint('✅ Captured champion email: $capturedChampionEmail');
          } else {
            debugPrint('⚠️ selectedPerson already null at Step 0');
          }
        } catch (e) {
          debugPrint('❌ Error capturing champion email: $e');
        }

        // ✅ Step 1: Refresh dashboard data
        debugPrint('');
        debugPrint('🔄 Step 1: Refreshing dashboard data...');
        await dashboardCubit.getAllChampionsAssignments();
        debugPrint('✅ Dashboard refresh complete');
        debugPrint(
            '   Total tasks after refresh: ${dashboardCubit.tasks.length}');

        // ✅ Step 2: If champion email was not captured, find from refreshed tasks
        DateTime? capturedDeadline;

        if (capturedChampionEmail.isEmpty) {
          debugPrint('');
          debugPrint('🔄 Step 2a: Finding champion from refreshed tasks...');
          try {
            for (var task in dashboardCubit.tasks) {
              bool docMatch = false;
              try {
                docMatch = int.parse(task.documentNumber) == documentationIndex;
              } catch (_) {}
              bool criteriaMatch = task.criteriaId == expectedCriteriaId;

              if (docMatch && criteriaMatch) {
                capturedChampionEmail = task.controlChampion;
                capturedDeadline = task.documentSubmissionDate;
                debugPrint('   ✅ Found champion: $capturedChampionEmail');
                debugPrint('   ✅ Deadline: $capturedDeadline');
                break;
              }
            }
          } catch (e) {
            debugPrint('   ❌ Error searching tasks: $e');
          }
        } else {
          // ✅ Find deadline from refreshed tasks
          debugPrint('');
          debugPrint('🔄 Step 2: Finding deadline from tasks...');
          try {
            for (var task in dashboardCubit.tasks) {
              bool docMatch = false;
              try {
                docMatch = int.parse(task.documentNumber) == documentationIndex;
              } catch (_) {}
              bool criteriaMatch = task.criteriaId == expectedCriteriaId;

              if (docMatch && criteriaMatch) {
                capturedDeadline = task.documentSubmissionDate;
                debugPrint('   ✅ Deadline found: $capturedDeadline');
                break;
              }
            }
          } catch (e) {
            debugPrint('   ⚠️ Error finding deadline: $e');
          }
        }

        // ✅ Step 3: Get sender email
        debugPrint('');
        debugPrint('🔄 Step 3: Getting sender email...');
        String senderEmail = '';
        try {
          final employeeController = Get.find<MainCoreEmployeeController>();
          if (employeeController.employeeEntity != null &&
              employeeController.employeeEntity!.email != null &&
              employeeController.employeeEntity!.email!.isNotEmpty) {
            senderEmail = employeeController.employeeEntity!.email!;
            debugPrint('✅ Sender email: $senderEmail');
          }
        } catch (e) {
          debugPrint('❌ Error getting sender email: $e');
        }

        // ✅ Step 4: Validate emails
        debugPrint('');
        debugPrint('🔄 Step 4: Validating emails...');
        if (senderEmail.isEmpty) {
          debugPrint('❌ ABORT: Sender email is empty');
          return;
        }
        if (capturedChampionEmail.isEmpty) {
          debugPrint('❌ ABORT: Champion email is empty');
          return;
        }
        debugPrint('✅ Both emails valid');

        // ✅ Step 5: Send "Champion Assigned" notification
        debugPrint('');
        debugPrint('🔄 Step 5: Sending Champion Assigned notification...');
        await _sendQiyasNotification(
          senderEmail: senderEmail,
          receiverEmail: capturedChampionEmail,
          eventType: 'champion_assigned_to_evidence',
          documentName: documentName,
          defaultTitleAr: 'تم تعيين سفير التحول الرقمي',
          defaultBodyAr:
              'تم تعيين سفير التحول الرقمي للمستند $documentName. يتولى السفير الآن مسؤولية تنسيق تقديم الأدلة وإنجاز جميع الإجراءات المطلوبة المرتبطة بهذا المستند في غضون الإطار الزمني المحدد.',
          nameOfPage: 'QiyasTopicDetails',
        );

        // ✅ Step 6: Check if deadline is within 14 days → send overdue notification
        debugPrint('');
        debugPrint('🔄 Step 6: Checking deadline for overdue...');
        if (capturedDeadline != null) {
          final now = DateTime.now();
          final daysUntilDeadline = capturedDeadline.difference(now).inDays;
          debugPrint('   Deadline: $capturedDeadline');
          debugPrint('   Days until deadline: $daysUntilDeadline');

          if (daysUntilDeadline <= 14) {
            debugPrint(
                '   ⚠️ Deadline is within 14 days — sending overdue notification!');
            await _sendQiyasNotification(
              senderEmail: senderEmail,
              receiverEmail: capturedChampionEmail,
              eventType: 'evidence_overdue',
              documentName: documentName,
              defaultTitleAr: 'تجاوز موعد تقديم الدليل — مطلوب إجراء فوري!',
              defaultBodyAr:
                  'تجاوز المستند $documentName الموعد النهائي للتقديم المحدد وتم تسجيله في النظام كمتأخر. يرجى اتخاذ إجراء فوري لتجنب مزيد من التصعيد وأي تأثير محتمل على درجة القياس لمنظمتكم.',
              nameOfPage: 'QiyasTopicDetails',
            );
          } else {
            debugPrint(
                '   ✅ Deadline is more than 14 days away — no overdue notification needed');
          }
        } else {
          debugPrint('   ⚠️ No deadline found — skipping overdue check');
        }

        debugPrint('');
        debugPrint(
            '╔══════════════════════════════════════════════════════════╗');
        debugPrint(
            '║     ALL NOTIFICATIONS COMPLETE                          ║');
        debugPrint(
            '╚══════════════════════════════════════════════════════════╝');
        debugPrint('');
      },
    );
  }

  /// ✅ Reusable notification sender for Qiyas module
  Future<void> _sendQiyasNotification({
    required String senderEmail,
    required String receiverEmail,
    required String eventType,
    required String documentName,
    required String defaultTitleAr,
    required String defaultBodyAr,
    required String nameOfPage,
  }) async {
    try {
      debugPrint('');
      debugPrint('📤 Sending Qiyas notification: $eventType');

      String notificationTitleAr = defaultTitleAr;
      String notificationBodyAr = defaultBodyAr;

      try {
        final templateService = NotificationTemplateService();
        final template = await templateService.getTemplate(
          module: 'qiyas',
          eventType: eventType,
        );

        if (template != null) {
          debugPrint('   ✅ Template loaded');
          debugPrint('   Enabled: ${template.isEnabled}');

          if (!template.isEnabled) {
            debugPrint('   ⚠️ Notification DISABLED — skipping');
            return;
          }

          notificationTitleAr = template.pushTitleAr;
          notificationBodyAr = template.pushBodyAr
              .replaceAll('{DocumentName}', documentName)
              .replaceAll('{{DocumentName}}', documentName);
        } else {
          debugPrint('   ⚠️ No template — using defaults');
        }
      } catch (e) {
        debugPrint('   ❌ Template error: $e — using defaults');
      }

      debugPrint('   Title: $notificationTitleAr');
      debugPrint('   Sender: $senderEmail');
      debugPrint('   Receiver: $receiverEmail');

      final notificationModel = NotificationModelSystem(
        title: notificationTitleAr,
        body: notificationBodyAr,
        nameOfModule: 'qiyas',
        senderEmail: senderEmail,
        receiverEmail: receiverEmail,
        nameOfPage: nameOfPage,
        isPinned: false,
        isRead: false,
        isClean: false,
      );

      try {
        final docId = await FirestoreNotificationService()
            .uploadNotification(notificationModel);
        debugPrint('   ✅ Firestore uploaded! Doc ID: $docId');
      } catch (e) {
        debugPrint('   ❌ Firestore error: $e');
      }

      try {
        await NotificationServiceApp.sendNotification(
          notificationTitleAr,
          notificationBodyAr,
          receiverEmail,
        );
        debugPrint('   ✅ FCM push sent to: $receiverEmail');
      } catch (e) {
        debugPrint('   ❌ FCM error: $e');
      }
    } catch (e) {
      debugPrint('   ❌ Notification error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    VisionDetailsCubit controller = VisionDetailsCubit();
    controller.selectTopic(visionName, topicName);
    MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = !kpIsPhoneLayout(context);
    List<String> titlesTaps = controller.selectedTopicCriteria;
    Map<int, String> titlesMap = titlesTaps.asMap();

    return BlocProvider<VisionDetailsCubit>.value(
      value: controller,
      child: BlocBuilder<VisionDetailsCubit, VisionDetailsState>(
          buildWhen: (_, __) {
        return true;
      }, builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                  start: isTablet ? 30.sp : 15.sp, end: 15.sp),
              child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaginationAppBar(screensTitles: [
                        "قياس التحول الرقمي",
                        topicName,
                      ]),
                      Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              SizedBox(height: 30.sp),
                              GestureDetector(
                                onTap: () {
                                  HapticController
                                      .low(); // list row: on the tap (X-117)
                                  controller.toggleExpanded();
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (!controller.isExpanded)
                                      Text(
                                        "معلومات المنظور",
                                        style: StyleText.fontSize14Weight600
                                            .copyWith(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                    IntrinsicWidth(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            controller.isExpanded
                                                ? "إخفاء"
                                                : "اظهار",
                                            style: StyleText.fontSize14Weight600
                                                .copyWith(
                                              color: const Color(0xff1877F2),
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Container(
                                            height: 1.h,
                                            color: const Color(0xff1877F2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.sp),
                              controller.isExpanded == true
                                  ? const QiyasApprovalsContainerDetails(
                                      isTopicSelected: true)
                                  : const SizedBox.shrink(),
                              SizedBox(
                                  height: controller.isExpanded == true
                                      ? 25.sp
                                      : 15.sp),
                              Row(children: [
                                Expanded(
                                  child: CustomTabs(
                                    selectedValue:
                                        controller.selectedQiyasScreenIndex,
                                    onChanged:
                                        controller.updateSelectedCriteriaIndex,
                                    tabs: [
                                      for (int i = 0;
                                          i < titlesTaps.length;
                                          i++)
                                        titlesTaps[i],
                                    ],
                                  ),
                                ),
                              ]),
                              SizedBox(height: 32.sp),
                              Column(
                                children: [
                                  SizedBox(
                                    child: InkWell(
                                      onTap: () {
                                        HapticController
                                            .low(); // list row: on the tap (X-117)
                                        controller.toggleExpandedDetails(
                                            controller
                                                .selectedQiyasScreenIndex);
                                      },
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      child: Container(
                                        padding: EdgeInsets.all(10.sp),
                                        decoration: BoxDecoration(
                                            color: const Color(0xff797979),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                  titlesMap[controller
                                                          .selectedQiyasScreenIndex] ??
                                                      "",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: StyleText
                                                      .fontSize16Weight500
                                                      .copyWith(
                                                          color:
                                                              AppColors.white,
                                                          overflow: TextOverflow
                                                              .ellipsis)),
                                            ),
                                            SizedBox(width: 10.sp),
                                            RotatedBox(
                                                quarterTurns: controller
                                                                .isExpandedDetailsMap[
                                                            controller
                                                                .selectedQiyasScreenIndex] ==
                                                        true
                                                    ? 2
                                                    : 0,
                                                child: SvgPicture.asset(
                                                  "assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg",
                                                  colorFilter: ColorFilter.mode(
                                                      AppColors.white,
                                                      BlendMode.srcIn),
                                                  width: 12.sp,
                                                  height: 12.sp,
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 25.sp),
                                  controller.isExpandedDetailsMap[controller
                                              .selectedQiyasScreenIndex] ==
                                          true
                                      ? Column(
                                          children: [
                                            QiyasCustomRowVisionDetails(
                                              visionNumber: controller
                                                  .getCriteriaNumber(controller
                                                          .selectedTopicCriteria[
                                                      controller
                                                          .selectedQiyasScreenIndex]),
                                              visionValues: controller
                                                  .getCriteriaDetails(controller
                                                          .selectedTopicCriteria[
                                                      controller
                                                          .selectedQiyasScreenIndex]),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 15.sp),
                                child: Text("الوثائق الداعمة",
                                    style: StyleText.fontSize20Weight600
                                        .copyWith(color: AppColors.text)),
                              ),
                              BlocBuilder<QiyasDashboardControllerCubit,
                                      QiyasDashboardControllerState>(
                                  bloc: dashboardCubit,
                                  buildWhen: (previous, current) {
                                    return current
                                            is QiyasDashboardControllerLoadedState ||
                                        current
                                            is QiyasDashboardControllerInitial;
                                  },
                                  builder: (context, state) {
                                    return ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            controller.getDocuments().length,
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (context, documentationIndex) {
                                          QiyasChampionEntity? championEntity;
                                          EvidenceSubmissionModel?
                                              lastSubmission;

                                          try {
                                            debugPrint(
                                                '\n=== DOCUMENT INDEX: $documentationIndex ===');
                                            debugPrint(
                                                'Document Name: ${controller.getDocuments()[documentationIndex]}');

                                            String expectedCriteriaId = sl<
                                                    QiyasHomeCubit>()
                                                .getCriterionNumberByCriterionName(
                                                    visionName: visionName,
                                                    topicName: topicName,
                                                    criteriaName: controller
                                                            .selectedTopicCriteria[
                                                        controller
                                                            .selectedQiyasScreenIndex]);

                                            debugPrint(
                                                'Expected Criteria ID: $expectedCriteriaId');
                                            debugPrint(
                                                'Total tasks: ${dashboardCubit.tasks.length}');

                                            for (var task
                                                in dashboardCubit.tasks) {
                                              debugPrint(
                                                  'Task - Document: ${task.documentNumber}, Criteria: ${task.criteriaId}');
                                            }

                                            championEntity =
                                                dashboardCubit.tasks.firstWhere(
                                              (task) {
                                                bool docMatch = int.parse(
                                                        task.documentNumber) ==
                                                    documentationIndex;
                                                bool criteriaMatch =
                                                    task.criteriaId ==
                                                        expectedCriteriaId;

                                                debugPrint(
                                                    'Task Check - Doc: ${task.documentNumber} (match: $docMatch), Criteria: ${task.criteriaId} (match: $criteriaMatch)');

                                                return docMatch &&
                                                    criteriaMatch;
                                              },
                                            );

                                            debugPrint(
                                                '✓ Champion Entity Found!');
                                            debugPrint(
                                                '  Champion ID: ${championEntity.id}');
                                            debugPrint(
                                                '  Champion: ${championEntity.controlChampion}');

                                            lastSubmission = dashboardCubit
                                                .getTaskLastSubmission(
                                                    championEntity);

                                            if (lastSubmission != null) {
                                              debugPrint(
                                                  '✓ Last Submission Found!');
                                              debugPrint(
                                                  '  Submission ID: ${lastSubmission.submissionId}');
                                              debugPrint(
                                                  '  Submission Status (enum): ${lastSubmission.submissionStatus}');
                                              debugPrint(
                                                  '  Submission Status (value): ${lastSubmission.submissionStatus.value}');
                                              debugPrint(
                                                  '  Submission Status (color): ${lastSubmission.submissionStatus.color}');
                                              debugPrint(
                                                  '  Manager Response Time: ${lastSubmission.managerResponseTime}');
                                              debugPrint(
                                                  '  Approved Date: ${lastSubmission.approvedDate}');
                                            } else {
                                              debugPrint(
                                                  '✗ No submission found for this champion');
                                            }
                                          } catch (e, stackTrace) {
                                            debugPrint(
                                                '✗ ERROR finding champion/submission:');
                                            debugPrint('  Error: $e');
                                            debugPrint('  Stack: $stackTrace');
                                          }

                                          debugPrint(
                                              '\n--- DISPLAY DECISION ---');
                                          debugPrint(
                                              'Champion Entity: ${championEntity != null ? "EXISTS" : "NULL"}');
                                          debugPrint(
                                              'Last Submission: ${lastSubmission != null ? "EXISTS" : "NULL"}');

                                          if (lastSubmission != null) {
                                            debugPrint(
                                                '→ SHOWING: Submission Status Badge (${lastSubmission.submissionStatus.value})');
                                          } else if (championEntity != null) {
                                            debugPrint(
                                                '→ SHOWING: Uncompleted Status Badge');
                                          } else {
                                            debugPrint(
                                                '→ SHOWING: Assign Champion Button');
                                          }
                                          debugPrint('--- END DECISION ---\n');

                                          return isTablet
                                              ? Column(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.r),
                                                        color: AppColors.card,
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            10.sp),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          spacing: 10.sp,
                                                          children: [
                                                            CustomTitleValueWidget(
                                                                title:
                                                                    "ﻣﺴﺘﻨﺪﺍﺕ ﺍﻹﺛﺒﺎﺕ",
                                                                valueStyle: StyleText
                                                                    .fontSize12Weight400
                                                                    .copyWith(
                                                                        color: AppColors
                                                                            .secondaryText,
                                                                        fontSize: 10
                                                                            .sp),
                                                                value: controller
                                                                        .getDocuments()[
                                                                    documentationIndex]),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                userWidget(
                                                                    title:
                                                                        'السفير:',
                                                                    employeeId: (championEntity ==
                                                                            null)
                                                                        ? null
                                                                        : championEntity
                                                                            .controlChampion),
                                                                userWidget(
                                                                  title:
                                                                      'المدير:',
                                                                  employeeId: (championEntity !=
                                                                          null)
                                                                      ? TaskHelper()
                                                                          .getManagerId(
                                                                              championEntity.controlChampion)
                                                                      : null,
                                                                ),
                                                                userWidget(
                                                                  title:
                                                                      'المسؤول:',
                                                                  employeeId: (lastSubmission
                                                                              ?.managerId !=
                                                                          null)
                                                                      ? lastSubmission!
                                                                          .managerId
                                                                      : null,
                                                                )
                                                              ],
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                SizedBox(
                                                                  width: 250.sp,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    spacing:
                                                                        5.sp,
                                                                    children: [
                                                                      CustomTitleValueWidget(
                                                                          title:
                                                                              'تاريخ تقديم المستند',
                                                                          value: (lastSubmission?.submissionDate == null)
                                                                              ? "-"
                                                                              : intl.DateFormat('dd MMMM yyyy', 'ar').format(lastSubmission!.submissionDate!.toDate())),
                                                                      CustomTitleValueWidget(
                                                                          title:
                                                                              'الموعد النهائي للتسليم',
                                                                          value: (championEntity == null)
                                                                              ? "-"
                                                                              : intl.DateFormat('dd MMMM yyyy', 'ar').format(championEntity.documentSubmissionDate)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 250.sp,
                                                                  child: CustomTitleValueWidget(
                                                                      title:
                                                                          'تاريخ الاعتماد',
                                                                      value: (lastSubmission?.managerResponseTime == null || lastSubmission?.submissionStatus != EvidenceSubmissionStatus.approved)
                                                                          ? "-"
                                                                          : intl.DateFormat('dd MMMM yyyy', 'ar').format(lastSubmission!
                                                                              .approvedDate!
                                                                              .toDate())),
                                                                ),
                                                                // PRIORITY 1: Show submission status if exists
                                                                if (lastSubmission !=
                                                                    null)
                                                                  SizedBox(
                                                                    width:
                                                                        250.sp,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              140.sp,
                                                                          height:
                                                                              30.sp,
                                                                          padding:
                                                                              EdgeInsets.all(4.sp),
                                                                          decoration: BoxDecoration(
                                                                              border: Border.all(
                                                                                color: lastSubmission.submissionStatus.color,
                                                                                width: 1,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(6.r)),
                                                                          child:
                                                                              Row(
                                                                            spacing:
                                                                                4.sp,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              CircleAvatar(
                                                                                backgroundColor: lastSubmission.submissionStatus.color,
                                                                                child: SvgPicture.asset(
                                                                                  lastSubmission.submissionStatus.icon,
                                                                                  height: 12.sp,
                                                                                  width: 12.sp,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                lastSubmission.submissionStatus.value,
                                                                                textAlign: TextAlign.center,
                                                                                style: StyleText.fontSize12Weight400.copyWith(color: lastSubmission.submissionStatus.color),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                // PRIORITY 2: Show uncompleted if champion exists but no submission
                                                                else if (championEntity !=
                                                                    null)
                                                                  SizedBox(
                                                                    width:
                                                                        250.sp,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              140.sp,
                                                                          height:
                                                                              30.sp,
                                                                          padding:
                                                                              EdgeInsets.all(4.sp),
                                                                          decoration: BoxDecoration(
                                                                              border: Border.all(
                                                                                color: EvidenceSubmissionStatus.unCompleted.color,
                                                                                width: 1,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(6.r)),
                                                                          child:
                                                                              Row(
                                                                            spacing:
                                                                                4.sp,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              CircleAvatar(
                                                                                backgroundColor: EvidenceSubmissionStatus.unCompleted.color,
                                                                                child: SvgPicture.asset(
                                                                                  EvidenceSubmissionStatus.unCompleted.icon,
                                                                                  height: 12.sp,
                                                                                  width: 12.sp,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                EvidenceSubmissionStatus.unCompleted.value,
                                                                                textAlign: TextAlign.center,
                                                                                style: StyleText.fontSize12Weight400.copyWith(color: EvidenceSubmissionStatus.unCompleted.color),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                // PRIORITY 3: Show assign button if no champion
                                                                else if (Get.find<
                                                                        MainCoreEmployeeController>()
                                                                    .isHasPermission(
                                                                        module: Modules
                                                                            .qiyas,
                                                                        permission:
                                                                            null,
                                                                        section:
                                                                            QiyasPermissionsSections.assignedEvidence))
                                                                  SizedBox(
                                                                    width:
                                                                        250.sp,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        customButton(
                                                                          title:
                                                                              'تعيين سفير',
                                                                          textStyle: StyleText
                                                                              .fontSize14Weight400
                                                                              .copyWith(
                                                                            color:
                                                                                AppColors.textButton,
                                                                          ),
                                                                          function: () =>
                                                                              _openAssignDialog(
                                                                            context:
                                                                                context,
                                                                            controller:
                                                                                controller,
                                                                            documentationIndex:
                                                                                documentationIndex,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10.sp),
                                                  ],
                                                )
                                              : Column(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.r),
                                                        color: AppColors.card,
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            10.sp),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          spacing: 10.sp,
                                                          children: [
                                                            CustomTitleValueWidget(
                                                                title:
                                                                    "ﻣﺴﺘﻨﺪﺍﺕ ﺍﻹﺛﺒﺎﺕ ",
                                                                value: controller
                                                                        .getDocuments()[
                                                                    documentationIndex]),
                                                            userWidget(
                                                                title:
                                                                    'سفير التحول الرقمي:',
                                                                employeeId: (championEntity ==
                                                                        null)
                                                                    ? null
                                                                    : championEntity
                                                                        .controlChampion),
                                                            userWidget(
                                                              title: 'المدير:',
                                                              employeeId: (championEntity !=
                                                                      null)
                                                                  ? TaskHelper()
                                                                      .getManagerId(
                                                                          championEntity
                                                                              .controlChampion)
                                                                  : null,
                                                            ),
                                                            userWidget(
                                                              title: 'المسؤول:',
                                                              employeeId: (lastSubmission
                                                                          ?.managerId !=
                                                                      null)
                                                                  ? lastSubmission!
                                                                      .managerId
                                                                  : null,
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  spacing: 5.sp,
                                                                  children: [
                                                                    CustomTitleValueWidget(
                                                                        title:
                                                                            'تاريخ تقديم المستند',
                                                                        value: (lastSubmission?.submissionDate ==
                                                                                null)
                                                                            ? "-"
                                                                            : intl.DateFormat('dd MMMM yyyy', 'ar').format(lastSubmission!.submissionDate!.toDate())),
                                                                    CustomTitleValueWidget(
                                                                        title:
                                                                            'الموعد النهائي للتسليم',
                                                                        value: (championEntity ==
                                                                                null)
                                                                            ? "-"
                                                                            : intl.DateFormat('dd MMMM yyyy', 'ar').format(championEntity.documentSubmissionDate)),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            CustomTitleValueWidget(
                                                                title:
                                                                    'تاريخ الاعتماد',
                                                                value: (lastSubmission?.managerResponseTime ==
                                                                            null ||
                                                                        lastSubmission?.submissionStatus !=
                                                                            EvidenceSubmissionStatus
                                                                                .approved)
                                                                    ? "-"
                                                                    : intl.DateFormat(
                                                                            'dd MMMM yyyy',
                                                                            'ar')
                                                                        .format(lastSubmission!
                                                                            .approvedDate!
                                                                            .toDate())),
                                                            // PRIORITY 1: Show submission status if exists
                                                            if (lastSubmission !=
                                                                null)
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Container(
                                                                    width:
                                                                        140.sp,
                                                                    height:
                                                                        30.sp,
                                                                    padding: EdgeInsets
                                                                        .all(4
                                                                            .sp),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                            border:
                                                                                Border.all(
                                                                              color: lastSubmission.submissionStatus.color,
                                                                              width: 1,
                                                                            ),
                                                                            borderRadius: BorderRadius.circular(6.r)),
                                                                    child: Row(
                                                                      spacing:
                                                                          4.sp,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        CircleAvatar(
                                                                          backgroundColor: lastSubmission
                                                                              .submissionStatus
                                                                              .color,
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            lastSubmission.submissionStatus.icon,
                                                                            height:
                                                                                12.sp,
                                                                            width:
                                                                                12.sp,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          lastSubmission
                                                                              .submissionStatus
                                                                              .value,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: StyleText
                                                                              .fontSize12Weight400
                                                                              .copyWith(color: lastSubmission.submissionStatus.color),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            // PRIORITY 2: Show uncompleted if champion exists but no submission
                                                            else if (championEntity !=
                                                                null)
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Container(
                                                                    width:
                                                                        140.sp,
                                                                    height:
                                                                        30.sp,
                                                                    padding: EdgeInsets
                                                                        .all(4
                                                                            .sp),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                            border:
                                                                                Border.all(
                                                                              color: EvidenceSubmissionStatus.unCompleted.color,
                                                                              width: 1,
                                                                            ),
                                                                            borderRadius: BorderRadius.circular(6.r)),
                                                                    child: Row(
                                                                      spacing:
                                                                          4.sp,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        CircleAvatar(
                                                                          backgroundColor: EvidenceSubmissionStatus
                                                                              .unCompleted
                                                                              .color,
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            EvidenceSubmissionStatus.unCompleted.icon,
                                                                            height:
                                                                                12.sp,
                                                                            width:
                                                                                12.sp,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          EvidenceSubmissionStatus
                                                                              .unCompleted
                                                                              .value,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: StyleText
                                                                              .fontSize12Weight400
                                                                              .copyWith(color: EvidenceSubmissionStatus.unCompleted.color),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            // PRIORITY 3: Show assign button if no champion
                                                            else if (Get.find<
                                                                    MainCoreEmployeeController>()
                                                                .isHasPermission(
                                                                    module: Modules
                                                                        .qiyas,
                                                                    permission:
                                                                        null,
                                                                    section:
                                                                        QiyasPermissionsSections
                                                                            .assignedEvidence))
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  customButton(
                                                                    title:
                                                                        'تعيين سفير',
                                                                    function: () =>
                                                                        _openAssignDialog(
                                                                      context:
                                                                          context,
                                                                      controller:
                                                                          controller,
                                                                      documentationIndex:
                                                                          documentationIndex,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10.sp),
                                                  ],
                                                );
                                        });
                                  })
                            ])),
                      ),
                      SizedBox(height: 20.sp),
                    ],
                  )),
            ),
          ),
        );
      }),
    );
  }

  Widget userWidget({required String title, required String? employeeId}) {
    debugPrint('User Widget - Title: $title, Employee ID: $employeeId');
    return SizedBox(
      width: 250.sp,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryBlack)
                  .copyWith(color: AppColors.text)),
          SizedBox(width: 5.sp),
          EmployeeNameAndImage(employeeId: employeeId)
        ],
      ),
    );
  }
}
