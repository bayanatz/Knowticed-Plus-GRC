/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_main_button.dart
/// Purpose: Declares `MainCustomButton`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import '../theme/app_animations.dart';
import '../theme/haptic_controller.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';

class MainCustomButton extends StatelessWidget {
  final String? buttonText;
  final VoidCallback onPressed;
  final double? height;
  final Color? buttonColor;
  final TextStyle? textStyle;

  const MainCustomButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.height,
    this.buttonColor,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return appPressFeedback(
      color: buttonColor,
      child: Container(
      height: height ?? 50.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticController.forLabel(buttonText,
              fallback: isYellowButton(buttonColor)
                  ? HapticLevel.medium
                  : HapticLevel.low);
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(buttonText== null?"":buttonText!,
                style: textStyle ??
                    StyleText.fontSize23Weight600
                        .copyWith(color: AppColors.textButton)
            ),
          ],
        ),
      ),
    ));
  }
}
