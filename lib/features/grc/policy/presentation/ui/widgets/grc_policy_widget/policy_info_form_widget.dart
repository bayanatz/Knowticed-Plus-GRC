/// Module: GRC Policy Management
/// Description: Multi-field form widget for entering policy information.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, CustomTextField, CustomDropdownCalendar
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Split Policy Document into English/Arabic
///                   2026-07-14 - Converted to StatefulWidget; added
///                                English/Arabic language-mismatch validation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_info_form_widget.dart
/// Purpose: Contains PolicyInfoFormWidget, the form for all policy fields —
///          names, numbers, description, dates, weight, document. Validates
///          that EN fields contain no Arabic letters and vice versa.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'policy_document_preview_widget.dart';

class PolicyInfoFormWidget extends StatefulWidget {
  final bool isArabicEnabled;
  final bool submitted;

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

  final PolicyDocumentInfo? documentEn;
  final PolicyDocumentInfo? documentAr;
  final VoidCallback onUploadDocumentEn;
  final VoidCallback onUploadDocumentAr;
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;

  const PolicyInfoFormWidget({
    super.key,
    required this.isArabicEnabled,
    this.submitted = false,
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
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    this.documentEn,
    this.documentAr,
  });

  @override
  State<PolicyInfoFormWidget> createState() => _PolicyInfoFormWidgetState();
}

class _PolicyInfoFormWidgetState extends State<PolicyInfoFormWidget> {
  List<TextEditingController> get _bilingualControllers => [
        widget.nameController,
        widget.nameArController,
        widget.numberController,
        widget.numberArController,
        widget.descriptionController,
        widget.descriptionArController,
      ];

  List<TextEditingController> get _watchedControllers =>
      [..._bilingualControllers, widget.weightController];

