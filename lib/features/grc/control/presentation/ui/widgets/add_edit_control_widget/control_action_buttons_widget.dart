/// Module: GRC Policy Management
/// Description: Bottom action bar (Discard / Save For Later / Add-or-Save)
///              for the Add/Edit Control form, extracted from
///              AddEditControlPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter, CustomButton
/// Revision History: 2026-07-15 - Initial creation (inline in
///                                add_edit_control_page.dart)
///                   2026-07-27 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_action_buttons_widget.dart
/// Purpose: Contains ControlActionButtonsWidget, the bottom action bar:
///          Discard on the left, and (Save For Later +) Add/Save on the
///          right. Purely layout — every button's confirm-dialog and save
///          logic lives on AddEditControlPage and is invoked via the
///          callbacks passed in.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026

import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// class name: [ControlActionButtonsWidget]
///
/// purpose: renders the Discard / Save For Later / Add-or-Save buttons.
///          [onSaveDraft] is null in Edit mode, hiding the "Save For Later"
///          button entirely — a saved Control has no "draft" concept.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class ControlActionButtonsWidget extends StatelessWidget {
  final bool isEdit;
  final VoidCallback onDiscard;
  final VoidCallback? onSaveDraft;
  final VoidCallback onSave;

  const ControlActionButtonsWidget({
    super.key,
    required this.isEdit,
    required this.onDiscard,
    required this.onSaveDraft,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: 'Discard'.tr,
          function: onDiscard,
          height: 38.h,
          width: 150.w,
          color: AppColors.grey,
          textColor: AppColors.text,
          borderColor: AppColors.border,
        ),
        Row(
          children: [
            if (onSaveDraft != null) ...[
              customButton(
                title: 'Save For Later'.tr,
                function: onSaveDraft!,
                height: 38.h,
                width: 150.w,
                color: AppColors.grey,
                textColor: AppColors.text,
                borderColor: AppColors.border,
              ),
              SizedBox(width: 10.w),
            ],
            customButton(
              title: isEdit ? 'Save'.tr : 'Add'.tr,
              function: onSave,
              height: 38.h,
              width: 150.w,
              color: AppColors.primary,
              textColor: AppColors.textButton,
            ),
          ],
        ),
      ],
    );
  }
}
