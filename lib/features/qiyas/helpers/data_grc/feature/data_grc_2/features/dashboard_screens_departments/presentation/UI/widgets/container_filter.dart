import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ContainerFiltered extends StatelessWidget {
  const ContainerFiltered(
      {super.key,
      required this.isSelcted,
      required this.title,
      required this.onTap,
      this.buttonWidth,
      this.radius,
      this.isSelctedColorWhite = false,
      this.verticalPadding,
      this.horizontalPadding,
      this.backgroundColor,
      this.buttonHight});
  final bool isSelcted;
  final bool? isSelctedColorWhite;
  final String title;
  final Function()? onTap;
  final double? buttonWidth;
  final double? buttonHight;
  final double? radius;
  final double? verticalPadding;
  final double? horizontalPadding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: Container(
        width: buttonWidth,
        height: buttonHight,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 4),
            color: isSelcted
                ? AppColors.primary
                : backgroundColor ?? AppColors.card),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.sp, horizontal: 6.sp),
          child: Center(
            child: FittedBox(
              child: Text(title.tr,
                  style: StyleText.fontSize14Weight600.copyWith(
                      height: 1,
                      color: isSelcted
                          ? AppColors.textButton
                          : AppColors.secondaryBlack)),
            ),
          ),
        ),
      ),
    );
  }
}
