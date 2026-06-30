/// Module: GRC Module Management
/// Description: Provides the form input fields for the GRC Module details page,
///              including bilingual name/description fields, department dropdown,
///              and activation date picker.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: AppColors, CustomTextField, CustomDropdown, CustomDropdownCalendar
/// Revision History: 2026-06-29 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_form_fields.dart
/// Purpose: Contains GrcFormFields, a stateless widget that renders all input
///          fields needed to create or edit a GRC Module record.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// class name: [GrcFormFields]
///
/// purpose: stateless form section for a GRC Module. Renders bilingual name
///          fields (EN/AR), bilingual description fields, owning-department
///          dropdown, and activation-date picker. All values are managed by the
///          parent page's state via controllers and callbacks.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 29/6/2026
class GrcFormFields extends StatelessWidget {
  final TextEditingController nameEnController;
  final TextEditingController nameArController;
  final TextEditingController descEnController;
  final TextEditingController descArController;
  final String? selectedDepartment;
  final DateTime? activationDate;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<DateTime?> onDateChanged;

  const GrcFormFields({
    super.key,
    required this.nameEnController,
    required this.nameArController,
    required this.descEnController,
    required this.descArController,
    required this.selectedDepartment,
    required this.activationDate,
    required this.onDepartmentChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Module name (EN + AR) ─────────────────────
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'GRC Module Name',
                hint: 'Text here',
                controller: nameEnController,
                required: true,
                fillColor: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                height: 30.h,
                valueStyle: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.secondaryText),
                hintStyle: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
                labelStyle: AppTextStyles.font16BlackRegularCairo
                    .copyWith(fontSize: 14.sp),
                onChanged: (_) {},
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: CustomTextField(
                  label: 'عنوان اطار الحوكمه',
                  hint: 'اكتب هنا',
                  controller: nameArController,
                  required: true,
                  fillColor: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  height: 30.h,
                  valueStyle: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.secondaryText),
                  hintStyle: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
                  labelStyle: AppTextStyles.font16BlackRegularCairo
                      .copyWith(fontSize: 14.sp),
                  onChanged: (_) {},
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),

        // ── Description EN ────────────────────────────
        CustomTextField(
          label: 'Description',
          hint: 'Text here',
          controller: descEnController,
          required: true,
          maxLines: 3,
          minLines: 3,
          maxLength: 500,
          showCharCount: true,
          fillColor: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          valueStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
          hintStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
          labelStyle:
              AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 15.h),

        // ── Description AR ────────────────────────────
        Directionality(
          textDirection: TextDirection.rtl,
          child: CustomTextField(
            label: 'الوصف',
            hint: 'اكتب وصف',
            controller: descArController,
            required: true,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
            fillColor: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            valueStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
            hintStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
            labelStyle:
                AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp),
          ),
        ),
        SizedBox(height: 15.h),

        // ── Owning Department + Activation Date ───────
        Row(
          children: [
            Expanded(
              child: CustomDropdown<String>(
                label: 'Owning Department',
                hint: 'Choose Department',
                items: ['Department 1', 'Department 2', 'Department 3']
                    .map((d) => DropdownItem<String>(value: d, label: d))
                    .toList(),
                value: selectedDepartment,
                onChanged: onDepartmentChanged,
                fillColor: AppColors.background,
                labelStyle: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.text,
                ),
                hintStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText.withOpacity(.7),
                ),
                itemStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.text,
                ),
                triggerPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                borderRadius: BorderRadius.circular(4.r),
                required: false,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CustomDropdownCalendar(
                borderRadius: BorderRadius.circular(4.r),
                label: 'Activation Date',
                hint: 'Select Activation Date',
                value: activationDate,
                onChanged: onDateChanged,
                fillColor: AppColors.background,
                labelStyle: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.text,
                ),
                hintStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText.withOpacity(.7),
                ),
                required: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
