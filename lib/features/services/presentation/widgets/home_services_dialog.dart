/// Module: services / presentation / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: home_services_dialog.dart
/// Purpose: Home services dialog — declares showSuccessDialogMaster.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

Future<void> showSuccessDialogMaster({
  required String lottiePath,
  required BuildContext context,
  required String title,
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
