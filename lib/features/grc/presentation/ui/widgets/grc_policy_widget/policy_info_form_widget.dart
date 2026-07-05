/// Module: GRC Policy Management
/// Description: Multi-field form widget for entering policy information.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, CustomTextField, CustomDropdownCalendar
/// Revision History: 2026-07-01 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_info_form_widget.dart
/// Purpose: Contains PolicyInfoFormWidget, the stateless form for all
///          policy fields — names, numbers, description, dates, weight, document.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'policy_document_preview_widget.dart';

/// class name: [PolicyInfoFormWidget]
///
/// purpose: stateless form that renders all policy data fields.
///          When isArabicEnabled is true, Arabic companion fields appear
///          alongside each English field. The parent page owns all
///          controllers and state.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyInfoFormWidget extends StatelessWidget {
  final bool isArabicEnabled;

  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController numberController;
  final TextEditingController numberArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final TextEditingController weightController;

  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  final PolicyDocumentInfo? document;
  final VoidCallback onUploadDocument;
  final VoidCallback onRemoveDocument;

  const PolicyInfoFormWidget({
    super.key,
    required this.isArabicEnabled,
    required this.nameController,
    required this.nameArController,
    required this.numberController,
    required this.numberArController,
    required this.descriptionController,
    required this.descriptionArController,
    required this.weightController,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onUploadDocument,
    required this.onRemoveDocument,
    this.document,
  });

  TextStyle get _labelStyle =>
      AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp);
  TextStyle get _valueStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText);
  TextStyle get _hintStyle => StyleText.fontSize14Weight500
      .copyWith(color: AppColors.secondaryText.withOpacity(.5));

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool rtl = false,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool showCharCount = false,
  }) {
    final field = CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      required: true,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCharCount: showCharCount,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      height: maxLines == null ? 30.h : null,
      valueStyle: _valueStyle,
      hintStyle: _hintStyle,
      labelStyle: _labelStyle,
      onChanged: (_) {},
    );

    if (!rtl) return field;
    return Directionality(textDirection: TextDirection.rtl, child: field);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    Widget twoColumns(Widget left, Widget right) => isTablet
        ? Row(children: [
            Expanded(child: left),
            SizedBox(width: 10.w),
            Expanded(child: right),
          ])
        : Column(children: [
            left,
            SizedBox(height: 15.h),
            right,
          ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Policy Name + AR name (or Policy Number when AR disabled)
        twoColumns(
          _textField(label: 'Policy Name', hint: 'Text here', controller: nameController),
          isArabicEnabled
              ? _textField(label: 'اسم السياسة', hint: 'اكتب هنا', controller: nameArController, rtl: true)
              : _textField(label: 'Policy Number', hint: 'Text here', controller: numberController),
        ),
        SizedBox(height: 15.h),
        if (isArabicEnabled) ...[
          twoColumns(
            _textField(label: 'Policy Number', hint: 'Text here', controller: numberController),
            _textField(label: 'رقم السياسة', hint: 'اكتب هنا', controller: numberArController, rtl: true),
          ),
          SizedBox(height: 15.h),
        ],
        _textField(
          label: 'Policy Description',
          hint: 'Text here',
          controller: descriptionController,
          maxLines: 3,
          minLines: 3,
          maxLength: 500,
          showCharCount: true,
        ),
        SizedBox(height: 15.h),
        if (isArabicEnabled) ...[
          _textField(
            label: 'وصف السياسة',
            hint: 'اكتب وصف',
            controller: descriptionArController,
            rtl: true,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
          ),
          SizedBox(height: 15.h),
        ],
        // Start Date + End Date
        twoColumns(
          CustomDropdownCalendar(
            borderRadius: BorderRadius.circular(4.r),
            label: 'Start Date',
            hint: 'Select Start Date',
            value: startDate,
            onChanged: onStartDateChanged,
            fillColor: AppColors.background,
            labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            hintStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
            required: false,
          ),
          CustomDropdownCalendar(
            borderRadius: BorderRadius.circular(4.r),
            label: 'End Date',
            hint: 'Select End Date',
            value: endDate,
            onChanged: onEndDateChanged,
            fillColor: AppColors.background,
            labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            hintStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
            required: false,
          ),
        ),
        SizedBox(height: 15.h),
        // Policy Weight (half-width on tablet, full-width on mobile)
        isTablet
            ? Row(children: [
                Expanded(child: _textField(label: 'Policy Weight', hint: 'Text here', controller: weightController)),
                SizedBox(width: 10.w),
                const Expanded(child: SizedBox()),
              ])
            : _textField(label: 'Policy Weight', hint: 'Text here', controller: weightController),
        SizedBox(height: 15.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Policy Document',
              style:
                  StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            ),
            const Spacer(),
            if (document != null)
              Flexible(
                child: PolicyDocumentPreviewWidget(
                  document: document!,
                  onRemove: onRemoveDocument,
                ),
              )
            else
              customButtonWithSvg(
                colorBorder: AppColors.primary,
                space: 10.w,
                radius: 8.r,
                widthImage: 16.w,
                heightImage: 16.h,
                function: onUploadDocument,
                title: 'Policy Document',
                textStyle: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.textButton),
                image: 'assets/hrAsset/Upload.svg',
                color: AppColors.primary,
                width: 180.w,
                height: 36.h,
                svgColor: AppColors.textButton,
              ),
          ],
        ),
        SizedBox(height: 30.h),
      ],
    );
  }
}
