/// Module: GRC Policy Management
/// Description: Card widget for a single policy control entry.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyControlModel, PolicyDocumentPreviewWidget
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Split Control Document into English/Arabic
///                   2026-07-14 - Converted to StatefulWidget; added Control
///                                Number field and English/Arabic
///                                language-mismatch validation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_control_item_widget.dart
/// Purpose: Contains PolicyControlItemWidget, a card widget that renders
///          all fields for a single policy control entry. Validates that EN
///          fields contain no Arabic letters and vice versa.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_completeness.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'policy_document_preview_widget.dart';

class PolicyControlItemWidget extends StatefulWidget {
  final PolicyControlModel control;
  final bool isArabicEnabled;
  final bool showRemoveButton;
  final VoidCallback? onRemove;
  final VoidCallback onUploadDocumentEn;
  final VoidCallback onUploadDocumentAr;
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;
  final ValueChanged<String?> onFrequencyChanged;
  final DateTime? policyStartDate;
  final DateTime? policyEndDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final bool controlsSubmitted;

  /// Fires on every keystroke in any of this control's text fields — the
  /// parent page's own completeness/error checks (e.g. the Preview button's
  /// enabled state) read straight from these same TextEditingControllers,
  /// so it needs to rebuild on every change, not just on the
  /// dropdown/date/document callbacks below.
  final VoidCallback? onChanged;

  const PolicyControlItemWidget({
    super.key,
    required this.control,
    required this.isArabicEnabled,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    required this.onFrequencyChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.controlsSubmitted,
    this.policyStartDate,
    this.policyEndDate,
    this.showRemoveButton = false,
    this.onRemove,
    this.onChanged,
  });

  @override
  State<PolicyControlItemWidget> createState() =>
      _PolicyControlItemWidgetState();
}

class _PolicyControlItemWidgetState extends State<PolicyControlItemWidget> {
  List<TextEditingController> get _bilingualControllers => [
        widget.control.nameController,
        widget.control.nameArController,
        widget.control.numberController,
        widget.control.numberArController,
        widget.control.descriptionController,
        widget.control.descriptionArController,
      ];

  @override
  void initState() {
    super.initState();
    for (final c in _bilingualControllers) {
      c.addListener(_onTextChanged);
    }
    widget.control.weightController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    for (final c in _bilingualControllers) {
      c.removeListener(_onTextChanged);
    }
    widget.control.weightController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call();
  }

