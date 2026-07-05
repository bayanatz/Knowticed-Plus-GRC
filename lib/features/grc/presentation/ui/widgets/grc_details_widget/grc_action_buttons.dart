/// Module: GRC Module Management
/// Description: Provides the Edit and Delete action buttons shown at the top
///              of the GRC Module details page in view mode.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: AppColors, AppTheme, customButtonWithSvg, showConfirmDialog
/// Revision History: 2026-06-29 - Initial creation
///                    2026-06-30 - Added onDeleteTap callback (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_action_buttons.dart
/// Purpose: Contains GrcActionButtons, a row of Edit and Delete buttons for
///          the GRC Module details page view mode.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class GrcActionButtons extends StatelessWidget {
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const GrcActionButtons({
    super.key,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            customButtonWithSvg(
              colorBorder: AppColors.primary,
              space: 10.w,
              radius: 8.r,
              widthImage: 16.w,
              heightImage: 16.h,
              image: "assets/icons/edit.svg",
              title: isTablet ? "Edit".tr : "",
              function: onEditTap,
              width: isTablet ? 135.w : 40.w,
              height: 38.h,
              color: AppColors.primary,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.textButton),
            ),
            SizedBox(width: 10.w),
            customButtonWithSvg(
              colorBorder: AppColors.red,
              space: 10.w,
              radius: 8.r,
              widthImage: 16.w,
              heightImage: 16.h,
              image: "assets/delete.svg",
              title: isTablet ? "Delete".tr : "",
              function: () {
                showConfirmDialog(
                  context: context,
                  title: "Deleting GRC Module".tr,
                  cancelLabel: "No".tr,
                  confirmLabel: "Yes".tr,
                  iconAsset: 'assets/icons/delete_icon.svg',
                  subtitle:
                      "Are You Sure You Want To Delete This GRC Module ?".tr,
                  onConfirm: onDeleteTap,
                );
              },
              width: isTablet ? 135.w : 40.w,
              height: 38.h,
              color: AppColors.red,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.white),
            ),
          ],
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}
