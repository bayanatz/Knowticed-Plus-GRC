/// Module: services / sv11_admin_dashboard_mobile / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: success_master_dialog.dart
/// Purpose: The success dialog of the dashboard exports (showSuccessMaster).
///          Renamed from the generic dialog.dart (Dashboards rule 18); the
///          unused CustomConfirmationDialog was removed (rule 25).
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_animations.dart';

/// Function Name: [showSuccessMaster]
///
/// Purpose: Shows a lottie, a title and a message with an OK button.
///
/// Returns: true when the user confirmed.
Future<bool?> showSuccessMaster(
  BuildContext context, {
  required String lottiePath,
  required String title,
  required String message,
  VoidCallback? onConfirm, // optional: action to run when user confirms
  VoidCallback? onCancel, // optional: action to run when user cancels
  bool barrierDismissible = true,
}) {
  return showAppDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => _SuccessMasterDialog(
      lottiePath: lottiePath,
      title: title,
      message: message,
      onConfirm: onConfirm,
      onCancel: onCancel,
    ),
  );
}

class _SuccessMasterDialog extends StatelessWidget {
  final String lottiePath;
  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _SuccessMasterDialog({
    super.key,
    required this.lottiePath,
    required this.title,
    required this.message,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context).brightness == Brightness.light;

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: 411.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                lottiePath,
                width: 70.sp,
                height: 70.sp,
                fit: BoxFit.scaleDown,
                repeat: true,
                animate: true,
              ),
              SizedBox(height: 20.sp),
              Text(
                title,
                textAlign: TextAlign.center,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.text,
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
            ],
          ),
        ),
      ),
    );
  }
}
