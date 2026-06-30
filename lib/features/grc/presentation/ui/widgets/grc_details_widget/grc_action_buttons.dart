/// ************************* FILE INFO *************************** ///
/// File Name: grc_action_buttons.dart
/// Purpose: This file contains the implementation of the GrcActionButtons widget, which provides action buttons for managing GRC modules. It includes edit and delete functionality with confirmation dialogs.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 2026-06-29
library;

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../../settings/core_widgets/main_widget/shared_action_widgets.dart';

class GrcActionButtons extends StatelessWidget {
  final VoidCallback onEditTap;

  const GrcActionButtons({
    super.key,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
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
              title: "Edit".tr,
              function: onEditTap,
              width: 135.w,
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
              title: "Delete".tr,
              function: () {
                showConfirmDialog(
                  context: context,
                  title: "Deleting GRC Module".tr,
                  cancelLabel: "No".tr,
                  confirmLabel: "Yes".tr,
                  iconAsset: 'assets/icons/delete_icon.svg',
                  subtitle:
                      "Are You Sure You Want To Delete This GRC Module ?".tr,
                  onConfirm: () {
                    showSuccessDialog(
                      context: context,
                      title: "Deleted GRC Module".tr,
                      subtitle: "You Successfully Deleted This Module".tr,
                    );
                  },
                );
              },
              width: 135.w,
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
