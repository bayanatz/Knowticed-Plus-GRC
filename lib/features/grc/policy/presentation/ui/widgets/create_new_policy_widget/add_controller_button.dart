/// Module: GRC Policy Management
/// Description: "+ Add Controller" button shown on the Create Policy preview
///              step when there are no touched controls yet.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-16
/// Dependencies: Flutter SDK, AppColors, StyleText, customButtonWithSvg
/// Revision History: 2026-07-16 - Extracted from create_new_policy.dart
library;

/// ************************* FILE INFO *************************** ///
/// File Name: add_controller_button.dart
/// Purpose: Contains AddControllerButton, shown on step 2 (Preview) instead
///          of the controls table when there are no touched controls.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 16/7/2026

import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [AddControllerButton]
///
/// purpose: sends the user back to step 1 (Controls) so they can add one,
///          matching the "+ Control" button styling used there.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 16/7/2026
class AddControllerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddControllerButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: customButtonWithSvg(
        colorBorder: AppColors.textButton,
        widthImage: 16.w,
        heightImage: 16.h,
        function: onPressed,
        title: 'Add Controller'.tr,
        textStyle:
            StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        image: 'assets/icons_assets/database_builder_assets/plus_head.svg',
        color: AppColors.textButton,
        svgColor: AppColors.white,
      ),
    );
  }
}
