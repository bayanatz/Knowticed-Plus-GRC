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

import 'package:grc_module/core/custom/1-custom_dropdwon.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/custom/3-custom_dropdwon_calander.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:grc_module/generated/l10n.dart';

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
bool containsEnglishLetters(String text) => RegExp(r'[a-zA-Z]').hasMatch(text);

bool containsArabicLetters(String text) => RegExp(r'[؀-ۿ]').hasMatch(text);

class GrcFormFields extends StatefulWidget {
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
  State<GrcFormFields> createState() => _GrcFormFieldsState();
}

class _GrcFormFieldsState extends State<GrcFormFields> {
  @override
  void initState() {
    super.initState();
    for (final controller in _bilingualControllers) {
      controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _bilingualControllers) {
      controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  List<TextEditingController> get _bilingualControllers => [
        widget.nameEnController,
        widget.nameArController,
        widget.descEnController,
        widget.descArController,
      ];

  void _onTextChanged() => setState(() {});

  /// Computes error text for an English-language bilingual field: a required
  /// check first, then a wrong-script (Arabic letters present) check.
  String? _englishFieldErrorText({
    required bool submitted,
    required String text,
    required String requiredMessage,
    required String wrongScriptMessage,
  }) {
    if (submitted && text.trim().isEmpty) return requiredMessage;
    if (containsArabicLetters(text)) return wrongScriptMessage;
    return null;
  }

  /// Computes error text for an Arabic-language bilingual field: a required
  /// check first, then a wrong-script (English letters present) check.
  String? _arabicFieldErrorText({
    required bool submitted,
    required String text,
    required String requiredMessage,
    required String wrongScriptMessage,
  }) {
    if (submitted && text.trim().isEmpty) return requiredMessage;
    if (containsEnglishLetters(text)) return wrongScriptMessage;
    return null;
  }

  /// Computes error text for a non-text field (dropdown/date picker): only a
  /// required-field check, and only once the form has been submitted.
  String? _requiredFieldErrorText({
    required bool submitted,
    required bool isEmpty,
    required String requiredMessage,
  }) {
    if (!submitted) return null;
    return isEmpty ? requiredMessage : null;
  }

  Widget _buildNameEnField(bool submitted, bool readOnly) {
    final nameEnController = widget.nameEnController;
    return CustomTextField(
      label: 'GRC Module Name',
      hint: 'Text here',
      controller: nameEnController,
      autoCapitalize: true,
      errorText: _englishFieldErrorText(
        submitted: submitted,
        text: nameEnController.text,
        requiredMessage: "GRC Module Name is required",
        wrongScriptMessage: "GRC Module Name must be written in English",
      ),
      submitted: submitted,
      readOnly: readOnly,
      fillColor: AppColors.background,
      valueStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
      labelStyle:
          AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp),
      onChanged: (_) {},
    );
  }

  Widget _buildNameArField(bool submitted, bool readOnly) {
    final nameArController = widget.nameArController;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextField(
        label: 'عنوان اطار الحوكمه',
        hint: 'اكتب هنا',
        controller: nameArController,
        errorText: _arabicFieldErrorText(
          submitted: submitted,
          text: nameArController.text,
          requiredMessage: S.of(context).grcModuleNameIsRequired,
          wrongScriptMessage: S.of(context).grcModuleNameMustBeWrittenInArabic,
        ),
        submitted: submitted,
        readOnly: readOnly,
        fillColor: AppColors.background,
        valueStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText),
        hintStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
        labelStyle: AppTextStyles.font16BlackRegularCairo
            .copyWith(fontSize: 12.sp, height: 2.2),
        onChanged: (_) {},
      ),
    );
  }

  Widget _buildDepartmentField(
    BuildContext context,
    String? selectedDepartment,
    ValueChanged<String?> onDepartmentChanged,
    bool submitted,
    bool readOnly,
    String requiredError,
  ) {
    return CustomDropdown<String>(
      label: S.of(context).OwningDepartment,
      hint: S.of(context).chooseDepartment,
      items: Get.find<MainCoreDepartmentCubit>().departmentIds.map((id) {
        final depCtrl = Get.find<MainCoreDepartmentCubit>();
        final label = FormatHelper.capitalize(
          context.isArabic
              ? depCtrl.getArabicDepartmentNameFromDepartmentId(
                      departmentId: id) ??
                  ''
              : depCtrl.getEnglishDepartmentNameFromDepartmentId(
                      departmentId: id) ??
                  '',
        );
        return DropdownItem<String>(value: label, label: label);
      }).toList(),
      value: selectedDepartment,
      onChanged: onDepartmentChanged,
      enabled: !readOnly,
      fillColor: AppColors.background,
      errorText: _requiredFieldErrorText(
        submitted: submitted,
        isEmpty: selectedDepartment == null,
        requiredMessage: requiredError,
      ),
      labelStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
      borderRadius: BorderRadius.circular(4.r),
      required: false,
    );
  }

  Widget _buildActivationDateField(
    BuildContext context,
    DateTime? activationDate,
    ValueChanged<DateTime?> onDateChanged,
    bool submitted,
    bool readOnly,
    String requiredError,
  ) {
    // final today = DateTime.now();
    // final startOfToday = DateTime(today.year, today.month, today.day);
    // final isPastDate =
    //     activationDate != null && activationDate.isBefore(startOfToday);

    return CustomDropdownCalendar(
      borderRadius: BorderRadius.circular(4.r),
      label: S.of(context).activationDate,
      hint: S.of(context).selectActivationDate,
      value: activationDate,
      onChanged: onDateChanged,
      enabled: !readOnly,
      fillColor: AppColors.background,
      // firstDate: startOfToday,
      dateFormatter: (d) =>
          DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en').format(d),
      errorText: _requiredFieldErrorText(
        submitted: submitted,
        isEmpty: activationDate == null,
        requiredMessage: requiredError,
      ),
      labelStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
      required: false,
    );
  }

  Widget _buildDescEnField(bool submitted, bool readOnly) {
    final descEnController = widget.descEnController;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomTextField(
        label: 'Description',
        hint: 'Text here',
        autoCapitalize: true,
        controller: descEnController,
        errorText: _englishFieldErrorText(
          submitted: submitted,
          text: descEnController.text,
          requiredMessage: "Description is required",
          wrongScriptMessage: "Description must be written in English",
        ),
        submitted: submitted,
        readOnly: readOnly,
        maxLines: 3,
        minLines: 3,
        maxLength: 1000,
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
    );
  }

  Widget _buildDescArField(bool submitted, bool readOnly) {
    final descArController = widget.descArController;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextField(
        label: 'الوصف',
        hint: 'اكتب وصف',
        controller: descArController,
        errorText: _arabicFieldErrorText(
          submitted: submitted,
          text: descArController.text,
          requiredMessage: S.of(context).descriptionIsRequired,
          wrongScriptMessage: S.of(context).descriptionMustBeWrittenInArabic,
        ),
        submitted: submitted,
        readOnly: readOnly,
        maxLines: 3,
        minLines: 3,
        maxLength: 1000,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDepartment = widget.selectedDepartment;
    final activationDate = widget.activationDate;
    final onDepartmentChanged = widget.onDepartmentChanged;
    final onDateChanged = widget.onDateChanged;
    final submitted = widget.submitted;
    final readOnly = widget.readOnly;

    final requiredError = S.of(context).thisFieldIsRequired;

    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final nameEnField = _buildNameEnField(submitted, readOnly);
    final nameArField = _buildNameArField(submitted, readOnly);
    final departmentField = _buildDepartmentField(
      context,
      selectedDepartment,
      onDepartmentChanged,
      submitted,
      readOnly,
      requiredError,
    );
    final activationDateField = _buildActivationDateField(
      context,
      activationDate,
      onDateChanged,
      submitted,
      readOnly,
      requiredError,
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
        _buildDescEnField(submitted, readOnly),
        SizedBox(height: 15.h),

        // ── Description AR ────────────────────────────────────────────────────
        _buildDescArField(submitted, readOnly),
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
