/// Module: services / sv3_create_master_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: upload_details_dialogs.dart
/// Purpose: Dialog helpers (validation-error / confirm-activate / success) for
///          the bulk-upload request-preview screen.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: AppColors, StyleText, lottie
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from upload_details.dart
///     (fix item 5 — page LOC reduction).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_durations.dart';

class UploadDetailsDialogs {
  const UploadDetailsDialogs._();

  static void showMustCorrectErrors(BuildContext context) {
    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding: EdgeInsets.all(20.sp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              ServicesLottie.rejected,
              width: 90.sp,
              height: 90.sp,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.sp),
            Text(
              S.of(context).mustCorrectErrors,
              style: StyleText.fontSize18Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showConfirmActivate(
    BuildContext context, {
    required bool lightMode,
    required VoidCallback onConfirm,
  }) {
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (confirmCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding: EdgeInsets.all(20.sp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              ServicesLottie.confirmation,
              width: 90.sp,
              height: 90.sp,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 15.sp),
            Text(
              S.of(context).activatingRequests,
              style: StyleText.fontSize20Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18.sp),
            Text(
              S.of(context).areYouSureActivateRequests,
              style: StyleText.fontSize18Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customButton(
                  title: S.of(confirmCtx).no,
                  function: () => Navigator.pop(confirmCtx),
                  textStyle: StyleText.fontSize18Weight500.copyWith(
                    color: AppColors.onSecondaryAction,
                  ),
                  width: 135.sp,
                  height: 38.sp,
                  radius: 4.r,
                  color: AppColors.secondaryAction,
                ),
                SizedBox(width: 28.sp),
                customButton(
                  title: S.of(confirmCtx).yes,
                  function: () {
                    Navigator.pop(confirmCtx);
                    onConfirm();
                  },
                  textStyle: StyleText.fontSize18Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                  width: 135.sp,
                  height: 38.sp,
                  radius: 4.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void showActivatedSuccess(
    BuildContext context, {
    required VoidCallback onDismiss,
  }) {
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (successCtx) {
        Future.delayed(ServicesDurations.successDialog, () {
          if (!successCtx.mounted) return;
          if (Navigator.canPop(successCtx)) {
            if (!successCtx.mounted) return;
            Navigator.pop(successCtx);
          }
          onDismiss();
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          contentPadding: EdgeInsets.all(20.sp),
          content: SizedBox(
            width: 400.sp,
            height: 180.sp,
            child: Column(
              children: [
                Lottie.asset(
                  ServicesLottie.approved,
                  width: 90.sp,
                  height: 90.sp,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 15.sp),
                Text(
                  S.of(context).activated,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).servicesRequestsActivatedSuccessfully,
                  style: StyleText.fontSize18Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
