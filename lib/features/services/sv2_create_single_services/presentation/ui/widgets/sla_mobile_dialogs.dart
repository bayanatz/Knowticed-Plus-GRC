/// Module: services / sv2_create_single_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: sla_mobile_dialogs.dart
/// Purpose: The confirmation and success dialogs of the phone SLA step.
///          Split out of the screen (Provider rule 7).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_durations.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [showSlaMobileConfirmDialog]
///
/// Purpose: "Are you sure you want to create / edit this service?".
///
/// Returns: true when the user tapped Yes.
Future<bool> showSlaMobileConfirmDialog(
  BuildContext context, {
  required bool isEdit,
}) async {
  final s = S.of(context);
  Widget button(
    String text,
    Color color,
    Color textColor,
    bool result,
    BuildContext dialogContext,
  ) =>
      Expanded(
        child: GestureDetector(
          onTapDown: (_) =>
              result ? HapticController.medium() : HapticController.low(),
          onTap: () => Navigator.of(dialogContext).pop(result),
          child: Container(
            height: 38.sp,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              text,
              style: StyleText.fontSize16Weight500.copyWith(color: textColor),
            ),
          ),
        ),
      );

  final result = await showAppDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 300.sp,
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              ServicesLottie.confirmation,
              width: 70.w,
              height: 70.h,
              fit: BoxFit.scaleDown,
            ),
            SizedBox(height: 20.sp),
            Text(
              isEdit ? s.editingService : s.creatingService,
              style: StyleText.fontSize20Weight500.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 18.sp),
            Text(
              isEdit ? s.areYouSureEditService : s.areYouSureCreateService,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(height: 15.sp),
            Row(
              children: [
                button(
                  s.no,
                  AppColors.secondaryAction,
                  AppColors.onSecondaryAction,
                  false,
                  dialogContext,
                ),
                SizedBox(width: 28.sp),
                button(
                  s.yes,
                  AppColors.primary,
                  AppColors.textButton,
                  true,
                  dialogContext,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result == true;
}

/// Function Name: [showSlaMobileSuccessDialog]
///
/// Purpose: "Service created / edited", closing by itself after
/// [ServicesDurations.successDialog]. Only this dialog's own route is popped
/// by the timer (QA p.18 — it used to pop the page under it).
Future<void> showSlaMobileSuccessDialog(
  BuildContext context, {
  required bool isEdit,
}) async {
  Route<dynamic>? dialogRoute;
  Future<void>.delayed(ServicesDurations.successDialog, () {
    final route = dialogRoute;
    if (route != null && route.isCurrent) route.navigator?.pop();
  });
  await showAppDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      dialogRoute ??= ModalRoute.of(dialogContext);
      final s = S.of(dialogContext);
      return Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: SizedBox(
            width: 410.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  ServicesLottie.approved,
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(height: 20.h),
                Text(
                  isEdit ? s.editSuccess : s.createSuccess,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  isEdit
                      ? s.YouSuccessfullyEditedThisService
                      : s.YouSuccessfullyCreatedThisService,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
