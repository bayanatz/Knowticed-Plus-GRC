/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_cancel_button.dart
/// Purpose: The Cancel button of the "My request" details page with its
///          confirm and reason dialogs. It calls
///          MyRequestDetailsCubit.cancelRequest and reads nothing itself.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/features/services/helpers/services_feedback.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/my_request_details_cubit.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class MyRequestCancelButton extends StatelessWidget {
  const MyRequestCancelButton({
    super.key,
    required this.isMobile,
    required this.cancelController,
    required this.serviceName,
    required this.onCancelled,
  });

  final bool isMobile;
  final TextEditingController cancelController;
  final String serviceName;

  /// Called after a successful cancel so the page can refresh derived
  /// approval-related lists on the module-level cubit.
  final VoidCallback onCancelled;

  @override
  Widget build(BuildContext context) {
    // "Cancel Service" off → the whole affordance goes, not just the handler.
    if (!ServicesModuleAccess.canCancelService) {
      return const SizedBox.shrink();
    }

    final cubit = context.read<MyRequestDetailsCubit>();

    return GestureDetector(
      onTapDown: (_) => HapticController.high(),
      onTap: () {
        CustomDialogManager.showDialogFlow(
          confirmWidth: 411,
          context: context,
          customReasonTitle: S.of(context).reasonsOfCancellation,
          confirmLottie: ServicesLottie.rejected,
          confirmTitle: S.of(context).cancelRequest,
          confirmSubtitle: S.of(context).AreYousureYouWanttoCancelThisRequest,
          confirmYesText: S.of(context).yes,
          confirmNoText: S.of(context).no,
          onConfirm: () async => true,
          comment: true,
          commentRequired: true,
          commentController: cancelController,
          commentSubmitText: S.of(context).submit,
          commentDiscardText: S.of(context).discard,
          onCommentSubmit: () async {
            final messenger = ScaffoldMessenger.of(context);
            final s = S.of(context);
            // Success (and the refresh) only when the cancel was saved.
            final ok = await cubit.cancelRequest(
              cancellationReason: cancelController.text,
              serviceName: serviceName,
            );
            if (!ok) return false;
            // SVC-REQ-08: cancelled, but the provider was not told.
            if (cubit.lastNotificationFailed) {
              ServicesFeedback.showWarning(
                messenger,
                s.svcCancelSavedNotifyFailed,
              );
            }
            onCancelled();
            return true;
          },
          successLottie: ServicesLottie.approved,
          successTitle: S.of(context).CancelRequest,
          successSubtitle: S.of(context).cancelSuccessMessage,
          onSuccessComplete: () {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) Navigator.pop(context);
            });
          },
        );
      },
      child: Container(
        width: isMobile ? 135.sp : 150.sp,
        // Same height as Send Reminder and the status pill next to it.
        height: 36.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.red,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgImage.natural(
              assetPath:
                  "assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg",
              height: 20.sp,
              color: AppColors.white,
              width: 20.sp,
              fit: BoxFit.fill,
            ),
            SizedBox(width: 8.sp),
            Text(
              S.of(context).Cancel,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
