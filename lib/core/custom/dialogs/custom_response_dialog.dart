/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: response_dialog.dart
/// Purpose: Declares `ResponseDialog`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dialogs/dialog_lottie.dart';

class ResponseDialog extends StatelessWidget implements ErrorFeedbackDialog {
  const ResponseDialog({
    super.key,
    required this.subtitle,
    required this.title,
    required this.lottieAsset,
  });

  final String subtitle;
  final String title;
  final String lottieAsset;

  /// The error Lottie marks a failure (X-105: a login error fires HIGH).
  @override
  bool get isErrorFeedback => lottieAsset.contains('error');

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet
              ? isPortrait
                  ? 150.w
                  : 310.w
              : 40.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.card, borderRadius: BorderRadius.circular(8)),
        width: 500.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 24/10/2026 (Moataz): sized in the layout and capped to the
              // dialog. It was a 1.5x Transform.scale in portrait, which drew
              // the animation outside the top of the dialog.
              DialogLottie(
                asset: lottieAsset,
                size: isTablet
                    ? isPortrait
                        ? 140.w
                        : 120.w
                    : 110.w,
              ),
              Text(title,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize18Weight500),
              SizedBox(
                  height: isTablet
                      ? isPortrait
                          ? 20.h
                          : 10.h
                      : 10.h),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.secondaryBlack)
                      .copyWith(height: 1.4)),
              SizedBox(height: 20.h)
            ],
          ),
        ),
      ),
    );
  }
}
