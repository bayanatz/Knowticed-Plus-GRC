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

import 'dart:io';

import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_responsive_field_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'policy_document_preview_widget.dart';

class PolicyInfoFormWidget extends StatefulWidget {
  final bool isArabicEnabled;
  final bool submitted;

  /// When true (the Create New Policy wizard's Preview step), every upload
  /// action is a no-op, so an empty document should show nothing instead
  /// of an "Upload" button that looks actionable but isn't.
  final bool readOnly;

  /// The policy's picked image, shown read-only above the form when set.
  /// [imageFile] takes priority over [imageUrl] (mirrors CustomImagePicker).
  final File? imageFile;
  final String? imageUrl;

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
    this.readOnly = false,
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
    this.imageFile,
    this.imageUrl,
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
    if (value == null) return 'Policy Weight must be a valid number'.tr;
    if (value <= 0) return 'Policy Weight must be a positive number'.tr;
    if (value > 100) return 'Policy Weight cannot be more than 100'.tr;
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

    final requiredError = (rtl &&
            isMandatory &&
            widget.submitted &&
            controller.text.trim().isEmpty)
        ? 'هذا الحقل مطلوب'
        : null;

    final field = CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      autoCapitalize: true,
      required: true,
      readOnly: widget.readOnly,
      submitted: isMandatory && widget.submitted,
      onlyDigits: onlyDigits,
      errorText: customError ?? requiredError ?? languageError,
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

