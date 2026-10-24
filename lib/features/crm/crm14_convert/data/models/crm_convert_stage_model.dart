// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_stage_model.dart
// Purpose: Firestore serialization model for CRM conversion stages
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:knowticed_plus/features/crm/crm14_convert/domain/entities/crm_convert_stage.dart';

class CrmConvertStageModel {
  static const String _id = 'Id';
  static const String _nameEn = 'Name_En';
  static const String _nameAr = 'Name_Ar';
  static const String _status = 'Status';
  static const String _order = 'Order';
  static const String _isDeleted = 'Is_Deleted';
  static const String _checklist = 'Checklist_Items';
  static const String _updatedAt = 'Updated_At';
  static const String _updatedBy = 'Updated_By';

  final CrmConvertStage stage;

  const CrmConvertStageModel(this.stage);

  Map<String, dynamic> toMap() => <String, dynamic>{
        _id: stage.id,
        _nameEn: stage.nameEn,
        _nameAr: stage.nameAr,
        _status: stage.status,
        _order: stage.order,
        _isDeleted: stage.isDeleted,
        _checklist: stage.checklistItems
            .map((CrmConvertChecklistItem item) => <String, dynamic>{
                  _nameEn: item.nameEn,
                  _nameAr: item.nameAr,
                })
            .toList(),
        _updatedAt: stage.updatedAt.toIso8601String(),
        _updatedBy: stage.updatedBy,
      };

  factory CrmConvertStageModel.fromMap(Map<String, dynamic> map) {
    final List<CrmConvertChecklistItem> items =
        ((map[_checklist] as List?) ?? const <dynamic>[])
            .whereType<Map>()
            .map((Map item) => CrmConvertChecklistItem(
                  nameEn: (item[_nameEn] ?? '').toString(),
                  nameAr: (item[_nameAr] ?? '').toString(),
                ))
            .toList();
    return CrmConvertStageModel(
      CrmConvertStage(
        id: (map[_id] ?? '').toString(),
        nameEn: (map[_nameEn] ?? '').toString(),
        nameAr: (map[_nameAr] ?? '').toString(),
        status: (map[_status] ?? 'active').toString(),
        order: int.tryParse((map[_order] ?? 0).toString()) ?? 0,
        isDeleted: map[_isDeleted] == true,
        checklistItems: items,
        updatedAt: DateTime.tryParse((map[_updatedAt] ?? '').toString()) ??
            DateTime.now(),
        updatedBy: (map[_updatedBy] ?? '').toString(),
      ),
    );
  }
}
