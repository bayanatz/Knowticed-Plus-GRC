/// Module: messaging / chat / presentation/ui/widgets/buttons/menu_icon_button.dart
library;
// By:Youssef Ashraf
// Date: 18/9/2024
// Objectives: This file is responsible for providing a widget that represents the menu icon in the menu attachment message widget.

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/messaging/helpers/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class MenuIconButton extends StatelessWidget {
  final Function() onTap;
  final String icon;
  final String text;

  const MenuIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTapDown: hapticDown(onTap, HapticLevel.low),
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(
                8.r,
              ),
            ),
            child: CustomSvgImage.natural(
              assetPath: icon,
              color: AppTheme.isDark ? AppColors.textButton : AppColors.black,
              height: 32.h,
              width: 32.w,
            ),
          ),
        ),
        verticalSpace(4),
        Text(
          text,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
      ],
    );
  }
}
