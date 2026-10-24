/// Module: services / sv5_service_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: success_dialog.dart
/// Purpose: Success dialog — declares showDownloadSuccessDialog.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';

Future<void> showDownloadSuccessDialog(BuildContext context) async {
  await showAppDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 411.sp,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                ServicesLottie.approved,
                width: 70.sp,
                height: 70.sp,
                repeat: true,
              ),
              SizedBox(height: 12.sp),
              Text(
                S.of(context).downloadSuccessTitle,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.sp),
              Text(
                S.of(context).downloadSuccessMessage,
                style: StyleText.fontSize14Weight500.copyWith(
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
