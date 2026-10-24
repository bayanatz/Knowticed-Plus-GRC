/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_filter_dialog.dart
/// Purpose: Simple success and confirmation dialogs (lottie, title,
///          subtitle) used by the services export flows.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

Future<void> showSuccessDialog({
  required String lottiePath,
  required String title,
  required BuildContext context,
  required String subtitle,
}) async {
  return showAppDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: 411.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                lottiePath,
                width: 70.w,
                height: 70.h,
                fit: BoxFit.scaleDown,
              ),
              SizedBox(height: 20.h),
              Text(
                title,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showConfirmationDialog({
  required String lottiePath,
  required String title,
  required BuildContext context,
  required String message,
  required VoidCallback onConfirm,
}) async {
  return showAppDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: 411.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                lottiePath, // Replace with your Lottie URL
                width: 70.sp,
                height: 70.sp,
                fit: BoxFit.scaleDown,
                repeat: true,
                // Set to false if you don't want it to loop
                animate: true, // Set to false to pause the animation
              ),
              SizedBox(height: 20.sp),
              Text(
                title,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                message,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 15.sp),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 56.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    customButton(
                      title: "No",
                      function: () => Navigator.pop(context),
                      textStyle: StyleText.fontSize15Weight400.copyWith(
                        color: AppColors.header,
                      ),
                      width: 135.sp,
                      height: 38.sp,
                      radius: 4.r,
                      color: AppColors.secondaryAction,
                    ),
                    SizedBox(width: 20.sp),
                    customButton(
                      title: "Yes",
                      function: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      textStyle: StyleText.fontSize15Weight400.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: 135.sp,
                      height: 38.sp,
                      radius: 4.r,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
