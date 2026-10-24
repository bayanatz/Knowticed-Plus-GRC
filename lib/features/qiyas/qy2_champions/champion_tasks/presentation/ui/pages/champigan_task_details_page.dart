import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/presentation/controller/qiyas_champigan_tasks_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/comment_section/presentation/presentation/ui/widgets/comment_section.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/utils/task_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/presentation/ui/widgets/submission_details.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/presentation/ui/widgets/task_details_overview.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/presentation/ui/widgets/upload_evidence.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_log_service.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';

class ChampiganTaskDetailsPage extends StatelessWidget {
  ChampiganTaskDetailsPage({super.key});

  final QiyasChampiganTasksCubit controller = sl();

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context); // Check if tablet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getTaskSubmissions();
      QiyasLogService.log('qiyas champion task details');
    });
    return BlocProvider<QiyasChampiganTasksCubit>.value(
      value: controller,
      child: Scaffold(
        body: SafeArea(
            child: Directionality(
                textDirection: TextDirection.rtl,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsetsDirectional.only(
                      start: isTablet ? 30.sp : 15.sp, end: 15.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaginationAppBar(screensTitles: [
                        'قياس التحول الرقمي',
                        'المعايير المكلفه',
                        controller.selectedTask?.visionName ?? ""
                      ]),
                      TaskDetailsOverview(
                        taskOverview: controller.selectedTask!,
                      ),
                      SizedBox(height: 20.sp),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'الموافقات',
                            style: StyleText.fontSize20Weight500,
                          ),
                          const Spacer(),
                          BlocBuilder<QiyasChampiganTasksCubit,
                              QiyasTasksState>(
                            buildWhen: (_, currentState) {
                              return currentState is SectionViewUpdated;
                            },
                            builder: (context, state) {
                              return Container(
                                padding: EdgeInsets.all(4.sp),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(4.sp),
                                ),
                                child: Row(
                                  children: [
                                    customButton(
                                      title: 'تقديمات',
                                      function: () {
                                        controller
                                            .toggleDiscussionsVisibility(false);
                                      },
                                      color: !controller.isShowDiscissions
                                          ? AppColors.primary
                                          : AppColors.card,
                                      textStyle: StyleText.fontSize16Weight400
                                          .copyWith(
                                              color: !controller
                                                      .isShowDiscissions
                                                  ? AppColors.textButton
                                                  : AppColors.secondaryText),
                                    ),
                                    customButton(
                                      title: 'الاستفسارات',
                                      function: () {
                                        controller
                                            .toggleDiscussionsVisibility(true);
                                      },
                                      color: controller.isShowDiscissions
                                          ? AppColors.primary
                                          : AppColors.card,
                                      textStyle: StyleText.fontSize16Weight500
                                          .copyWith(
                                              color: AppColors.blackButton)
                                          .copyWith(
                                              color: controller
                                                      .isShowDiscissions
                                                  ? AppColors.textButton
                                                  : AppColors.secondaryText),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8.sp),
                      BlocBuilder<QiyasChampiganTasksCubit, QiyasTasksState>(
                          buildWhen: (_, currentState) {
                        return true;
                      }, builder: (context, state) {
                        if (state is QiyasTasksEvidenceSubmitted) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // The success dialog is shown by the
                            // CustomDialogManager.showDialogFlow in
                            // UploadEvidenceDialog, so it is not repeated here.
                            // ✅ Send notification to manager
                            _sendEvidenceNotification(controller);
                          });
                        }
                        return controller.isShowDiscissions
                            ? CommentSection(
                                criteriaNumber:
                                    controller.selectedTask!.criteriaNumber,
                                evidenceNumber:
                                    controller.selectedTask!.evidenceNumber)
                            : controller.evidenceSubmissions.isEmpty
                                ? UploadEvidence()
                                : SubmissionDetails(
                                    isChampion: true,
                                    isManager: false,
                                    isOwner: false,
                                    submissions: controller.evidenceSubmissions,
                                  );
                      }),
                      SizedBox(height: 20.sp),
                    ],
                  ),
                ))),
      ),
    );
  }

  Future<void> _sendEvidenceNotification(
      QiyasChampiganTasksCubit controller) async {
    try {
      debugPrint('');
      debugPrint(
          '╔══════════════════════════════════════════════════════════╗');
      debugPrint('║     EVIDENCE SUBMITTED — SENDING NOTIFICATION           ║');
      debugPrint(
          '╚══════════════════════════════════════════════════════════╝');

      final String championEmail =
          Get.find<MainCoreEmployeeController>().employeeEntity!.email!;
      debugPrint('✅ Champion email: $championEmail');

      final String managerEmail =
          TaskHelper().getManagerId(championEmail) ?? '';
      debugPrint('   Manager email: $managerEmail');

      if (managerEmail.isEmpty) {
        debugPrint('❌ ABORT: Manager email is empty');
        return;
      }

      String documentName = '';
      try {
        documentName = TaskHelper().getEvidenceName(
          criteriaNumber: controller.selectedTask!.criteriaNumber,
          evidenceNumber: controller.selectedTask!.evidenceNumber,
        );
        debugPrint('✅ Document name: $documentName');
      } catch (e) {
        documentName = 'مستند ${controller.selectedTask!.evidenceNumber}';
        debugPrint('⚠️ Using fallback name: $documentName');
      }

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
          debugPrint('✅ Template loaded');
          debugPrint('   Enabled: ${template.isEnabled}');

          if (!template.isEnabled) {
            debugPrint('⚠️ Notification DISABLED — skipping');
            return;
          }

          notificationTitleAr = template.pushTitleAr;
          notificationBodyAr = template.pushBodyAr
              .replaceAll('{DocumentName}', documentName)
              .replaceAll('{{DocumentName}}', documentName);
        } else {
          debugPrint('⚠️ No template — using defaults');
        }
      } catch (e) {
        debugPrint('❌ Template error: $e — using defaults');
      }

      debugPrint('   Title: $notificationTitleAr');
      debugPrint('   Body: $notificationBodyAr');
      debugPrint('   Sender: $championEmail');
      debugPrint('   Receiver: $managerEmail');

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

      try {
        final docId = await FirestoreNotificationService()
            .uploadNotification(notificationModel);
        debugPrint('✅ Firestore notification uploaded! Doc ID: $docId');
      } catch (e) {
        debugPrint('❌ Firestore error: $e');
      }

      try {
        await NotificationServiceApp.sendNotification(
          notificationTitleAr,
          notificationBodyAr,
          managerEmail,
        );
        debugPrint('✅ FCM push sent to: $managerEmail');
      } catch (e) {
        debugPrint('❌ FCM error: $e');
      }

      debugPrint(
          '╚══════════════════════════════════════════════════════════╝');
    } catch (e) {
      debugPrint('❌ Notification error: $e');
    }
  }
}
