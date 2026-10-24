// ****************** FILE INFO ******************
// File Name: crm_template_field_type_row.dart
// Purpose: CRM template field type selector row
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateFieldTypeRow extends StatelessWidget {
  const CrmTemplateFieldTypeRow({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    this.readOnly = false,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final List<String> items = fieldTypes.isEmpty
        ? const [
            'Image',
            'Text Field',
            'Email',
            'Phone',
            'Address',
            'Drop Down',
            'Radio',
            'Check Box',
            'Description',
            'Attachment',
            'Link',
            'Attached Digital Signature',
            'Date Selector',
            'Time Selector',
            'Switch',
            'Website',
            'Purchasing Value',
            'Business Initiation Date',
            'Company Size',
            'Sector',
            'Industry',
            'Preferred Language',
            'Tag',
          ]
        : fieldTypes
            .map((type) => FormatHelper.localizedString(
                  englishName: type.nameEn,
                  arabicName: type.nameAr,
                ))
            .toList();
    return buildResponsiveFields(
      context: context,
      left: _DropdownBox(
        title: S.current.crmFieldType,
        value: _fieldTypeLabel(model.field.fieldTypeId),
        items: items,
        readOnly: readOnly,
        onChanged: (String value) {
          final CrmFieldTypeModel? selected = _selectedFieldType(value);
          final String fieldTypeId = selected?.id ?? _fieldTypeId(value);
          final String fieldKind = selected?.inputType ?? _fieldKind(value);
          model.field = model.field.copyWith(fieldTypeId: fieldTypeId);
          model.setConfig(CrmFirestoreKeys.FIELD_KIND_KEY, fieldKind);
          if (fieldKind == 'address') {
            model.setConfig(
              CrmFirestoreKeys.ADDRESS_COMPONENT_KEY,
              model.stringConfig(
                CrmFirestoreKeys.ADDRESS_COMPONENT_KEY,
                fallback: 'Country',
              ),
            );
            model.setConfig(
              CrmFirestoreKeys.ENTRY_TYPE_KEY,
              model.stringConfig(
                CrmFirestoreKeys.ENTRY_TYPE_KEY,
                fallback: 'Dropdown',
              ),
            );
            model.setConfig(
                CrmFirestoreKeys.ALLOW_SPECIAL_CHARACTERS_KEY, true);
          }
          if (fieldKind == 'image') {
            model.setConfig(
              CrmFirestoreKeys.IMAGE_TYPES_KEY,
              model.selectedImageTypes(),
            );
            model.setConfig(CrmFirestoreKeys.IMAGE_SIZE_UNIT_KEY, 'MB');
          }
          if (fieldKind == 'phone') {
            model.setConfig(
              CrmFirestoreKeys.COUNTRY_CODE_KEY,
              model.stringConfig(
                CrmFirestoreKeys.COUNTRY_CODE_KEY,
                fallback: 'Countries',
              ),
            );
          }
          if (fieldKind == 'link') {
            model.setConfig(
              CrmFirestoreKeys.LINK_TYPES_KEY,
              model.selectedLinkTypes(),
            );
          }
          if (fieldKind == 'attachment' || fieldKind == 'file') {
            model.setConfig(
              CrmFirestoreKeys.FILE_TYPES_KEY,
              model.selectedFileTypes(),
            );
          }
          if (fieldKind == 'signature') {
            model.setConfig(CrmFirestoreKeys.SAVE_FORMAT_KEY, 'File');
            model.setConfig(
              CrmFirestoreKeys.SIGNATURE_TYPES_KEY,
              CrmTemplateFieldEditModel.defaultSignatureFileTypes,
            );
          }
          if (fieldTypeId == 'website') {
            model.setConfig(CrmFirestoreKeys.AUTO_ADD_HTTPS_KEY, true);
            model.setConfig(CrmFirestoreKeys.TRIM_SPACES_KEY, true);
          }
          if (fieldTypeId == 'purchasing_value') {
            model.setConfig(
              CrmFirestoreKeys.VALUE_VALIDATION_TYPES_KEY,
              model.selectedPurchasingValidationTypes(),
            );
          }
          _applySavedChoicePreset(context, fieldTypeId);
          onChanged();
        },
      ),
      right: const SizedBox.shrink(),
    );
  }

  String _fieldTypeLabel(String value) {
    if (value.isEmpty) return '';
    for (final CrmFieldTypeModel type in fieldTypes) {
      if (type.id == value || type.nameEn == value || type.nameAr == value) {
        return FormatHelper.localizedString(
          englishName: type.nameEn,
          arabicName: type.nameAr,
        );
      }
    }
    switch (value) {
      case 'image':
        return FormatHelper.localizedString(
          englishName: 'Image',
          arabicName: 'صورة',
        );
      case 'text':
        return FormatHelper.localizedString(
          englishName: 'Text Field',
          arabicName: 'حقل نصي',
        );
      case 'dropdown':
        return FormatHelper.localizedString(
          englishName: 'Drop Down',
          arabicName: 'قائمة منسدلة',
        );
      case 'radio':
        return FormatHelper.localizedString(
          englishName: 'Radio',
          arabicName: 'زر اختيار فردي',
        );
      case 'checkbox':
        return FormatHelper.localizedString(
          englishName: 'Check Box',
          arabicName: 'صندوق اختيار',
        );
      case 'email':
        return FormatHelper.localizedString(
          englishName: 'Email',
          arabicName: 'بريد إلكتروني',
        );
      case 'phone':
        return FormatHelper.localizedString(
          englishName: 'Phone',
          arabicName: 'رقم الهاتف',
        );
      case 'address':
        return FormatHelper.localizedString(
          englishName: 'Address',
          arabicName: 'العنوان',
        );
      case 'description':
        return FormatHelper.localizedString(
          englishName: 'Description',
          arabicName: 'الوصف',
        );
      case 'attachment':
      case 'file':
        return FormatHelper.localizedString(
          englishName: 'Attachment',
          arabicName: 'مرفق',
        );
      case 'link':
        return FormatHelper.localizedString(
          englishName: 'Link',
          arabicName: 'رابط',
        );
      case 'signature':
      case 'digital_signature':
        return FormatHelper.localizedString(
          englishName: 'Attached Digital Signature',
          arabicName: 'توقيع رقمي مرفق',
        );
      case 'date':
        return FormatHelper.localizedString(
          englishName: 'Date Selector',
          arabicName: 'محدد التاريخ',
        );
      case 'time':
        return FormatHelper.localizedString(
          englishName: 'Time Selector',
          arabicName: 'محدد الوقت',
        );
      case 'switch':
        return FormatHelper.localizedString(
          englishName: 'Switch',
          arabicName: 'مفتاح تحويل',
        );
      case 'website':
        return FormatHelper.localizedString(
          englishName: 'Website',
          arabicName: 'موقع إلكتروني',
        );
      case 'purchasing_value':
        return FormatHelper.localizedString(
          englishName: 'Purchasing Value',
          arabicName: 'القيمة الشرائية',
        );
      case 'business_initiation_date':
        return FormatHelper.localizedString(
          englishName: 'Business Initiation Date',
          arabicName: 'تاريخ بدء النشاط',
        );
      case 'company_size':
        return FormatHelper.localizedString(
          englishName: 'Company Size',
          arabicName: 'حجم الشركة',
        );
      case 'sector':
        return FormatHelper.localizedString(
          englishName: 'Sector',
          arabicName: 'القطاع',
        );
      case 'industry':
        return FormatHelper.localizedString(
          englishName: 'Industry',
          arabicName: 'الصناعة',
        );
      case 'preferred_language':
        return FormatHelper.localizedString(
          englishName: 'Preferred Language',
          arabicName: 'اللغة المفضلة',
        );
      case 'tag':
        return FormatHelper.localizedString(
          englishName: 'Tag',
          arabicName: 'وسم',
        );
      default:
        return FormatHelper.localizedString(
          englishName: 'Text Field',
          arabicName: 'حقل نصي',
        );
    }
  }

  String _fieldTypeId(String value) {
    switch (value) {
      case 'Image':
        return 'image';
      case 'Text Field':
      case 'Text':
        return 'text';
      case 'Drop Down':
      case 'Dropdown':
        return 'dropdown';
      case 'Radio':
        return 'radio';
      case 'Check Box':
        return 'checkbox';
      case 'Email':
        return 'email';
      case 'Phone':
        return 'phone';
      case 'Address':
        return 'address';
      case 'Description':
        return 'description';
      case 'Attachment':
      case 'File':
        return 'attachment';
      case 'Link':
        return 'link';
      case 'Attached Digital Signature':
      case 'Signature':
        return 'signature';
      case 'Date Selector':
      case 'Date':
        return 'date';
      case 'Time Selector':
      case 'Time':
        return 'time';
      case 'Switch':
        return 'switch';
      case 'Website':
        return 'website';
      case 'Purchasing Value':
        return 'purchasing_value';
      case 'Business Initiation Date':
        return 'business_initiation_date';
      case 'Company Size':
        return 'company_size';
      case 'Sector':
        return 'sector';
      case 'Industry':
        return 'industry';
      case 'Preferred Language':
        return 'preferred_language';
      case 'Tag':
        return 'tag';
      default:
        return 'text';
    }
  }

  String _fieldKind(String value) {
    switch (value) {
      case 'Website':
        return 'link';
      case 'Purchasing Value':
        return 'text';
      case 'Business Initiation Date':
        return 'date';
      case 'Company Size':
      case 'Sector':
      case 'Industry':
      case 'Preferred Language':
        return 'dropdown';
      default:
        return _fieldTypeId(value);
    }
  }

  CrmFieldTypeModel? _selectedFieldType(String value) {
    for (final CrmFieldTypeModel type in fieldTypes) {
      final String localized = FormatHelper.localizedString(
        englishName: type.nameEn,
        arabicName: type.nameAr,
      );
      if (type.nameEn == value ||
          type.nameAr == value ||
          type.id == value ||
          localized == value) {
        return type;
      }
    }
    return null;
  }

  void _applySavedChoicePreset(BuildContext context, String fieldTypeId) {
    if (!_usesTemplateChoicePreset(fieldTypeId)) return;
    final CrmTemplateBuilderCubit cubit =
        context.read<CrmTemplateBuilderCubit>();
    final Iterable<CrmTemplateFieldModel> matches = cubit.state.fields.where(
      (CrmTemplateFieldModel field) =>
          field.templateId == model.field.templateId &&
          field.fieldTypeId == fieldTypeId &&
          field.id != model.field.id &&
          _hasSavedChoices(field),
    );
    if (matches.isEmpty) return;
    model.applyChoicePresetFrom(matches.last);
  }

  bool _usesTemplateChoicePreset(String fieldTypeId) {
    return const {
      'company_size',
      'sector',
      'industry',
      'tag',
      'preferred_language',
    }.contains(fieldTypeId);
  }

  bool _hasSavedChoices(CrmTemplateFieldModel field) {
    final dynamic options =
        field.configuration[CrmFirestoreKeys.DEFAULT_OPTIONS_KEY];
    return (options is List && options.isNotEmpty) || field.options.isNotEmpty;
  }
}

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.readOnly,
  });

  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.sp),
          CustomTextField(
            controller: TextEditingController(text: value),
            readOnly: true,
          ),
        ],
      );
    }

    final List<String> filteredItems =
        items.where((String item) => item.trim().isNotEmpty).toList();
    final List<String> values = (value.isEmpty || filteredItems.contains(value))
        ? filteredItems
        : <String>[value, ...filteredItems];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.sp),
        CustomDropdown<String>(
          value: value.isEmpty ? null : value,
          hint: S.current.crmChoose,
          enabled: !readOnly,
          items: values
              .map((item) => DropdownItem<String>(value: item, label: item))
              .toList(),
          onChanged: (String? selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ],
    );
  }
}