  @override
  void initState() {
    super.initState();
    for (final c in _watchedControllers) {
      c.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    for (final c in _watchedControllers) {
      c.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  /// True once the user has entered something into any Arabic field.
  /// Turning the Arabic toggle on by itself doesn't make Name/Number/
  /// Description AR required — only starting to fill one of them in does,
  /// at which point all three become required together.
  bool get _arabicTouched =>
      widget.nameArController.text.trim().isNotEmpty ||
      widget.numberArController.text.trim().isNotEmpty ||
      widget.descriptionArController.text.trim().isNotEmpty;

  /// Live validation for the Policy Weight field: must be a positive number
  /// no greater than 100.
  String? get _weightError {
    final text = widget.weightController.text.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null) return 'Policy Weight must be a valid number';
    if (value <= 0) return 'Policy Weight must be a positive number';
    if (value > 100) return 'Policy Weight cannot be more than 100';
    return null;
  }

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
    bool isMandatory = false,
    bool onlyDigits = false,
    String? englishOnlyError,
    String? arabicOnlyError,
    String? customError,
  }) {
    final languageError = rtl
        ? (containsEnglishLetters(controller.text) ? arabicOnlyError : null)
        : (containsArabicLetters(controller.text) ? englishOnlyError : null);

    final field = CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      autoCapitalize: true,
      required: true,
      submitted: isMandatory && widget.submitted,
      onlyDigits: onlyDigits,
      errorText: customError ?? languageError,
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

  Widget _documentButton({required VoidCallback onTap, required String title}) {
    return customButtonWithSvg(
      colorBorder: AppColors.primary,
      widthImage: 16.w,
      heightImage: 16.h,
      function: onTap,
      title: title,
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
      image: 'assets/icons_assets/data_grc_assets/upload_minimalistic.svg',
      color: AppColors.primary,
      width: double.infinity,
      svgColor: AppColors.textButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final endBeforeStart = widget.endDate != null &&
        widget.startDate != null &&
        widget.endDate!.isBefore(widget.startDate!);

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
        twoColumns(
          _textField(
            label: 'Policy Name',
            hint: 'Text here',
            controller: widget.nameController,
            isMandatory: true,
            englishOnlyError: 'Policy Name must be written in English',
          ),
          widget.isArabicEnabled
              ? _textField(
                  label: 'اسم السياسة',
                  hint: 'اكتب هنا',
                  controller: widget.nameArController,
                  rtl: true,
                  isMandatory: _arabicTouched,
                  arabicOnlyError: 'يجب كتابة اسم السياسة باللغة العربية',
                )
              : _textField(
                  label: 'Policy Number',
                  hint: 'Text here',
                  controller: widget.numberController,
                  isMandatory: true,
                  onlyDigits: true,
                  englishOnlyError: 'Policy Number must be written in English',
                ),
        ),
        SizedBox(height: 15.h),
        if (widget.isArabicEnabled) ...[
          twoColumns(
            _textField(
              label: 'Policy Number',
              hint: 'Text here',
              controller: widget.numberController,
              isMandatory: true,
              onlyDigits: true,
              englishOnlyError: 'Policy Number must be written in English',
            ),
            _textField(
              label: 'رقم السياسة',
              hint: 'اكتب هنا',
              controller: widget.numberArController,
              rtl: true,
              isMandatory: _arabicTouched,
              arabicOnlyError: 'يجب كتابة رقم السياسة باللغة العربية',
            ),
          ),
          SizedBox(height: 15.h),
        ],
        _textField(
          label: 'Policy Description',
          hint: 'Text here',
          controller: widget.descriptionController,
          maxLines: 3,
          minLines: 3,
          maxLength: 500,
          showCharCount: true,
          isMandatory: true,
          englishOnlyError: 'Policy Description must be written in English',
        ),
        SizedBox(height: 15.h),
        if (widget.isArabicEnabled) ...[
          _textField(
            label: 'وصف السياسة',
            hint: 'اكتب وصف',
            controller: widget.descriptionArController,
            rtl: true,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
            isMandatory: _arabicTouched,
            arabicOnlyError: 'يجب كتابة وصف السياسة باللغة العربية',
          ),
          SizedBox(height: 15.h),
        ],
        twoColumns(
          CustomDropdownCalendar(
            borderRadius: BorderRadius.circular(4.r),
            label: 'Start Date',
            hint: 'Select Start Date',
            value: widget.startDate,
            onChanged: widget.onStartDateChanged,
            fillColor: AppColors.background,
            labelStyle:
                StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            hintStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
            required: false,
            dateFormatter: (d) => DateFormat('d MMM yyyy').format(d),
            errorText: !widget.submitted
                ? null
                : widget.startDate == null
                    ? 'This field is required.'
                    : null,
          ),
          CustomDropdownCalendar(
            borderRadius: BorderRadius.circular(4.r),
            label: 'End Date',
            hint: 'Select End Date',
            value: widget.endDate,
            onChanged: widget.onEndDateChanged,
            fillColor: AppColors.background,
            labelStyle:
                StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            hintStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
            required: false,
            firstDate: widget.startDate,
            dateFormatter: (d) => DateFormat('d MMM yyyy').format(d),
            errorText: !widget.submitted
                ? null
                : widget.endDate == null
                    ? 'This field is required.'
                    : endBeforeStart
                        ? 'End date cannot be before start date.'
                        : null,
          ),
        ),
        SizedBox(height: 15.h),
        isTablet
            ? Row(children: [
                Expanded(
                  child: _textField(
                    label: 'Policy Weight',
                    hint: 'Text here',
                    controller: widget.weightController,
                    isMandatory: true,
                    customError: _weightError,
                  ),
                ),
                SizedBox(width: 10.w),
                const Expanded(child: SizedBox()),
              ])
            : _textField(
                label: 'Policy Weight',
                hint: 'Text here',
                controller: widget.weightController,
                isMandatory: true,
                customError: _weightError,
              ),
        SizedBox(height: 15.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                spacing: 8.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Policy Document ENG',
                      style: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.text)),
                  widget.documentEn != null
                      ? PolicyDocumentPreviewWidget(
                          document: widget.documentEn!,
                          onRemove: widget.onRemoveDocumentEn)
                      : SizedBox(
                          width: double.infinity,
                          child: _documentButton(
                              onTap: widget.onUploadDocumentEn,
                              title: 'Policy Document'),
                        ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            if (widget.isArabicEnabled)
              Expanded(
                child: Column(
                  spacing: 8.h,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Policy Document AR',
                        style: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.text)),
                    widget.documentAr != null
                        ? PolicyDocumentPreviewWidget(
                            document: widget.documentAr!,
                            onRemove: widget.onRemoveDocumentAr)
                        : SizedBox(
                            width: double.infinity,
                            child: _documentButton(
                                onTap: widget.onUploadDocumentAr,
                                title: 'Policy Document'),
                          ),
                  ],
                ),
              )
            else if (isTablet)
              const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}
