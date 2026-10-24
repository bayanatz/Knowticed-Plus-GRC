// ***************************** FILE INFO ***************************** //
// File Name: hr_employee_view_buttons.dart
// Purpose: Renders the HR employee list and grid view selection buttons.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_view_mode_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/enums/ui_controllers/hr_employee_view_mode.dart';

class HrEmployeeViewButtons extends StatelessWidget {
  const HrEmployeeViewButtons({
    required this.selectedMode,
    required this.onChanged,
    super.key,
  });

  final HrEmployeeViewMode selectedMode;
  final ValueChanged<HrEmployeeViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        customViewModeButton(
          mode: ViewMode.list,
          function: () => onChanged(HrEmployeeViewMode.table),
          isSelected: selectedMode == HrEmployeeViewMode.table,
          color: AppColors.card,
          selectedColor: AppColors.primary,
          svgColor: AppColors.text,
          selectedSvgColor: AppColors.textButton,
        ),
        SizedBox(width: 8.w),
        customViewModeButton(
          mode: ViewMode.grid,
          function: () => onChanged(HrEmployeeViewMode.grid),
          isSelected: selectedMode == HrEmployeeViewMode.grid,
          color: AppColors.card,
          selectedColor: AppColors.primary,
          svgColor: AppColors.text,
          selectedSvgColor: AppColors.textButton,
        ),
      ],
    );
  }
}
