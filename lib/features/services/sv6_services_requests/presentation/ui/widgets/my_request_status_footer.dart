/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_status_footer.dart
/// Purpose: The bottom row of the "My request" details page (Send reminder
///          button and status chip) and the requested-date / breached-SLA
///          ribbon. The reminder goes through ServicesNotificationService.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/helper/current_user_context.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/custom_button_with_image.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MyRequestStatusFooter extends StatelessWidget {
  const MyRequestStatusFooter({
    super.key,
    required this.isMobile,
    required this.shouldShowReminder,
    required this.requestId,
    required this.reminderServiceName,
    required this.currentApproverEmail,
    required this.hasApprovalCycle,
    required this.hasRejectionOrCancel,
    required this.borderColor,
    required this.iconAsset,
    required this.stateLabel,
  });

  final bool isMobile;
  final bool shouldShowReminder;
  final String requestId;
  final String reminderServiceName;
  final String? currentApproverEmail;
  final bool hasApprovalCycle;
  final bool hasRejectionOrCancel;
  final Color borderColor;
  final String iconAsset;
  final String stateLabel;

  /// Function Name: [_sendReminder]
  ///
  /// Purpose: Reminds the current approver that this request is waiting,
  /// through the `services_review_reminder_manager` template (in-app
  /// notification and push), then tells the user whether it went out.
  ///
  /// Parameters:
  /// - [context]: for the notification service and the result dialog.
  Future<void> _sendReminder(BuildContext context) async {
    if (currentApproverEmail == null || currentApproverEmail!.isEmpty) return;

    final bool sent = await context
        .read<ServicesNotificationService>()
        .notifyManagerOfPendingReview(
          requestId: requestId,
          senderEmail: CurrentUserContext.email ?? '',
          managerEmail: currentApproverEmail!,
          serviceName: reminderServiceName,
          isArabic: false,
        );

    if (!context.mounted) return;

    // A dialog, not a SnackBar: the failure dialog stays open so the user
    // sees the reminder did not go out and can retry.
    if (sent) {
      await CustomDialogManager.showSuccess(
        context: context,
        lottiePath: ServicesLottie.approved,
        title: S.of(context).SendReminder,
        subtitle: S.of(context).svcReminderSent,
      );
    } else {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: ServicesLottie.rejected,
        title: S.of(context).warning,
        subtitle: S.of(context).errorOccuredPleaseTryAgain,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // On a phone without the reminder button the chip fills the row; that
    // must be Expanded, not an infinite width inside a Row.
    final bool fillsRow = isMobile && !shouldShowReminder;

    final Widget statusBox = Container(
      // Null under `Expanded`: the parent hands down a tight width, and a
      // `width` here would fight it.
      width: fillsRow ? null : (isMobile ? 150.sp : 200.sp),
      height: 36.sp,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          hasRejectionOrCancel
              ? Container(
                  width: 22.sp,
                  height: 22.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.red,
                  ),
                  child: Icon(
                    Icons.block_flipped,
                    color: AppColors.chatBackground,
                    size: 18.sp,
                  ),
                )
              : CustomSvgImage.natural(
                  assetPath: iconAsset,
                  width: 24.sp,
                  height: 24.sp,
                  fit: BoxFit.scaleDown,
                ),
          SizedBox(width: 8.w),
          Text(
            stateLabel,
            style: StyleText.fontSize16Weight500.copyWith(color: borderColor),
          ),
        ],
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        hasApprovalCycle && shouldShowReminder
            ? customButtonWithImage(
                title: isMobile
                    ? S.of(context).reminder
                    : S.of(context).SendReminder,
                function: () => _sendReminder(context),
                textStyle: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.textButton,
                ),
                width: isMobile ? 125.sp : 185.sp,
                height: 36.sp,
                space: 8.sp,
                radius: 8.r,
                color: AppColors.primary,
                image:
                    "assets/icons_assets/services_assets/ic_time_reminder_calendar.svg",
                widthImage: 21.sp,
                heightImage: 21.sp,
                colorBorder: AppColors.transparent,
              )
            : SizedBox(),
        if (shouldShowReminder) Spacer(),
        fillsRow ? Expanded(child: statusBox) : statusBox,
      ],
    );
  }
}

class MyRequestDateRibbon extends StatelessWidget {
  const MyRequestDateRibbon({
    super.key,
    required this.isMobile,
    required this.requestedTimestamp,
    required this.showBreachedSlaRibbon,
  });

  final bool isMobile;
  final int? requestedTimestamp;
  final bool showBreachedSlaRibbon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(12.sp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "${S.of(context).requestedDate}: ",
                style: isMobile
                    ? StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.secondaryText,
                      )
                    : StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
              ),
              Text(
                DateFormat(
                  'dd MMM yyyy',
                  Localizations.localeOf(context).toString(),
                ).format(
                  requestedTimestamp != null
                      ? DateTime.fromMillisecondsSinceEpoch(requestedTimestamp!)
                      : DateTime.now(),
                ),
                style: isMobile
                    ? StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.blackButton,
                      )
                    : StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.blackButton,
                      ),
              ),
            ],
          ),
        ),
        if (showBreachedSlaRibbon)
          Positioned(
            top: 12.h,
            left: -40.w,
            child: Transform.rotate(
              angle: -0.785398,
              child: Container(
                width: 160.w,
                color: AppColors.red,
                child: Row(
                  children: [
                    SizedBox(width: 30.w),
                    Text(
                      S.of(context).status_breached,
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
