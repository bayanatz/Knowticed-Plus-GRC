/// Module: services / sv4_bulk_upload_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: upload_file_details_activate_flow.dart
/// Purpose: "Discard / Activate" action row + the error/confirm/success dialog
///          flow for the bulk "upload file details" (master step 1) screen.
///          Pure presentation — the actual Firestore upload happens via the
///          [onUpload] callback (backed by BulkServicesUploader); this widget
///          only sequences dialogs. Extracted from
///          UploadFileDetailsTabletMaster to bring that file under the 800-LOC
///          budget (audit fix #1).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: lottie, flutter_screenutil
/// Revision History: Initial version.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/features/services/helpers/guarded_action.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_durations.dart';

class UploadFileDetailsActivateRow extends StatelessWidget {
  const UploadFileDetailsActivateRow({
    super.key,
    required this.lightMode,
    required this.totalErrorCount,
    required this.onDiscard,
    required this.onUpload,
    required this.isMasterFlow,
  });

  final bool lightMode;
  final int totalErrorCount;
  final VoidCallback onDiscard;

  /// Performs the actual upload (delegates to BulkServicesUploader via the
  /// page). May throw — the caller shows a snackbar on failure.
  final Future<void> Function() onUpload;

  /// True when this screen is step 1 of the master (multi-step) flow, in
  /// which case the success dialog is skipped (the parent screen shows its
  /// own success UI after step 2 completes).
  final bool isMasterFlow;

  void _showErrorDialog(BuildContext context) {
    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (errorDialogContext) => AlertDialog(
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
              S.of(errorDialogContext).mustCorrectErrors,
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

  void _showSuccessDialog(BuildContext parentContext) {
    showAppDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (successDialogContext) {
        Future.delayed(ServicesDurations.successDialog, () {
          if (!successDialogContext.mounted) return;
          if (Navigator.canPop(successDialogContext)) {
            if (!successDialogContext.mounted) return;
            Navigator.pop(successDialogContext);
            if (!parentContext.mounted) return;
            if (Navigator.canPop(parentContext)) {
              if (!parentContext.mounted) return;
              Navigator.pop(parentContext);
              // S2: next frame instead of a fixed 100 ms wait.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!parentContext.mounted) return;
                if (Navigator.canPop(parentContext)) {
                  if (!parentContext.mounted) return;
                  Navigator.pop(parentContext);
                }
              });
            }
          }
        });

        return AlertDialog(
          backgroundColor: AppColors.card,
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
                  S.of(successDialogContext).activated,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(successDialogContext).successfullyActivated,
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

  void _showConfirmDialog(BuildContext parentContext) {
    showAppDialog(
      context: parentContext,
      barrierDismissible: true,
      builder: (confirmDialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
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
              S.of(confirmDialogContext).activatingService,
              style: StyleText.fontSize20Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18.sp),
            Text(
              S.of(confirmDialogContext).areYouSureActivate,
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
                  title: S.of(confirmDialogContext).no,
                  function: () => Navigator.pop(confirmDialogContext),
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
                  title: S.of(confirmDialogContext).yes,
                  function: () async {
                    Navigator.pop(confirmDialogContext);

                    final error = await svcGuard(onUpload);
                    if (error != null) {
                      if (!parentContext.mounted) return;
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            S.of(parentContext).uploadFailedTryAgain,
                          ),
                        ),
                      );
                      return;
                    }

                    if (!parentContext.mounted) return;

                    if (!isMasterFlow) {
                      _showSuccessDialog(parentContext);
                    } else if (Navigator.canPop(parentContext)) {
                      Navigator.pop(parentContext);
                    }
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

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection
          .ltr, // X-73: Cancel left, action right in both languages

      children: [
        customButton(
          title: S.of(context).discard,
          function: onDiscard,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.onSecondaryAction,
          ),
          width: 150.sp,
          height: 38.sp,
          radius: 8.r,
          color: AppColors.secondaryAction,
        ),
        Spacer(),
        customButton(
          title: S.of(context).activate,
          function: () {
            if (totalErrorCount > 0) {
              _showErrorDialog(context);
              return;
            }
            _showConfirmDialog(context);
          },
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: totalErrorCount > 0 ? AppColors.text : AppColors.textButton,
          ),
          width: 150.sp,
          height: 38.sp,
          radius: 8.r,
          color: totalErrorCount > 0
              ? (lightMode ? AppColors.grey : AppColors.mediumGrey)
              : AppColors.primary,
        ),
      ],
    );
  }
}
