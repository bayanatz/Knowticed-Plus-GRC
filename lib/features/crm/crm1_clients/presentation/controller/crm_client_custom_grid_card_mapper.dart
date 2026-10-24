// ****************** FILE INFO ******************
// File Name: crm_client_custom_grid_card_mapper.dart
// Purpose: Resolves template-selected fields into localized client card data.
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:intl/intl.dart';

class CrmClientCustomGridCardItem {
  final String label;
  final String value;
  final String iconAsset;

  const CrmClientCustomGridCardItem({
    required this.label,
    required this.value,
    required this.iconAsset,
  });
}

abstract final class CrmClientCustomGridCardMapper {
  static List<CrmTemplateFieldModel> resolveFields({
    required CrmTemplateModel? template,
    required List<CrmTemplateFieldModel> fields,
  }) {
    if (template == null || template.customGridFieldIds.isEmpty) {
      return const <CrmTemplateFieldModel>[];
    }

    final Set<String> selectedIds = template.customGridFieldIds.toSet();
    final List<CrmTemplateFieldModel> selectedFields = fields
        .where((CrmTemplateFieldModel field) =>
            field.templateId == template.id &&
            !field.isDeleted &&
            field.status.toLowerCase() != 'deleted' &&
            selectedIds.contains(field.id))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return selectedFields.take(4).toList(growable: false);
  }

  static List<CrmClientCustomGridCardItem> buildItems({
    required CrmClientRecordModel record,
    required List<CrmTemplateFieldModel> fields,
    required String languageCode,
  }) {
    return fields
        .map(
          (CrmTemplateFieldModel field) => CrmClientCustomGridCardItem(
            label: _labelFor(field, languageCode),
            value: _formatValue(
              record.valueFor(field.id, field.systemKey),
              languageCode,
            ),
            iconAsset: _iconFor(field),
          ),
        )
        .toList(growable: false);
  }

  static String _labelFor(CrmTemplateFieldModel field, String languageCode) {
    final bool isArabic = languageCode.toLowerCase() == 'ar';
    final String preferred = isArabic ? field.nameAr : field.nameEn;
    final String fallback = isArabic ? field.nameEn : field.nameAr;
    return preferred.trim().isEmpty ? fallback.trim() : preferred.trim();
  }

  static String _formatValue(dynamic value, String languageCode) {
    if (value == null) {
      return '—';
    }
    if (value is Timestamp) {
      return _formatDate(value.toDate());
    }
    if (value is DateTime) {
      return _formatDate(value);
    }
    if (value is List) {
      final List<String> entries = value
          .map((dynamic item) => _formatValue(item, languageCode))
          .where((String item) => item != '—')
          .toList();
      return entries.isEmpty ? '—' : entries.join(', ');
    }
    if (value is Map) {
      final dynamic localized = value[languageCode] ??
          value[languageCode.toUpperCase()] ??
          value['en'] ??
          value['ar'];
      if (localized != null) {
        return _formatValue(localized, languageCode);
      }
      final List<String> entries = value.values
          .map((dynamic item) => _formatValue(item, languageCode))
          .where((String item) => item != '—')
          .toList();
      return entries.isEmpty ? '—' : entries.join(', ');
    }
    final String text = value.toString().trim();
    return text.isEmpty ? '—' : text;
  }

  static String _formatDate(DateTime value) =>
      DateFormat('dd/MM/yyyy').format(value);

  static String _iconFor(CrmTemplateFieldModel field) {
    final String key = '${field.systemKey} ${field.fieldTypeId}'.toLowerCase();
    if (key.contains('email')) {
      return AppAssets.email;
    }
    if (key.contains('phone') || key.contains('mobile')) {
      return AppAssets.phone;
    }
    if (key.contains('date') || key.contains('time')) {
      return AppAssets.calendar;
    }
    if (key.contains('country') ||
        key.contains('city') ||
        key.contains('province') ||
        key.contains('street') ||
        key.contains('address')) {
      return AppAssets.addressIcon;
    }
    if (key.contains('image') || key.contains('photo')) {
      return AppAssets.imageWatermark;
    }
    return AppAssets.text;
  }
}