  TextStyle get _labelStyle =>
      AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp);
  TextStyle get _valueStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText);
  TextStyle get _hintStyle => StyleText.fontSize14Weight500
      .copyWith(color: AppColors.secondaryText.withOpacity(.5));

  /// "Required" error styling stays suppressed on this card in every state
  /// — the parent page's Preview button being greyed/disabled while
  /// anything here is incomplete (see create_new_policy.dart's
  /// _canPreview) is the only feedback for that. Language-mismatch errors
  /// (Arabic typed into an English field or vice versa) still show inline,
  /// live, as the user types. [isMandatory] is still accepted so call
  /// sites don't need reworking, but no longer feeds into anything
  /// rendered.
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
  }) {
    final languageError = rtl
        ? (containsEnglishLetters(controller.text) ? arabicOnlyError : null)
        : (containsArabicLetters(controller.text) ? englishOnlyError : null);

    final field = CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      required: true,
      onlyDigits: onlyDigits,
      errorText: languageError,
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
      svgColor: AppColors.textButton,
    );
  }

  /// function name: [_documentColumn]
  ///
  /// purpose: one document upload/preview column — shared by the ENG and AR
  ///          Control Document sections so their layout stays identical
  ///          whether they're shown side by side or (Arabic disabled) alone.
  Widget _documentColumn({
    required String label,
    required PolicyDocumentInfo? document,
    required VoidCallback onRemove,
    required VoidCallback onUpload,
  }) {
    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        document != null
            ? PolicyDocumentPreviewWidget(
                document: document, onRemove: onRemove)
            : SizedBox(
                width: double.infinity,
                child:
                    _documentButton(onTap: onUpload, title: 'Control Document'),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.control;
    final isArabicEnabled = widget.isArabicEnabled;
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

    final frequencyField = CustomDropdown<String>(
      label: 'Frequency',
      hint: 'Choose Here',
      items: const [
        'Weekly',
        'Bi weekly',
        'Monthly',
        'Quarterly',
        'Semi Annual',
        'Annually',
      ].map((d) => DropdownItem<String>(value: d, label: d)).toList(),
      value: control.frequency,
      onChanged: widget.onFrequencyChanged,
      fillColor: AppColors.background,
      labelStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
      itemStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      required: false,
    );

    final weightField = _textField(
      label: 'Control Weight',
      hint: 'Text Here',
      controller: control.weightController,
      isMandatory: true,
      onlyDigits: true,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showRemoveButton)
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: widget.onRemove,
                child: Icon(Icons.close,
                    color: AppColors.secondaryText, size: 18.sp),
              ),
            ),
          twoColumns(
            _textField(
              label: 'Control Name',
              hint: 'Text here',
              controller: control.nameController,
              isMandatory: true,
              englishOnlyError: 'Control Name must be written in English',
            ),
            isArabicEnabled
                ? _textField(
                    label: 'اسم ضابط',
                    hint: 'اكتب هنا',
                    controller: control.nameArController,
                    rtl: true,
                    isMandatory: controlArabicTouched(control),
                    arabicOnlyError: 'يجب كتابة اسم ضابط باللغة العربية',
                  )
                : _textField(
                    label: 'Control Number'.tr,
                    hint: 'Text here',
                    controller: control.numberController,
                    isMandatory: true,
                    onlyDigits: true,
                    englishOnlyError:
                        'Control Number must be written in English'.tr,
                  ),
          ),
          SizedBox(height: 15.h),
          if (isArabicEnabled) ...[
            twoColumns(
              _textField(
                label: 'Control Number'.tr,
                hint: 'Text here',
                controller: control.numberController,
                isMandatory: true,
                onlyDigits: true,
                englishOnlyError:
                    'Control Number must be written in English'.tr,
              ),
              _textField(
                label: 'رقم ضابط',
                hint: 'اكتب هنا',
                controller: control.numberArController,
                rtl: true,
                isMandatory: controlArabicTouched(control),
                arabicOnlyError: 'يجب كتابة رقم ضابط باللغة العربية',
              ),
            ),
            SizedBox(height: 15.h),
          ],
          _textField(
            label: 'Control Description',
            hint: 'Text here',
            controller: control.descriptionController,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
            isMandatory: true,
            englishOnlyError: 'Control Description must be written in English',
          ),
          SizedBox(height: 15.h),
          if (isArabicEnabled) ...[
            _textField(
              label: 'وصف ضابط',
              hint: 'اكتب وصف',
              controller: control.descriptionArController,
              rtl: true,
              maxLines: 3,
              minLines: 3,
              maxLength: 500,
              showCharCount: true,
              isMandatory: controlArabicTouched(control),
              arabicOnlyError: 'يجب كتابة وصف ضابط باللغة العربية',
            ),
            SizedBox(height: 15.h),
          ],
          isTablet
              ? Row(children: [
                  Expanded(child: frequencyField),
                  SizedBox(width: 10.w),
                  Expanded(child: weightField),
                ])
              : Column(children: [
                  frequencyField,
                  SizedBox(height: 15.h),
                  weightField,
                ]),
          SizedBox(height: 15.h),
          // Two Expanded columns split the row 50/50 when Arabic is on;
          // with only the ENG column left, an Expanded there would stretch
          // it across the whole row instead of keeping that same
          // half-width look.
          isArabicEnabled
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10.w,
                  children: [
                    Expanded(
                      child: _documentColumn(
                        label: 'Control Document ENG',
                        document: control.documentEn,
                        onRemove: widget.onRemoveDocumentEn,
                        onUpload: widget.onUploadDocumentEn,
                      ),
                    ),
                    Expanded(
                      child: _documentColumn(
                        label: 'Control Document AR',
                        document: control.documentAr,
                        onRemove: widget.onRemoveDocumentAr,
                        onUpload: widget.onUploadDocumentAr,
                      ),
                    ),
                  ],
                )
              : FractionallySizedBox(
                  widthFactor: 0.5,
                  alignment: Alignment.centerLeft,
                  child: _documentColumn(
                    label: 'Control Document ENG',
                    document: control.documentEn,
                    onRemove: widget.onRemoveDocumentEn,
                    onUpload: widget.onUploadDocumentEn,
                  ),
                ),
        ],
      ),
    );
  }
}
