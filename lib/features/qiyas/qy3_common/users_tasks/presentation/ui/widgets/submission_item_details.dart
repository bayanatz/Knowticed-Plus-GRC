import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/presentation/ui/widgets/manager_confirm_dialog.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/attatchment_widget.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/employee_name_and_image.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/presentation/ui/widgets/upload_evidence_dialog.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_tasks/presentation/ui/widgets/confirm_dialog.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/utils/task_helper.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';
import 'package:knowticed_plus/core/custom/cards/custom_title_value_widget.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class SubmissionItemDetails extends StatelessWidget {
  const SubmissionItemDetails(
      {required this.isOwner,
      required this.isChampion,
      required this.isManager,
      required this.submission,
      required this.isFirst,
      super.key});
  final EvidenceSubmissionModel submission;
  final bool isOwner;
  final bool isChampion;
  final bool isFirst;
  final bool isManager;

  // ─────────────────────────────────────────────
  // NOTIFICATION HELPER
  // ─────────────────────────────────────────────

  Future<void> _sendStatusNotificationToChampion(
      EvidenceSubmissionStatus status) async {
    try {
      debugPrint('');
      debugPrint(
          '╔══════════════════════════════════════════════════════════╗');
      debugPrint('║   STATUS UPDATED — SENDING NOTIFICATION TO CHAMPION     ║');
      debugPrint(
          '╚══════════════════════════════════════════════════════════╝');

      // ── Receiver: the champion who submitted the evidence ──
      final String? championEmail = submission.submittedBy;
      if (championEmail == null || championEmail.isEmpty) {
        debugPrint('❌ ABORT: Champion email is empty');
        return;
      }
      debugPrint('   Champion (receiver): $championEmail');

      // ── Sender: the currently logged-in user (owner / manager) ──
      final String senderEmail =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? '';
      debugPrint('   Sender: $senderEmail');

      // ── Document name ──
      String documentName = '';
      try {
        documentName = TaskHelper().getEvidenceName(
          criteriaNumber: submission.criteriaNumber,
          evidenceNumber: submission.evidenceNumber,
        );
        debugPrint('✅ Document name: $documentName');
      } catch (e) {
        documentName = 'مستند ${submission.evidenceNumber}';
        debugPrint('⚠️ Using fallback name: $documentName');
      }

      // ── Default Arabic strings (approved vs rejected) ──
      final bool isApproved = status == EvidenceSubmissionStatus.approved ||
          status ==
              EvidenceSubmissionStatus
                  .pending; // manager "pending" = approved by manager
      final bool isRejected = status == EvidenceSubmissionStatus.rejected;

      String notificationTitleAr;
      String notificationBodyAr;
      String eventType;

      if (isApproved) {
        eventType = 'evidence_approved';
        notificationTitleAr = 'تحديث حالة الدليل إلى معتمد';
        notificationBodyAr =
            'تم تحديث حالة الموافقة على المستند $documentName رسمياً إلى معتمد. '
            'يستوفي الدليل الآن جميع المعايير المطلوبة ويُعدّ صالحاً للفترة الزمنية للقياس المرتبطة. '
            'لا يُستلزم اتخاذ أي إجراء إضافي.';
      } else if (isRejected) {
        eventType = 'evidence_rejected';
        notificationTitleAr = 'تحديث حالة الدليل إلى مرفوض';
        notificationBodyAr =
            'تم تحديث حالة الموافقة على المستند $documentName رسمياً إلى مرفوض. '
            'يرجى مراجعة الملاحظات المقدمة من المشرف ومعالجة جميع المشكلات المحددة '
            'وإعادة تقديم نسخة معدّلة لإعادة النظر فيها في أقرب وقت ممكن.';
      } else {
        debugPrint('⚠️ Status not handled for notification: ${status.name}');
        return;
      }

      // ── Try to load template (override defaults if found & enabled) ──
      try {
        final templateService = NotificationTemplateService();
        final template = await templateService.getTemplate(
          module: 'qiyas',
          eventType: eventType,
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
          debugPrint('⚠️ No template found — using defaults');
        }
      } catch (e) {
        debugPrint('❌ Template error: $e — using defaults');
      }

      debugPrint('   Title: $notificationTitleAr');
      debugPrint('   Body: $notificationBodyAr');
      debugPrint('   Sender: $senderEmail');
      debugPrint('   Receiver: $championEmail');

      // ── Build notification model ──
      final notificationModel = NotificationModelSystem(
        title: notificationTitleAr,
        body: notificationBodyAr,
        nameOfModule: 'qiyas',
        senderEmail: senderEmail,
        receiverEmail: championEmail,
        nameOfPage: 'ChampiganTaskDetails',
        isPinned: false,
        isRead: false,
        isClean: false,
      );

      // ── Upload to Firestore ──
      try {
        final docId = await FirestoreNotificationService()
            .uploadNotification(notificationModel);
        debugPrint('✅ Firestore notification uploaded! Doc ID: $docId');
      } catch (e) {
        debugPrint('❌ Firestore error: $e');
      }

      // ── Send FCM push ──
      try {
        await NotificationServiceApp.sendNotification(
          notificationTitleAr,
          notificationBodyAr,
          championEmail,
        );
        debugPrint('✅ FCM push sent to: $championEmail');
      } catch (e) {
        debugPrint('❌ FCM error: $e');
      }

      debugPrint(
          '╚══════════════════════════════════════════════════════════╝');
    } catch (e) {
      debugPrint('❌ Notification error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isTablet = !kpIsPhoneLayout(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        spacing: 15.sp,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTitleValueWidget(
            titleStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryBlack),
            valueStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
            title: 'ﻣﺴﺘﻨﺪﺍﺕ ﺍﻹﺛﺒﺎﺕ',
            value: TaskHelper().getEvidenceName(
              criteriaNumber: submission.criteriaNumber,
              evidenceNumber: submission.evidenceNumber,
            ),
          ),

          /// ========== السفير + المدير + المسؤول ==========
          if (isTablet)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _userWidget(
                  isTablet: isTablet,
                  title: 'السفير:',
                  employeeId: submission.submittedBy,
                ),
                _userWidget(
                  isTablet: isTablet,
                  title: 'المدير:',
                  employeeId: submission.submittedBy != null
                      ? TaskHelper().getManagerId(submission.submittedBy!)
                      : null,
                ),
                _userWidget(
                  isTablet: isTablet,
                  title: 'المسؤول:',
                  employeeId: submission.managerId,
                ),
              ],
            )
          else ...[
            _userWidget(
              isTablet: isTablet,
              title: 'سفير التحول الرقمي:',
              employeeId: submission.submittedBy,
            ),
            _userWidget(
              isTablet: isTablet,
              title: 'المدير:',
              employeeId: submission.submittedBy != null
                  ? TaskHelper().getManagerId(submission.submittedBy!)
                  : null,
            ),
            _userWidget(
              isTablet: isTablet,
              title: 'المسؤول:',
              employeeId: submission.managerId,
            ),
          ],

          submissionDetails(submission, context),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────

  Widget _userWidget(
      {required bool isTablet,
      required String title,
      required String? employeeId}) {
    return SizedBox(
      width: isTablet ? 250.sp : double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryBlack),
          ),
          SizedBox(width: 5.sp),
          EmployeeNameAndImage(employeeId: employeeId),
        ],
      ),
    );
  }

  Widget submissionDetails(
      EvidenceSubmissionModel submission, BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    final bool isPortait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return isTablet
        ? Column(
            spacing: 15.sp,
            children: [
              Row(
                children: [
                  attachmentWidget(submission),
                  if (isTablet && isPortait) dates(submission, isPortait),
                  if (isTablet &&
                      isPortait &&
                      (submission.rejectionReason == null &&
                          submission.submissionStatus !=
                              EvidenceSubmissionStatus.rejected))
                    actionButtons(submission, context)
                ],
              ),
              if ((isTablet && !isPortait) || !isTablet)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    dates(submission, isPortait),
                    if (isTablet &&
                        EvidenceSubmissionStatus.rejected !=
                            submission.submissionStatus &&
                        submission.submissionNote == null)
                      actionButtons(submission, context),
                  ],
                ),
              if (submission.rejectionReason != null ||
                  submission.submissionNote != null)
                notes(submission),
              if (submission.rejectionReason != null ||
                  submission.submissionNote != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [actionButtons(submission, context)],
                )
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15.sp,
            children: [
              attachmentWidget(submission),
              dates(submission, isPortait),
              if (submission.rejectionReason != null ||
                  submission.submissionNote != null)
                notes(submission),
              actionButtons(submission, context),
            ],
          );
  }

  Widget attachmentWidget(EvidenceSubmissionModel submission) {
    return AttatchmentWidget(
      filePath: submission.filePath,
      showMinus: false,
      fileName: submission.fileName,
      fileSize: submission.fileSize,
      uploadDate: null,
    );
  }

  Widget dates(EvidenceSubmissionModel submission, bool isPortait) {
    if (isPortait) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTitleValueWidget(
            titleStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryBlack),
            valueStyle: StyleText.fontSize14Weight500,
            title: 'تاريخ تقديم المستند',
            value: DateFormat.yMMMd('ar')
                .format(submission.submissionDate!.toDate()),
          ),
          CustomTitleValueWidget(
            titleStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryBlack),
            valueStyle: StyleText.fontSize14Weight500,
            title: 'تاريخ الاعتماد',
            value: submission.approvedDate == null
                ? '-'
                : DateFormat.yMMMd('ar')
                    .format(submission.submissionDate!.toDate()),
          ),
        ],
      );
    }
    return Row(
      spacing: 50.sp,
      children: [
        CustomTitleValueWidget(
          titleStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryBlack),
          valueStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.secondaryText,
          ),
          title: 'تاريخ تقديم المستند',
          value: DateFormat.yMMMd('ar')
              .format(submission.submissionDate!.toDate()),
        ),
        CustomTitleValueWidget(
          titleStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryBlack),
          valueStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.secondaryText,
          ),
          title: 'تاريخ الاعتماد',
          value: submission.approvedDate == null
              ? '-'
              : DateFormat.yMMMd('ar')
                  .format(submission.submissionDate!.toDate()),
        ),
      ],
    );
  }

  Widget actionButtons(
      EvidenceSubmissionModel submission, BuildContext context) {
    final bool isTablet = !kpIsPhoneLayout(context);
    // ========================================
    // CHAMPION VIEW — Can resubmit if rejected
    // ========================================
    if (isChampion) {
      return Row(
        spacing: 10.sp,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (submission.submissionStatus ==
                  EvidenceSubmissionStatus.rejected &&
              isFirst)
            customButton(
              height: 38.h,
              width: 200.w,
              title: 'إعادة تقديم الدليل',
              function: () {
                UploadEvidenceDialog().show(context);
              },
            ),
          _statusBadge(submission),
        ],
      );
    }

    // ========================================
    // OWNER VIEW — Reviews "pending" submissions
    // ========================================
    if (isOwner &&
        submission.submissionStatus == EvidenceSubmissionStatus.pending) {
      return Row(
        spacing: 10.sp,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Reject button
          InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTapDown: (_) => HapticController.high(),
            onTap: () {
              ConfirmDialog().show(
                context,
                EvidenceSubmissionStatus.rejected,
                submission.submissionId,
                onConfirmed: () {
                  _sendStatusNotificationToChampion(
                      EvidenceSubmissionStatus.rejected);
                },
              );
            },
            child: _actionBadge(
              status: EvidenceSubmissionStatus.rejected,
              label: 'رفض',
            ),
          ),
          // Approve button
          InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTapDown: (_) => HapticController.medium(),
            onTap: () {
              ConfirmDialog().show(
                context,
                EvidenceSubmissionStatus.approved,
                submission.submissionId,
                onConfirmed: () {
                  _sendStatusNotificationToChampion(
                      EvidenceSubmissionStatus.approved);
                },
              );
            },
            child: _actionBadge(
              status: EvidenceSubmissionStatus.approved,
              label: EvidenceSubmissionStatus.approved.value,
            ),
          ),
        ],
      );
    }

    // ========================================
    // MANAGER VIEW — Reviews "submitted" submissions
    // ========================================
    if (isManager) {
      if (submission.submissionStatus == EvidenceSubmissionStatus.submitted) {
        return Row(
          mainAxisAlignment:
              isTablet ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
          spacing: 10.sp,
          children: [
            // Reject button
            InkWell(
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTapDown: (_) => HapticController.high(),
              onTap: () {
                ManagerConfirmDialog().show(
                  context,
                  EvidenceSubmissionStatus.rejected,
                  submission.submissionId,
                  onConfirmed: () {
                    _sendStatusNotificationToChampion(
                        EvidenceSubmissionStatus.rejected);
                  },
                );
              },
              child: _actionBadge(
                status: EvidenceSubmissionStatus.rejected,
                label: 'رفض',
              ),
            ),
            // Approve button
            InkWell(
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTapDown: (_) => HapticController.medium(),
              onTap: () {
                ManagerConfirmDialog().show(
                  context,
                  EvidenceSubmissionStatus
                      .pending, // manager approval = pending for owner review
                  submission.submissionId,
                  onConfirmed: () {
                    _sendStatusNotificationToChampion(
                        EvidenceSubmissionStatus.approved);
                  },
                );
              },
              child: _actionBadge(
                status: EvidenceSubmissionStatus.approved,
                label: 'موافقة',
              ),
            ),
          ],
        );
      }

      // Other statuses — just badge
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [_statusBadge(submission)],
      );
    }

    // ========================================
    // DEFAULT FALLBACK — Just show status badge
    // ========================================
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [_statusBadge(submission)],
    );
  }

  // ─────────────────────────────────────────────
  // REUSABLE BADGE HELPERS
  // ─────────────────────────────────────────────

  /// Outlined badge for an action button (reject / approve) — uses a specific
  /// [status] for colour and a custom [label] string.
  Widget _actionBadge({
    required EvidenceSubmissionStatus status,
    required String label,
  }) {
    return Container(
      height: 38.h,
      width: 200.w,
      padding: EdgeInsets.symmetric(vertical: 4.sp),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: status.color, width: 1.sp),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 8.sp,
            backgroundColor: status.color,
            child: SvgPicture.asset(status.icon),
          ),
          SizedBox(width: 8.sp),
          Text(
            label,
            style: StyleText.fontSize16Weight500.copyWith(color: status.color),
          ),
        ],
      ),
    );
  }

  /// Read-only status badge — uses [submission.submissionStatus].
  Widget _statusBadge(EvidenceSubmissionModel submission) {
    return Container(
      height: 38.h,
      width: 200.w,
      padding: EdgeInsets.symmetric(vertical: 4.sp),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border:
            Border.all(color: submission.submissionStatus.color, width: 1.sp),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 8.sp,
            backgroundColor: submission.submissionStatus.color,
            child: SvgPicture.asset(submission.submissionStatus.icon),
          ),
          SizedBox(width: 8.sp),
          Text(
            submission.submissionStatus.value,
            style: StyleText.fontSize16Weight500
                .copyWith(color: submission.submissionStatus.color),
          ),
        ],
      ),
    );
  }

  Widget notes(EvidenceSubmissionModel submission) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons_assets/main_icons_assets/ic_reason_reject.svg',
          colorFilter: ColorFilter.mode(
              submission.rejectionReason != null ? Colors.red : AppColors.text,
              BlendMode.srcIn),
          width: 16.sp,
          height: 16.sp,
        ),
        SizedBox(width: 3.w),
        CustomTitleValueWidget(
            titleStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryBlack)
                .copyWith(
                  color: submission.rejectionReason != null
                      ? Colors.red
                      : AppColors.text,
                ),
            valueStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
            title: submission.rejectionReason == null ? 'ملاحظة' : 'سبب الرفض',
            value: submission.rejectionReason == null
                ? submission.submissionNote!
                : submission.rejectionReason!),
      ],
    );
  }
}
