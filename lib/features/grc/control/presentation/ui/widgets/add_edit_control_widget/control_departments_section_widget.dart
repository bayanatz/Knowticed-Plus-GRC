/// Module: GRC Policy Management
/// Description: Department multi-select + Equal Weights section for the
///              Add/Edit Control form (Edit mode only), extracted from
///              AddEditControlPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter, flutter_switch, CustomMultiSelectDropdown,
///               CustomTextField
/// Revision History: 2026-07-15 - Initial creation (inline in
///                                add_edit_control_page.dart)
///                   2026-07-27 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_departments_section_widget.dart
/// Purpose: Contains ControlDepartmentsSectionWidget, the Department
///          multi-select and per-department weight rows. All selection
///          reconciliation logic (checking "All", equal-split, adding or
///          removing a department) stays on AddEditControlPage — this
///          widget is a pure display/toggle layer that reports every
///          interaction back via callbacks.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026

import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';

/// class name: [ControlDepartmentsSectionWidget]
///
/// purpose: renders the Department multi-select next to the Equal Weights
///          toggle. Checking "All" (or every real department individually)
///          selects every department and locks Equal Weights on, since an
///          all-department split is always equal. Otherwise Equal Weights
///          is user-controlled: on auto-splits 100 across the selection,
///          off shows an editable weight row per selected department with
///          a running total below (highlighted in red until it sums to
///          100).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class ControlDepartmentsSectionWidget extends StatelessWidget {
  final String allDepartmentsValue;
  final List<String> availableDepartmentNames;
  final List<String> selectedDepartments;
  final List<String> realSelectedDepartments;
  final bool isAllDepartmentsSelected;
  final bool equalWeights;
  final Map<String, TextEditingController> departmentWeightControllers;
  final double totalDepartmentsWeight;
  final bool isDepartmentsWeightValid;
  final bool submitted;
  final void Function(List<String> newSelection) onDepartmentsChanged;
  final ValueChanged<bool> onEqualWeightsChanged;
  final ValueChanged<String> onRemoveDepartment;

  const ControlDepartmentsSectionWidget({
    super.key,
    required this.allDepartmentsValue,
    required this.availableDepartmentNames,
    required this.selectedDepartments,
    required this.realSelectedDepartments,
    required this.isAllDepartmentsSelected,
    required this.equalWeights,
    required this.departmentWeightControllers,
    required this.totalDepartmentsWeight,
    required this.isDepartmentsWeightValid,
    required this.submitted,
    required this.onDepartmentsChanged,
    required this.onEqualWeightsChanged,
    required this.onRemoveDepartment,
  });

  /// function name: [_buildDepartmentWeightRow]
  ///
  /// purpose: render a single selected department's name alongside its
  ///          weight field and a control to remove it from the selection.
  ///          The weight field is editable while Equal Weights is off, and
  ///          read-only (showing the auto-computed equal share) while it's
  ///          on — hidden entirely only when "All" is selected instead.
  ///
  /// parameters:
  ///            [String] department: the department name this row represents
  ///
  /// return type: [Widget] - the row widget for this department
  Widget _buildDepartmentWeightRow(String department) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40.h,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                department,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: CustomTextField(
              hint: '0',
              controller: departmentWeightControllers[department],
              fillColor: AppColors.background,
              readOnly: equalWeights,
              onChanged: equalWeights ? null : (_) {},
            ),
          ),
          SizedBox(width: 4.w),
          IconButton(
            icon: Icon(Icons.remove_circle, color: AppColors.red, size: 20.sp),
            onPressed: () => onRemoveDepartment(department),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomMultiSelectDropdown<String>(
                label: 'Department'.tr,
                hint: 'Select Department'.tr,
                items: [
                  MultiSelectDropdownItem<String>(
                      value: allDepartmentsValue, label: 'All'.tr),
                  ...availableDepartmentNames.map(
                    (d) => MultiSelectDropdownItem<String>(value: d, label: d),
                  ),
                ],
                values: selectedDepartments,
                onChanged: onDepartmentsChanged,
                fillColor: AppColors.background,
                errorText: submitted && realSelectedDepartments.isEmpty
                    ? 'This field is required.'.tr
                    : null,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Equal Weights'.tr,
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.text),
                  ),
                  Spacer(),
                  FlutterSwitch(
                    width: 38.sp,
                    height: 22.sp,
                    padding: 3.sp,
                    borderRadius: 20.sp,
                    toggleSize: 16.sp,
                    activeColor: AppColors.secondaryPrimary,
                    inactiveColor: Colors.grey.withValues(alpha: 0.16),
                    value: equalWeights,
                    onToggle: onEqualWeightsChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (realSelectedDepartments.isNotEmpty && !isAllDepartmentsSelected) ...[
          SizedBox(height: 15.h),
          ...realSelectedDepartments.map(_buildDepartmentWeightRow),
          Container(
            width: 160.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDepartmentsWeightValid
                    ? AppColors.border
                    : AppColors.red,
              ),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '${'Total Weight'.tr} : ${totalDepartmentsWeight.toStringAsFixed(0)}',
              style: StyleText.fontSize14Weight500.copyWith(
                color: isDepartmentsWeightValid ? AppColors.text : AppColors.red,
              ),
            ),
          ),
          if (!isDepartmentsWeightValid) ...[
            SizedBox(height: 4.h),
            Text(
              'Total Weight should be 100'.tr,
              style:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
            ),
          ],
        ],
      ],
    );
  }
}
