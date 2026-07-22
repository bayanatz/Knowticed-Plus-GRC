/// Module: GRC Policy Management
/// Description: Bottom action buttons for step 1 (Controls) of the Create
///              Policy page — Save For Later and Preview.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-16
/// Dependencies: Flutter SDK, AppColors, StyleText, customButton
/// Revision History: 2026-07-16 - Extracted from create_new_policy.dart
library;

/// ************************* FILE INFO *************************** ///
/// File Name: create_policy_step1_buttons.dart
/// Purpose: Contains CreatePolicyStep1Buttons, the Save For Later/Preview
///          button row shown on step 1 of CreateNewPolicyPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 16/7/2026

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [CreatePolicyStep1Buttons]
///
/// purpose: Save For Later/Preview button row for step 1. All validation,
///          dialogs, and step transitions are handled by the parent page
///          via the callbacks; this widget only renders the row.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 16/7/2026
class CreatePolicyStep1Buttons extends StatelessWidget {
  final VoidCallback onSaveForLater;
  final VoidCallback onPreview;
  final bool previewEnabled;

  const CreatePolicyStep1Buttons({
    super.key,
    required this.onSaveForLater,
    required this.onPreview,
    required this.previewEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: 'Save For Later'.tr,
          function: onSaveForLater,
          height: 38.h,
          width: 150.w,
          color: AppColors.grey,
          textStyle:
              StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        customButton(
          title: 'Preview'.tr,
          // Greyed and inert until the form actually validates — replaces
          // the old always-clickable button whose only feedback was
          // per-field required errors triggered by touching any field.
          function: previewEnabled ? onPreview : () {},
          height: 38.h,
          width: 150.w,
          color: previewEnabled ? AppColors.primary : AppColors.colorGrey,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }
}
