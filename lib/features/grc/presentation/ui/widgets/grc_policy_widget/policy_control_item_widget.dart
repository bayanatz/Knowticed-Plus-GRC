/// Module: GRC Policy Management
/// Description: Card widget for a single policy control entry.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyControlModel, PolicyDocumentPreviewWidget
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Split Control Document into English/Arabic
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_control_item_widget.dart
/// Purpose: Contains PolicyControlItemWidget, a card widget that renders
///          all fields for a single policy control entry.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'policy_document_preview_widget.dart';

/// class name: [PolicyControlItemWidget]
///
/// purpose: stateless card that renders all input fields for one
///          PolicyControlModel. The parent list widget owns the state and
///          passes callbacks for document upload, removal, and frequency change.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyControlItemWidget extends StatelessWidget {
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
      onChanged: onFrequencyChanged,
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
          if (showRemoveButton)
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onRemove,
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
                    controller: control.nameController),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _textField(
                    label: 'اسم ضابط',
                    hint: 'اكتب هنا',
                    controller: control.nameArController,
                    rtl: true),
              ),
            ])
          else ...[
            _textField(
                label: 'Control Name',
                hint: 'Text here',
                controller: control.nameController),
            if (isArabicEnabled) ...[
              SizedBox(height: 15.h),
              _textField(
                  label: 'اسم ضابط',
                  hint: 'اكتب هنا',
                  controller: control.nameArController,
                  rtl: true),
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
                            onRemove: onRemoveDocumentEn,
                          )
                        : _documentButton(
                            onTap: onUploadDocumentEn,
                            title: 'Upload Document (English)',
                          ),
                    if (isArabicEnabled) ...[
                      SizedBox(height: 10.h),
                      control.documentAr != null
                          ? PolicyDocumentPreviewWidget(
                              document: control.documentAr!,
                              onRemove: onRemoveDocumentAr,
                            )
                          : _documentButton(
                              onTap: onUploadDocumentAr,
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
