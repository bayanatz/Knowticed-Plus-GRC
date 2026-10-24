import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/ui/widgets/document_selector.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_control_card.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/add_new_visions.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ReassignPage extends StatelessWidget {
  ReassignPage({super.key});
  final QiyasCreateChampionControllerCubit controller = sl();
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    controller.searchByName("", removeChampions: false);

    bool isTablet = !kpIsPhoneLayout(context);
    return Form(
      key: formKey,
      child: BlocProvider.value(
        value: controller,
        child: Scaffold(
          body: SafeArea(
              child: Container(
            width: double.infinity,
            padding: EdgeInsetsDirectional.only(
                start: isTablet ? 30.sp : 15.sp, end: 15.sp),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(
                      screensTitles: isTablet
                          ? [
                              'قياس التحول الرقمي',
                              'إعادة التعيين سفير التحول الرقمي'
                            ]
                          : ['قياس التحول الرقمي', 'إعادة التعيين سفير']),
                  Expanded(
                      child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    padding: EdgeInsetsDirectional.all(15.sp),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              "سفير التحول الرقمي",
                              style: StyleText.fontSize18Weight500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                AppSearchTextField(
                                  hintText: "بحث",
                                  fillColor: AppColors.background,
                                  controller: searchController,
                                  onChanged: (value) {
                                    controller.searchByName(value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          BlocBuilder<ControlCoreCubit, ControlCoreState>(
                            bloc: controller,
                            buildWhen: (_, currentState) {
                              return currentState is OwnerDataChanged ||
                                  currentState is VisionsDataChanged;
                            },
                            builder: (context, state) {
                              return _championsBuilder(context);
                            },
                          ),
                          SizedBox(height: 20.sp),
                          BlocProvider<ControlCoreCubit>.value(
                            value: controller,
                            child:
                                BlocBuilder<ControlCoreCubit, ControlCoreState>(
                              bloc: controller,
                              builder: (context, state) {
                                if (controller.selectedPerson == null) {
                                  return const SizedBox.shrink();
                                }
                                return DocumentSelector();
                              },
                            ),
                          ),
                          SizedBox(height: 20.sp),
                          Text(
                            'تعيين المنظور',
                            style: StyleText.fontSize16Weight500,
                          ),
                          SizedBox(height: 20.sp),
                          AddNewVisions(isWithNote: true),
                        ],
                      ),
                    ),
                  )),
                  SizedBox(height: 20.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customButton(
                          width: 150,
                          title: 'إلغاء',
                          function: () {
                            Navigator.of(context).pop();
                          },
                          color: AppColors.secondaryButton,
                          textStyle: StyleText.fontSize16Weight400),
                      customButton(
                        width: 150,
                        title: 'إرسال',
                        function: () {
                          if (controller.selectedPerson == null) {
                            return;
                          }

                          final String capturedNewChampionEmail =
                              controller.selectedPerson!.id;

                          String capturedDocumentNames = '';
                          try {
                            final docs = controller.getUserUniqueDocuments();
                            if (docs.isNotEmpty) {
                              capturedDocumentNames = docs.join('، ');
                            }
                            debugPrint(
                                '✅ Captured reassign documents: $capturedDocumentNames');
                          } catch (e) {
                            debugPrint('⚠️ Error capturing documents: $e');
                          }

                          List<DateTime> capturedDeadlines = [];
                          try {
                            final reassignedChampions =
                                controller.getReassignedChampions();
                            for (var champion in reassignedChampions) {
                              capturedDeadlines
                                  .add(champion.documentSubmissionDate);
                            }
                            debugPrint(
                                '✅ Captured deadlines: $capturedDeadlines');
                          } catch (e) {
                            debugPrint('⚠️ Error capturing deadlines: $e');
                          }

                          debugPrint(
                              '✅ Captured new champion email: $capturedNewChampionEmail');

                          CustomDialogManager.showDialogFlow(
                            context: context,
                            confirmLottie:
                                "assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json",
                            confirmTitle: "إعادة التعيين سفير",
                            confirmSubtitle:
                                "هل أنت متأكد أنك تريد إعادة التعيين سفير؟",
                            confirmYesText: "نعم",
                            confirmNoText: "لا",
                            onConfirm: () async {
                              bool succeeded = false;
                              await controller.reassignChampions(onSuccess: () {
                                succeeded = true;
                                _sendReassignNotification(
                                  newChampionEmail: capturedNewChampionEmail,
                                  documentNames: capturedDocumentNames,
                                  deadlines: capturedDeadlines,
                                );
                              });
                              return succeeded;
                            },
                            successLottie:
                                'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
                            successTitle: 'تم اعادة التعيين بنجاح',
                            successSubtitle:
                                'لقد نجحت في اعادة التعيين المهام لهذا السفير',
                            onSuccessComplete: () {
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24.sp),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }

  Future<void> _sendReassignNotification({
    required String newChampionEmail,
    required String documentNames,
    required List<DateTime> deadlines,
  }) async {
    try {
      debugPrint('');
      debugPrint(
          '╔══════════════════════════════════════════════════════════╗');
      debugPrint('║     CHAMPION REASSIGNED — SENDING NOTIFICATIONS         ║');
      debugPrint(
          '╚══════════════════════════════════════════════════════════╝');

      debugPrint('🔄 Step 1: Getting sender email...');
      String senderEmail = '';
      try {
        senderEmail =
            Get.find<MainCoreEmployeeController>().employeeEntity!.email!;
        debugPrint('✅ Sender email: $senderEmail');
      } catch (e) {
        debugPrint('❌ Error getting sender email: $e');
        return;
      }

      if (newChampionEmail.isEmpty) {
        debugPrint('❌ ABORT: New champion email is empty');
        return;
      }
      debugPrint('✅ Receiver: $newChampionEmail');

      final String displayDocumentName =
          documentNames.isNotEmpty ? documentNames : 'المستندات المعاد تعيينها';

      // ✅ Send "Champion Reassigned" notification
      debugPrint('');
      debugPrint('🔄 Step 2: Sending Champion Reassigned notification...');

      String notificationTitleAr = 'تمت إعادة تعيين سفير التحول الرقمي';
      String notificationBodyAr =
          'تمت إعادة تعيين سفير التحول الرقمي للمستند $displayDocumentName رسمياً. سيتولى السفير المعيّن حديثاً المسؤولية الكاملة عن تنسيق الأدلة بشكل فوري. تم تحديث سجلات التعيين السابقة وفقاً لذلك.';

      try {
        final templateService = NotificationTemplateService();
        final template = await templateService.getTemplate(
          module: 'qiyas',
          eventType: 'champion_reassigned',
        );

        if (template != null) {
          debugPrint('   ✅ Template loaded');
          if (!template.isEnabled) {
            debugPrint('   ⚠️ Reassign notification DISABLED — skipping');
          } else {
            notificationTitleAr = template.pushTitleAr;
            notificationBodyAr = template.pushBodyAr
                .replaceAll('{DocumentName}', displayDocumentName)
                .replaceAll('{{DocumentName}}', displayDocumentName);

            final reassignModel = NotificationModelSystem(
              title: notificationTitleAr,
              body: notificationBodyAr,
              nameOfModule: 'qiyas',
              senderEmail: senderEmail,
              receiverEmail: newChampionEmail,
              nameOfPage: 'ReassignPage',
              isPinned: false,
              isRead: false,
              isClean: false,
            );

            try {
              final docId = await FirestoreNotificationService()
                  .uploadNotification(reassignModel);
              debugPrint('   ✅ Firestore uploaded! Doc ID: $docId');
            } catch (e) {
              debugPrint('   ❌ Firestore error: $e');
            }

            try {
              await NotificationServiceApp.sendNotification(
                notificationTitleAr,
                notificationBodyAr,
                newChampionEmail,
              );
              debugPrint('   ✅ FCM push sent');
            } catch (e) {
              debugPrint('   ❌ FCM error: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('   ❌ Template error: $e');
      }

      // ✅ Check deadlines — if ANY is within 14 days, send overdue
      debugPrint('');
      debugPrint('🔄 Step 3: Checking deadlines for overdue...');
      debugPrint('   Total deadlines to check: ${deadlines.length}');

      bool hasOverdue = false;
      final now = DateTime.now();

      for (var deadline in deadlines) {
        final daysUntilDeadline = deadline.difference(now).inDays;
        debugPrint(
            '   Deadline: $deadline — Days remaining: $daysUntilDeadline');
        if (daysUntilDeadline <= 14) {
          hasOverdue = true;
        }
      }

      if (hasOverdue) {
        debugPrint(
            '   ⚠️ At least one deadline is within 14 days — sending overdue notification!');

        String overdueTitleAr = 'تجاوز موعد تقديم الدليل — مطلوب إجراء فوري!';
        String overdueBodyAr =
            'تجاوز المستند $displayDocumentName الموعد النهائي للتقديم المحدد وتم تسجيله في النظام كمتأخر. يرجى اتخاذ إجراء فوري لتجنب مزيد من التصعيد وأي تأثير محتمل على درجة القياس لمنظمتكم.';

        try {
          final templateService = NotificationTemplateService();
          final template = await templateService.getTemplate(
            module: 'qiyas',
            eventType: 'evidence_overdue',
          );

          if (template != null && template.isEnabled) {
            overdueTitleAr = template.pushTitleAr;
            overdueBodyAr = template.pushBodyAr
                .replaceAll('{DocumentName}', displayDocumentName)
                .replaceAll('{{DocumentName}}', displayDocumentName);
            debugPrint('   ✅ Overdue template loaded');
          } else if (template != null && !template.isEnabled) {
            debugPrint('   ⚠️ Overdue notification DISABLED — skipping');
            debugPrint(
                '╚══════════════════════════════════════════════════════════╝');
            return;
          }
        } catch (e) {
          debugPrint('   ❌ Template error: $e — using defaults');
        }

        final overdueModel = NotificationModelSystem(
          title: overdueTitleAr,
          body: overdueBodyAr,
          nameOfModule: 'qiyas',
          senderEmail: senderEmail,
          receiverEmail: newChampionEmail,
          nameOfPage: 'ReassignPage',
          isPinned: false,
          isRead: false,
          isClean: false,
        );

        try {
          final docId = await FirestoreNotificationService()
              .uploadNotification(overdueModel);
          debugPrint('   ✅ Overdue Firestore uploaded! Doc ID: $docId');
        } catch (e) {
          debugPrint('   ❌ Overdue Firestore error: $e');
        }

        try {
          await NotificationServiceApp.sendNotification(
            overdueTitleAr,
            overdueBodyAr,
            newChampionEmail,
          );
          debugPrint('   ✅ Overdue FCM push sent');
        } catch (e) {
          debugPrint('   ❌ Overdue FCM error: $e');
        }
      } else {
        debugPrint(
            '   ✅ All deadlines are more than 14 days away — no overdue notification');
      }

      debugPrint('');
      debugPrint(
          '╔══════════════════════════════════════════════════════════╗');
      debugPrint(
          '║     ALL REASSIGN NOTIFICATIONS COMPLETE                  ║');
      debugPrint(
          '╚══════════════════════════════════════════════════════════╝');
      debugPrint('');
    } catch (e) {
      debugPrint('❌ Notification error: $e');
    }
  }

  Widget _championsBuilder(BuildContext context) {
    controller.showEmployees.removeWhere((element) {
      return element.id == controller.personDetails?.id;
    });

    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 72.sp,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          crossAxisCount:
              CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        ),
        itemCount: (controller.selectedPerson != null)
            ? 1
            : controller.showEmployees.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (controller.selectedPerson != null) {
            index =
                controller.showEmployees.indexOf(controller.selectedPerson!);
          }

          return InkWell(
            onTap: () {
              HapticController.low(); // list row: on the tap (X-117)
              controller.toggleChecked(index);
            },
            child: QiyasControlCard(
              index: index,
              onTap: null,
              person: controller.showEmployees[index],
            ),
          );
        });
  }
}
