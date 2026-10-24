// ****************** FILE INFO ******************
// File Name: crm_custom_grid_edit_actions.dart
// Purpose: Bottom action buttons row (Discard and Submit) for Custom Grid edit mode
// Author: Mohand Adel
// Created At: 10/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmCustomGridEditActions extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback onSubmit;
  final bool isSaving;

  const CrmCustomGridEditActions({
    super.key,
    required this.onDiscard,
    required this.onSubmit,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: Row(
        textDirection: TextDirection
            .ltr, // X-73: Cancel left, action right in both languages

        children: [
          Expanded(
            child: SizedBox(
              height: 42.sp,
              child: customButton(
                title: S.current.crmDiscard,
                color: AppColors.disabledGrey,
                textStyle: StyleText.fontSize14Weight600.copyWith(
                  color: AppColors.blackButton,
                ),
                function: isSaving ? () {} : onDiscard,
              ),
            ),
          ),
          SizedBox(width: 12.sp),
          Expanded(
            child: SizedBox(
              height: 42.sp,
              child: isSaving
                  ? const Center(child: CircleProgressMaster())
                  : customButton(
                      title: S.current.submit,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize14Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                      function: onSubmit,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
