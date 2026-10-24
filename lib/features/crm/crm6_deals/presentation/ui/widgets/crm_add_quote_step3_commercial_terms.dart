// ****************** FILE INFO ******************
// File Name: crm_add_quote_step3_commercial_terms.dart
// Purpose: Step 3 Commercial Terms form for Add Quote wizard using ProductWarrantyCard for uploaded attachments
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/cards/custom_uploaded_document_card.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class QuoteTermOption {
  final String id;
  final String label;
  const QuoteTermOption({required this.id, required this.label});
}

class CrmAddQuoteStep3CommercialTerms extends StatelessWidget {
  final String? selectedPaymentTerm;
  final String? selectedDeliveryTerm;
  final List<QuoteTermOption> paymentTermOptions;
  final List<QuoteTermOption> deliveryTermOptions;
  final ValueChanged<String?> onPaymentTermChanged;
  final ValueChanged<String?> onDeliveryTermChanged;
  final TextEditingController noteEnController;
  final TextEditingController noteArController;
  final List<String> uploadedFiles;
  final VoidCallback onUploadFile;
  final VoidCallback onAddFiles;
  final ValueChanged<String>? onRemoveFile;
  final bool showValidationErrors;
  final ValueChanged<String>? onChanged;

  const CrmAddQuoteStep3CommercialTerms({
    super.key,
    required this.selectedPaymentTerm,
    required this.selectedDeliveryTerm,
    this.paymentTermOptions = const <QuoteTermOption>[],
    this.deliveryTermOptions = const <QuoteTermOption>[],
    required this.onPaymentTermChanged,
    required this.onDeliveryTermChanged,
    required this.noteEnController,
    required this.noteArController,
    this.uploadedFiles = const <String>[],
    required this.onUploadFile,
    required this.onAddFiles,
    this.onRemoveFile,
    this.showValidationErrors = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPaymentTermError = showValidationErrors &&
        (selectedPaymentTerm == null || selectedPaymentTerm!.isEmpty);
    final bool hasDeliveryTermError = showValidationErrors &&
        (selectedDeliveryTerm == null || selectedDeliveryTerm!.isEmpty);

    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Terms',
        arabicName: 'الشروط',
      ),
      showHideToggle: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── 1. Payment Terms & Delivery Terms Dropdowns ─────────────────────
          buildResponsiveFields(
            context: context,
            left: _buildPaymentTermsField(hasPaymentTermError),
            right: _buildDeliveryTermsField(hasDeliveryTermError),
          ),

          SizedBox(height: 16.sp),

          // ── 2. Note (English) ───────────────────────────────────────────────
          _buildNoteEnField(),

          SizedBox(height: 16.sp),

          // ── 3. Note (Arabic) ───────────────────────────────────────────────
          _buildNoteArField(),

          SizedBox(height: 20.sp),

          // ── 4. File Upload Section ──────────────────────────────────────────
          _buildFileUploadSection(context),
        ],
      ),
    );
  }

  Widget _buildPaymentTermsField(bool hasError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          FormatHelper.localizedString(
            englishName: 'Payment Terms',
            arabicName: 'شروط الدفع',
          ),
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 6.sp),
        CustomDropdown<String>(
          hint: FormatHelper.localizedString(
            englishName: 'Choose',
            arabicName: 'اختر',
          ),
          value: selectedPaymentTerm,
          items: paymentTermOptions
              .map((QuoteTermOption opt) =>
                  DropdownItem<String>(value: opt.id, label: opt.label))
              .toList(),
          onChanged: onPaymentTermChanged,
          fillColor: AppColors.background,
          errorText: hasError
              ? FormatHelper.localizedString(
                  englishName: 'Field Required',
                  arabicName: 'هذا الحقل مطلوب',
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildDeliveryTermsField(bool hasError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          FormatHelper.localizedString(
            englishName: 'Delivery Terms',
            arabicName: 'شروط التسليم',
          ),
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 6.sp),
        CustomDropdown<String>(
          hint: FormatHelper.localizedString(
            englishName: 'Choose',
            arabicName: 'اختر',
          ),
          value: selectedDeliveryTerm,
          items: deliveryTermOptions
              .map((QuoteTermOption opt) =>
                  DropdownItem<String>(value: opt.id, label: opt.label))
              .toList(),
          onChanged: onDeliveryTermChanged,
          fillColor: AppColors.background,
          errorText: hasError
              ? FormatHelper.localizedString(
                  englishName: 'Field Required',
                  arabicName: 'هذا الحقل مطلوب',
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildNoteEnField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Note',
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 6.sp),
        CustomTextField(
          controller: noteEnController,
          hint: 'Description',
          maxLines: 3,
          minLines: 3,
          fillColor: AppColors.background,
          onChanged: (String val) => onChanged?.call(val),
        ),
        SizedBox(height: 4.sp),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${noteEnController.text.length}/500',
            style: StyleText.fontSize12Weight400.copyWith(
              color: const Color(0xFF9CA3AF),
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteArField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ملاحظة',
            style: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ),
        SizedBox(height: 6.sp),
        Directionality(
          textDirection: TextDirection.rtl,
          child: CustomTextField(
            controller: noteArController,
            hint: 'اكتب هنا',
            textAlign: TextAlign.right,
            maxLines: 3,
            minLines: 3,
            fillColor: AppColors.background,
            onChanged: (String val) => onChanged?.call(val),
          ),
        ),
        SizedBox(height: 4.sp),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${_toArabicDigits(noteArController.text.length)}/500',
            style: StyleText.fontSize12Weight400.copyWith(
              color: const Color(0xFF9CA3AF),
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          FormatHelper.localizedString(
            englishName: 'File',
            arabicName: 'الملف',
          ),
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 10.sp),

        // Yellow Upload Bar Button
        SizedBox(
          width: double.infinity,
          child: customButtonWithSvg(
            title: FormatHelper.localizedString(
              englishName: 'Upload',
              arabicName: 'رفع ملف',
            ),
            image: AppAssets.download,
            widthImage: 16.sp,
            heightImage: 16.sp,
            color: AppColors.primary,
            colorBorder: Colors.transparent,
            textStyle: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.bold,
            ),
            function: onUploadFile,
          ),
        ),

        SizedBox(height: 12.sp),

        // Dark + Add Files button
        customButton(
          title: FormatHelper.localizedString(
            englishName: '+ Add Files',
            arabicName: '+ إضافة ملفات',
          ),
          color: AppColors.blackButton,
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppTheme.readableOn(AppColors.blackButton),
            fontWeight: FontWeight.w600,
          ),
          function: onAddFiles,
        ),

        // Uploaded Document Cards using ProductWarrantyCard (22-custom_uploaded_document_card.dart)
        if (uploadedFiles.isNotEmpty) ...<Widget>[
          SizedBox(height: 16.sp),
          Wrap(
            spacing: 12.sp,
            runSpacing: 12.sp,
            children: uploadedFiles.map((String file) {
              final DateTime now = DateTime.now();
              final String today =
                  '${now.day} ${_monthName(now.month)} ${now.year}';
              return ProductWarrantyCard(
                title: FormatHelper.localizedString(
                  englishName: 'Attachment',
                  arabicName: 'مرفق',
                ),
                fileName: file,
                fileSize: '2.5 MB',
                date: today,
                width: 280.sp,
                onRemove:
                    onRemoveFile != null ? () => onRemoveFile!(file) : null,
                onTapFile: () {},
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  static String _monthName(int month) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  static String _toArabicDigits(int number) {
    const Map<String, String> arabicDigits = <String, String>{
      '0': '0',
      '1': '1',
      '2': '2',
      '3': '3',
      '4': '4',
      '5': '5',
      '6': '6',
      '7': '7',
      '8': '8',
      '9': '9',
    };
    return number
        .toString()
        .split('')
        .map((String e) => arabicDigits[e] ?? e)
        .join();
  }
}
