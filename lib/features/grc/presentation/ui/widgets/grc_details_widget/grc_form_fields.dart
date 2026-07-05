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
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
  final bool submitted;
  final bool readOnly;

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
    this.submitted = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final requiredError =
        context.isArabic ? 'هذا الحقل مطلوب' : 'This field is required.';

    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final nameEnField = CustomTextField(
      label: 'GRC Module Name',
      hint: 'Text here',
      controller: nameEnController,
      errorText: "GRC Module Name is required",
      submitted: submitted,
      readOnly: readOnly,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      height: 30.h,
      valueStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
      labelStyle:
          AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp),
      onChanged: (_) {},
    );

    final nameArField = Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextField(
        label: 'عنوان اطار الحوكمه',
        hint: 'اكتب هنا',
        controller: nameArController,
        errorText: "عنوان اطار الحوكمه مطلوب",
        submitted: submitted,
        readOnly: readOnly,
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        height: 30.h,
        valueStyle:
            StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText),
        hintStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
        labelStyle:
            AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp),
        onChanged: (_) {},
      ),
    );

    final departmentField = CustomDropdown<String>(
      label: 'Owning Department'.tr,
      hint: 'Choose Department'.tr,
      items: Get.find<MainCoreDepartmentController>().departmentIds.map((id) {
        final depCtrl = Get.find<MainCoreDepartmentController>();
        final label = FormatHelper.capitalize(
          context.isArabic
              ? depCtrl.getArabicDepartmentNameFromDepartmentId(
                      departmentId: id) ??
                  ''
              : depCtrl.getEnglishDepartmentNameFromDepartmentId(
                      departmentId: id) ??
                  '',
        );
        return DropdownItem<String>(value: id, label: label);
      }).toList(),
      value: selectedDepartment,
      onChanged: onDepartmentChanged,
      enabled: !readOnly,
      fillColor: AppColors.background,
      errorText:
          submitted && selectedDepartment == null ? requiredError : null,
      labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
      itemStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      triggerPadding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      borderRadius: BorderRadius.circular(4.r),
      required: false,
    );

    final activationDateField = CustomDropdownCalendar(
      borderRadius: BorderRadius.circular(4.r),
      label: 'Activation Date'.tr,
      hint: 'Select Activation Date'.tr,
      value: activationDate,
      onChanged: onDateChanged,
      enabled: !readOnly,
      fillColor: AppColors.background,
      errorText: submitted && activationDate == null ? requiredError : null,
      labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
      required: false,
    );

    return Column(
      children: [
        // ── Module name (EN + AR) ─────────────────────────────────────────────
        Directionality(
          textDirection: TextDirection.ltr,
          child: isTablet
              ? Row(
                  children: [
                    Expanded(child: nameEnField),
                    SizedBox(width: 10.w),
                    Expanded(child: nameArField),
                  ],
                )
              : Column(
                  children: context.isArabic
                      ? [
                          nameArField,
                          SizedBox(height: 15.h),
                          nameEnField,
                        ]
                      : [
                          nameEnField,
                          SizedBox(height: 15.h),
                          nameArField,
                        ],
                ),
        ),
        SizedBox(height: 15.h),

        // ── Description EN ────────────────────────────────────────────────────
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomTextField(
            label: 'Description',
            hint: 'Text here',
            controller: descEnController,
            errorText: "Description is required",
            submitted: submitted,
            readOnly: readOnly,
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

        // ── Description AR ────────────────────────────────────────────────────
        Directionality(
          textDirection: TextDirection.rtl,
          child: CustomTextField(
            label: 'الوصف',
            hint: 'اكتب وصف',
            controller: descArController,
            errorText: "الوصف مطلوب",
            submitted: submitted,
            readOnly: readOnly,
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

        // ── Owning Department + Activation Date ───────────────────────────────
        isTablet
            ? Row(
                children: [
                  Expanded(child: departmentField),
                  SizedBox(width: 10.w),
                  Expanded(child: activationDateField),
                ],
              )
            : Column(
                children: [
                  departmentField,
                  SizedBox(height: 15.h),
                  activationDateField,
                ],
              ),
      ],
    );
  }
}