  /// function name: [_documentSection]
  ///
  /// purpose: one Policy Document column (label + content). When there's
  ///          no document and [PolicyInfoFormWidget.readOnly] is true (the
  ///          Preview step, where uploading is a no-op), renders nothing at
  ///          all instead of a dead-looking "Upload" button.
  ///
  /// parameters:
  ///            [String] title: the column's label text
  ///            [PolicyDocumentInfo?] document: the uploaded document, if any
  ///            [VoidCallback] onUpload: invoked when "Upload" is tapped
  ///            [VoidCallback] onRemove: invoked when the uploaded document is removed
  ///
  /// return type: [Widget]
  Widget _documentSection({
    required String title,
    required PolicyDocumentInfo? document,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    if (document == null && widget.readOnly) return const SizedBox.shrink();
    return Expanded(
      child: Column(
        spacing: 8.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.text)),
          document != null
              ? PolicyDocumentPreviewWidget(
                  document: document, onRemove: onRemove)
              : SizedBox(
                  width: double.infinity,
                  child: _documentButton(
                      onTap: onUpload, title: 'Policy Document'.tr),
                ),
        ],
      ),
    );
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

  /// function name: [_readOnlyImage]
  ///
  /// purpose: read-only preview of [PolicyInfoFormWidget.imageFile]/
  ///          [PolicyInfoFormWidget.imageUrl] — the same File/URL priority
  ///          [CustomImagePicker] uses, minus its edit badge, since this is
  ///          only ever passed in from the Preview step. Only called when
  ///          one of the two is present.
  ///
  /// parameters: none
  ///
  /// return type: [Widget]
  Widget _readOnlyImage() {
    return CircleAvatar(
      radius: 30.r,
      backgroundColor: AppColors.grey,
      backgroundImage: widget.imageFile != null
          ? FileImage(widget.imageFile!.absolute) as ImageProvider
          : NetworkImage(widget.imageUrl!),
    );
  }

  /// The Policy Name (English) + (Arabic-or-Number) paired row.
  Widget _buildNameRow(bool isTablet) {
    return GrcResponsiveFieldRow(
      isTablet: isTablet,
      children: [
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
                arabicOnlyError: 'يجب كتابة اسم الوثيقة باللغة العربية',
              )
            : _textField(
                label: 'Policy Number',
                hint: 'Text here',
                controller: widget.numberController,
                isMandatory: true,
                englishOnlyError: 'Policy Number must be written in English',
              ),
      ],
    );
  }

  /// The Policy Number (English) + (Arabic) paired row — Arabic mode only.
  Widget _buildNumberRow(bool isTablet) {
    return GrcResponsiveFieldRow(
      isTablet: isTablet,
      children: [
        _textField(
          label: 'GRC Policy Number'.tr,
          hint: 'Text here'.tr,
          controller: widget.numberController,
          isMandatory: true,
          englishOnlyError: 'Policy Number must be written in English'.tr,
        ),
        _textField(
          label: 'رقم السياسة',
          hint: 'اكتب هنا',
          controller: widget.numberArController,
          rtl: true,
          isMandatory: _arabicTouched,
          arabicOnlyError: 'يجب كتابة رقم الوثيقة باللغة العربية',
        ),
      ],
    );
  }

  /// The Policy Description (English) and, in Arabic mode, (Arabic) fields.
  Widget _buildDescriptionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textField(
          label: 'Policy Description'.tr,
          hint: 'Text here'.tr,
          controller: widget.descriptionController,
          maxLines: 3,
          minLines: 3,
          maxLength: 500,
          showCharCount: true,
          isMandatory: true,
          englishOnlyError: 'Policy Description must be written in English'.tr,
        ),
        if (widget.isArabicEnabled) ...[
          SizedBox(height: 15.h),
          _textField(
            label: 'وصف السياسة',
            hint: 'اكتب وصفًا',
            controller: widget.descriptionArController,
            rtl: true,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
            isMandatory: _arabicTouched,
            arabicOnlyError: 'يجب كتابة وصف السياسة باللغة العربية',
          ),
        ],
      ],
    );
  }

  /// The Start Date + End Date paired row.
  Widget _buildDateRow(bool isTablet) {
    final endBeforeStart = widget.endDate != null &&
        widget.startDate != null &&
        widget.endDate!.isBefore(widget.startDate!);

    return GrcResponsiveFieldRow(
      isTablet: isTablet,
      children: [
        CustomDropdownCalendar(
          borderRadius: BorderRadius.circular(4.r),
          label: 'Start Date'.tr,
          hint: 'Select Start Date'.tr,
          value: widget.startDate,
          onChanged: widget.onStartDateChanged,
          enabled: !widget.readOnly,
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
                  ? 'This field is required.'.tr
                  : null,
        ),
        CustomDropdownCalendar(
          borderRadius: BorderRadius.circular(4.r),
          label: 'End Date'.tr,
          hint: 'Select End Date'.tr,
          value: widget.endDate,
          onChanged: widget.onEndDateChanged,
          enabled: !widget.readOnly,
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
                  ? 'This field is required.'.tr
                  : endBeforeStart
                      ? 'End date cannot be before start date.'.tr
                      : null,
        ),
      ],
    );
  }

  /// The Policy Weight field. On tablets it's paired with an empty spacer
  /// column to keep it half-width, matching the other paired rows; on
  /// phones it's rendered alone, full width.
  ///
  /// NOTE: intentionally NOT routed through [GrcResponsiveFieldRow] — the
  /// phone branch renders the field by itself with no matching second
  /// child/gap, which the shared helper's Column would add unconditionally.
  /// Preserved exactly as it was inline — this is a pure move, not a
  /// behavior change.
  Widget _buildWeightRow(bool isTablet) {
    final weightField = _textField(
      label: 'Policy Weight'.tr,
      hint: 'Text here'.tr,
      controller: widget.weightController,
      isMandatory: true,
      customError: _weightError,
    );

    return isTablet
        ? Row(children: [
            Expanded(child: weightField),
            SizedBox(width: 10.w),
            const Expanded(child: SizedBox()),
          ])
        : weightField;
  }

  /// The Policy Document upload columns.
  Widget _buildDocumentsRow(bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _documentSection(
          title: 'Policy Document ENG'.tr,
          document: widget.documentEn,
          onUpload: widget.onUploadDocumentEn,
          onRemove: widget.onRemoveDocumentEn,
        ),
        SizedBox(width: 10.w),
        if (widget.isArabicEnabled)
          _documentSection(
            title: 'Policy Document AR'.tr,
            document: widget.documentAr,
            onUpload: widget.onUploadDocumentAr,
            onRemove: widget.onRemoveDocumentAr,
          )
        else if (isTablet)
          const Expanded(child: SizedBox()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.imageFile != null ||
            (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)) ...[
          _readOnlyImage(),
          SizedBox(height: 16.h),
        ],
        _buildNameRow(isTablet),
        SizedBox(height: 15.h),
        if (widget.isArabicEnabled) ...[
          _buildNumberRow(isTablet),
          SizedBox(height: 15.h),
        ],
        _buildDescriptionFields(),
        SizedBox(height: 15.h),
        _buildDateRow(isTablet),
        SizedBox(height: 15.h),
        _buildWeightRow(isTablet),
        SizedBox(height: 15.h),
        _buildDocumentsRow(isTablet),
      ],
    );
  }
}
