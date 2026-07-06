import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/helper/main_helper/app_haptics.dart';
import 'package:demo_app/core/custom/41_custom_button_sizing.dart';

Widget customButton({
  required String title,
  required VoidCallback function,
  double? width, // ignored: sizing is enforced by ButtonSizing
  double? height, // ignored: sizing is enforced by ButtonSizing
  double radius = 8, // ignored: sizing is enforced by ButtonSizing
  Color? color,
  Color? textColor,
  Color? borderColor,
  TextStyle? textStyle,
}) {
  final isDark = Get.isDarkMode;

  return Builder(
    builder: (context) {
      final TextStyle effectiveStyle = textStyle ??
          StyleText.fontSize16Weight500.copyWith(
            color: textColor ?? AppColors.textButton,
          );

      // 38.sp on mobile / 135.sp on tablet, or null when the text
      // doesn't fit (then the button wraps the text with 12.sp padding).
      final double? buttonWidth = ButtonSizing.width(
        context,
        title: title,
        textStyle: effectiveStyle,
      );

      final Widget text = Text(title, style: effectiveStyle);

      return GestureDetector(
        onTap: () {
          AppHaptics.medium(); // primary action button
          function();
        },
        child: Container(
          width: buttonWidth,
          height: ButtonSizing.height,
          decoration: BoxDecoration(
            color: color ?? AppColors.primary,
            borderRadius: BorderRadius.circular(ButtonSizing.radius),
            border: Border.all(
              color: borderColor ?? AppColors.transparent,
            ),
          ),
          child: buttonWidth == null
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ButtonSizing.horizontalPadding,
                  ),
                  child: Center(widthFactor: 1, child: text),
                )
              : Center(child: text),
        ),
      );
    },
  );
}

/*
// ── Usage ─────────────────────────────────────────────────────────────────────
// Sizing is enforced app-wide by ButtonSizing:
// width 38.sp (mobile) / 135.sp (tablet), height 38.sp, radius 8.r.
// If the text doesn't fit, the button wraps it with 12.sp horizontal padding.
customButton(
  title: 'Save',
  function: () {},
  color: AppColors.primary,
  textColor: AppColors.textButton,
)
*/
