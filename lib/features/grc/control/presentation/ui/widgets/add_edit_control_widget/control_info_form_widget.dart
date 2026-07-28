/// Module: GRC Policy Management
/// Description: Name/Number/Description fields for the Add/Edit Control
///              form, extracted from AddEditControlPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter, CustomTextField, GrcResponsiveFieldRow
/// Revision History: 2026-07-15 - Initial creation (inline in
///                                add_edit_control_page.dart)
///                   2026-07-27 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_info_form_widget.dart
/// Purpose: Contains ControlInfoFormWidget, the Control Name/Number/
///          Description fields row group, with live English-only/
///          Arabic-only language-mismatch validation.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026

import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/shared/widgets/grc_responsive_field_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// class name: [ControlInfoFormWidget]
///
/// purpose: renders the Control Name (English + Arabic-or-Number) row, the
///          Control Number (English + Arabic) row (Arabic mode only), and
///          the Control Description (English + Arabic) fields. Mirrors the
///          English-only/Arabic-only language-mismatch validation that lived
///          on AddEditControlPage's `_textField`.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class ControlInfoFormWidget extends StatefulWidget {
  final bool isTablet;
  final bool isArabicEnabled;
  final bool submitted;
  final bool arabicTouched;

  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController numberController;
  final TextEditingController numberArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;

  const ControlInfoFormWidget({
    super.key,
    required this.isTablet,
    required this.isArabicEnabled,
    required this.submitted,
    required this.arabicTouched,
    required this.nameController,
    required this.nameArController,
    required this.numberController,
    required this.numberArController,
    required this.descriptionController,
    required this.descriptionArController,
  });

  @override
  State<ControlInfoFormWidget> createState() => _ControlInfoFormWidgetState();
}

class _ControlInfoFormWidgetState extends State<ControlInfoFormWidget> {
  List<TextEditingController> get _watchedControllers => [
        widget.nameController,
        widget.nameArController,
        widget.numberController,
        widget.numberArController,
        widget.descriptionController,
        widget.descriptionArController,
      ];

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

  /// Shared text field builder: shows a live English-only/Arabic-only
  /// language-mismatch error, matching the same rule used elsewhere in
  /// this feature (e.g. PolicyControlItemWidget).
  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool rtl = false,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool showCharCount = false,
    bool submitted = false,
    String? englishOnlyError,
    String? arabicOnlyError,
  }) {
    final languageError = rtl
        ? (containsEnglishLetters(controller.text) ? arabicOnlyError : null)
        : (containsArabicLetters(controller.text) ? englishOnlyError : null);

    final field = CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      required: true,
      submitted: submitted,
      errorText: languageError,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCharCount: showCharCount,
      fillColor: AppColors.background,
      onChanged: (_) {},
    );

    if (!rtl) return field;
    return Directionality(textDirection: TextDirection.rtl, child: field);
  }

  /// The Control Name (English) + (Arabic-or-Number) paired row.
  Widget _buildNameRow() {
    return GrcResponsiveFieldRow(
      isTablet: widget.isTablet,
      children: [
        _textField(
          label: 'Control Name'.tr,
          hint: 'Text here'.tr,
          controller: widget.nameController,
          submitted: widget.submitted,
          englishOnlyError: 'Control Name must be written in English'.tr,
        ),
        widget.isArabicEnabled
            ? _textField(
                label: 'Control Name'.tr,
                hint: 'Type here'.tr,
                controller: widget.nameArController,
                rtl: true,
                submitted: widget.submitted && widget.arabicTouched,
                arabicOnlyError: 'Control Name must be written in Arabic'.tr,
              )
            : _textField(
                label: 'Control Number'.tr,
                hint: 'Text here'.tr,
                controller: widget.numberController,
                submitted: widget.submitted,
                englishOnlyError:
                    'Control Number must be written in English'.tr,
              ),
      ],
    );
  }

  /// The Control Number (English) + (Arabic) paired row — Arabic mode only.
  Widget _buildNumberRow() {
    return GrcResponsiveFieldRow(
      isTablet: widget.isTablet,
      children: [
        _textField(
          label: 'Control Number'.tr,
          hint: 'Text here'.tr,
          controller: widget.numberController,
          submitted: widget.submitted,
          englishOnlyError: 'Control Number must be written in English'.tr,
        ),
        _textField(
          label: 'Control Number'.tr,
          hint: 'Type here'.tr,
          controller: widget.numberArController,
          rtl: true,
          submitted: widget.submitted && widget.arabicTouched,
          arabicOnlyError: 'Control Number must be written in Arabic'.tr,
        ),
      ],
    );
  }

  /// The Control Description (English) and, in Arabic mode, (Arabic) fields.
  Widget _buildDescriptionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textField(
          label: 'Control Description'.tr,
          hint: 'Text here'.tr,
          controller: widget.descriptionController,
          submitted: widget.submitted,
          maxLines: 3,
          minLines: 3,
          maxLength: 500,
          showCharCount: true,
          englishOnlyError:
              'Control Description must be written in English'.tr,
        ),
        if (widget.isArabicEnabled) ...[
          SizedBox(height: 15.h),
          _textField(
            label: 'Control Description'.tr,
            hint: 'Write a Description'.tr,
            controller: widget.descriptionArController,
            rtl: true,
            submitted: widget.submitted && widget.arabicTouched,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
            arabicOnlyError: 'Control Description must be written in Arabic'.tr,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameRow(),
        SizedBox(height: 15.h),
        if (widget.isArabicEnabled) ...[
          _buildNumberRow(),
          SizedBox(height: 15.h),
        ],
        _buildDescriptionFields(),
      ],
    );
  }
}
