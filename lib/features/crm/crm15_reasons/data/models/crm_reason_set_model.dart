// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reason_set_model.dart
// Purpose: Firestore serialization model for a CRM reason set
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:knowticed_plus/features/crm/crm15_reasons/domain/entities/crm_reason.dart';

class CrmReasonSetModel {
  static const String reasonsKey = 'Reasons';
  static const String nameEnKey = 'Name_En';
  static const String nameArKey = 'Name_Ar';
  static const String updatedAtKey = 'Updated_At';
  static const String updatedByKey = 'Updated_By';

  final List<CrmReason> reasons;

  const CrmReasonSetModel({required this.reasons});

  Map<String, dynamic> toMap(String updatedBy) => <String, dynamic>{
        reasonsKey: reasons
            .map((CrmReason item) => <String, dynamic>{
                  nameEnKey: item.nameEn,
                  nameArKey: item.nameAr,
                })
            .toList(),
        updatedAtKey: DateTime.now().toIso8601String(),
        updatedByKey: updatedBy,
      };

  factory CrmReasonSetModel.fromMap(Map<String, dynamic> map) {
    final List<CrmReason> reasons =
        ((map[reasonsKey] as List?) ?? const <dynamic>[])
            .whereType<Map>()
            .map((Map item) => CrmReason(
                  nameEn: (item[nameEnKey] ?? '').toString(),
                  nameAr: (item[nameArKey] ?? '').toString(),
                ))
            .toList();
    return CrmReasonSetModel(reasons: reasons);
  }
}
