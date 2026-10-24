// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_stage.dart
// Purpose: Immutable domain entity for a client conversion stage and checklist
// Author: Mohand Adel
// Created At: 07/10/2026

class CrmConvertChecklistItem {
  final String nameEn;
  final String nameAr;

  const CrmConvertChecklistItem({required this.nameEn, required this.nameAr});
}

class CrmConvertStage {
  final String id;
  final String nameEn;
  final String nameAr;
  final String status;
  final int order;
  final bool isDeleted;
  final List<CrmConvertChecklistItem> checklistItems;
  final DateTime updatedAt;
  final String updatedBy;

  const CrmConvertStage({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.updatedAt,
    this.status = 'active',
    this.order = 0,
    this.isDeleted = false,
    this.checklistItems = const <CrmConvertChecklistItem>[],
    this.updatedBy = '',
  });

  bool get isActive => status.toLowerCase() == 'active';

  CrmConvertStage copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? status,
    int? order,
    bool? isDeleted,
    List<CrmConvertChecklistItem>? checklistItems,
    DateTime? updatedAt,
    String? updatedBy,
  }) =>
      CrmConvertStage(
        id: id ?? this.id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        status: status ?? this.status,
        order: order ?? this.order,
        isDeleted: isDeleted ?? this.isDeleted,
        checklistItems: checklistItems ?? this.checklistItems,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
      );
}
