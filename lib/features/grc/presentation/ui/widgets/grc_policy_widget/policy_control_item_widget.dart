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
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  const PolicyControlItemWidget({
    super.key,
    required this.control,
    required this.isArabicEnabled,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    required this.onFrequencyChanged,
    this.showRemoveButton = false,
    this.onRemove,
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
  }

  @override
  void dispose() {
    for (final c in _bilingualControllers) {
      c.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

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
      space: 10.w,
      radius: 8.r,
      widthImage: 16.w,
      heightImage: 16.h,
      function: onTap,
      title: title,
      textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
      image: 'assets/hrAsset/Upload.svg',
      color: AppColors.primary,
      width: 220.w,
      height: 36.h,
      svgColor: AppColors.textButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.control;
    final isArabicEnabled = widget.isArabicEnabled;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

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
      labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
      itemStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      triggerPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      borderRadius: BorderRadius.circular(4.r),
      required: false,
    );

    final weightField = _textField(
      label: 'Control Weight',
      hint: 'Text Here',
      controller: control.weightController,
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
          if (isArabicEnabled && isTablet)
            Row(children: [
              Expanded(
                child: _textField(
                  label: 'Control Name',
                  hint: 'Text here',
                  controller: control.nameController,
                  englishOnlyError: 'Control Name must be written in English',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _textField(
                  label: 'اسم ضابط',
                  hint: 'اكتب هنا',
                  controller: control.nameArController,
                  rtl: true,
                  arabicOnlyError: 'يجب كتابة اسم ضابط باللغة العربية',
                ),
              ),
            ])
          else ...[
            _textField(
              label: 'Control Name',
              hint: 'Text here',
              controller: control.nameController,
              englishOnlyError: 'Control Name must be written in English',
            ),
            if (isArabicEnabled) ...[
              SizedBox(height: 15.h),
              _textField(
                label: 'اسم ضابط',
                hint: 'اكتب هنا',
                controller: control.nameArController,
                rtl: true,
                arabicOnlyError: 'يجب كتابة اسم ضابط باللغة العربية',
              ),
            ],
          ],
          SizedBox(height: 15.h),
          if (isArabicEnabled && isTablet)
            Row(children: [
              Expanded(
                child: _textField(
                  label: 'Control Number',
                  hint: 'Text here',
                  controller: control.numberController,
                  englishOnlyError: 'Control Number must be written in English',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _textField(
                  label: 'رقم ضابط',
                  hint: 'اكتب هنا',
                  controller: control.numberArController,
                  rtl: true,
                  arabicOnlyError: 'يجب كتابة رقم ضابط باللغة العربية',
                ),
              ),
            ])
          else ...[
            _textField(
              label: 'Control Number',
              hint: 'Text here',
              controller: control.numberController,
              englishOnlyError: 'Control Number must be written in English',
            ),
            if (isArabicEnabled) ...[
              SizedBox(height: 15.h),
              _textField(
                label: 'رقم ضابط',
                hint: 'اكتب هنا',
                controller: control.numberArController,
                rtl: true,
                arabicOnlyError: 'يجب كتابة رقم ضابط باللغة العربية',
              ),
            ],
          ],
          SizedBox(height: 15.h),
          _textField(
            label: 'Control Description',
            hint: 'Text here',
            controller: control.descriptionController,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
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
              arabicOnlyError: 'يجب كتابة وصف ضابط باللغة العربية',
            ),
            SizedBox(height: 15.h),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Control Document',
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.text)),
              const Spacer(),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    control.documentEn != null
                        ? PolicyDocumentPreviewWidget(
                            document: control.documentEn!,
                            onRemove: widget.onRemoveDocumentEn,
                          )
                        : _documentButton(
                            onTap: widget.onUploadDocumentEn,
                            title: 'Upload Document (English)',
                          ),
                    if (isArabicEnabled) ...[
                      SizedBox(height: 10.h),
                      control.documentAr != null
                          ? PolicyDocumentPreviewWidget(
                              document: control.documentAr!,
                              onRemove: widget.onRemoveDocumentAr,
                            )
                          : _documentButton(
                              onTap: widget.onUploadDocumentAr,
                              title: 'رفع المستند (عربي)',
                            ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
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
        ],
      ),
    );
  }
}
