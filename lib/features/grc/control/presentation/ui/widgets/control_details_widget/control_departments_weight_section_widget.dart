/// Module: GRC Policy Management
/// Description: Departments Weight chip section for the Control Details
///              page, extracted from ControlDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter, DepartmentWeight
/// Revision History: 2026-07-21 - Initial creation (inline in
///                                control_details_page.dart)
///                   2026-07-28 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_departments_weight_section_widget.dart
/// Purpose: Contains ControlDepartmentsWeightSectionWidget, the "Departments
///          Weight" label followed by one chip per department (or a single
///          "Not Assigned" chip when there are none).
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/7/2026

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_department_weight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [ControlDepartmentsWeightSectionWidget]
///
/// purpose: renders the "Departments Weight" label and one chip per
///          department, each showing "{department} | {weight}".
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/7/2026
class ControlDepartmentsWeightSectionWidget extends StatelessWidget {
  final List<DepartmentWeight> departments;

  const ControlDepartmentsWeightSectionWidget({
    super.key,
    required this.departments,
  });

  Widget _departmentChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Departments Weight'.tr,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
        SizedBox(height: 8.h),
        departments.isEmpty
            ? _departmentChip('Not Assigned'.tr)
            : Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: departments
                    .map((d) => _departmentChip(
                        '${d.department} | ${d.weight.toStringAsFixed(0)}'))
                    .toList(),
              ),
      ],
    );
  }
}
