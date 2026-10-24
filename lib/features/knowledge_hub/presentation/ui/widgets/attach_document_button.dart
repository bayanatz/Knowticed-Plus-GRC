/// Module: knowledge_hub/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: attach_document_button.dart
/// Description: `attachDocumentButton()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

Widget attachDocumentButton(
  BuildContext context, {
  required String text,
  required VoidCallback onPressed,
  Color? textColor,
  Color? backgroundColor,
  double? horizontalPadding,
  double? verticalPadding,
  double? borderRadius,
  double? buttonWidth,
  double? buttonHeight,
  TextStyle? textStyle,
  Widget? icon,
  double? spacingBetweenIconAndText,
}) {
  return GestureDetector(
    onTapDown: hapticDown(onPressed, HapticLevel.low),
    onTap: onPressed,
    child: Container(
      width: buttonWidth ?? ScreenUtil().screenWidth,
      height: buttonHeight ?? 36,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius ?? 4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) icon,
          spacingBetweenIconAndText != null
              ? SizedBox(width: spacingBetweenIconAndText.w)
              : SizedBox(width: 16.w),
          Text(
            text,
            style:
                textStyle ??
                StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.textButton,
                ),
          ),
        ],
      ),
    ),
  );
}
