// ****************** FILE INFO ******************
// File Name: crm_relationship_category_model.dart
// Purpose: Data model representing a relationship category containing sub-types
// Author: Mohand Adel
// Created At: 12/08/2026
// ignore_for_file: constant_identifier_names

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_type_model.dart';

class CrmRelationshipCategoryModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String status; // 'active', 'inactive', 'deleted'
  final String iconUrl;
  final bool isActive;
  final bool isDeleted;
  final int order;
  final CrmAuditModel? audit;
  final List<CrmRelationshipTypeModel> types;

  static const String kId = 'Id';
  static const String kNameEn = 'Name_En';
  static const String kNameAr = 'Name_Ar';
  static const String kStatus = 'Status';
  static const String ICON_URL = 'Icon_Url';
  static const String kIsActive = 'Is_Active';
  static const String kIsDeleted = 'Is_Deleted';
  static const String kOrder = 'Order';
  static const String kAudit = 'Audit';
  static const String TYPES = 'Types';

  const CrmRelationshipCategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.status = 'active',
    this.iconUrl = '',
    this.isActive = true,
    this.isDeleted = false,
    this.order = 0,
    this.audit,
    this.types = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.kIdKey: id,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      CrmFirestoreKeys.kStatusKey: status,
      CrmFirestoreKeys.ICON_URL_KEY: iconUrl,
      CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
      CrmFirestoreKeys.ORDER_KEY: order,
      if (audit != null) CrmFirestoreKeys.AUDIT_KEY: audit!.toMap(),
      CrmFirestoreKeys.OPTIONS_KEY: types.map((t) => t.toMap()).toList(),
    };
  }

  factory CrmRelationshipCategoryModel.fromMap(Map<String, dynamic> map) {
    final dynamic typesData =
        CrmFirestoreKeys.read(map, CrmFirestoreKeys.OPTIONS_KEY, 'options');
    List<CrmRelationshipTypeModel> resolvedTypes = [];
    if (typesData is List) {
      resolvedTypes = typesData
          .map((item) => CrmRelationshipTypeModel.fromMap(
              Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    final dynamic auditData =
        CrmFirestoreKeys.read(map, CrmFirestoreKeys.AUDIT_KEY, 'audit');
    final String resolvedStatus =
        (CrmFirestoreKeys.read(map, CrmFirestoreKeys.kStatusKey, 'status') ??
                'active')
            .toString();
    final bool resolvedDeleted = (CrmFirestoreKeys.read(
              map,
              CrmFirestoreKeys.IS_DELETED_KEY,
              'isDeleted',
            ) ??
            resolvedStatus == 'deleted') ==
        true;
    final bool resolvedActive = (CrmFirestoreKeys.read(
              map,
              CrmFirestoreKeys.IS_ACTIVE_KEY,
              'isActive',
            ) ??
            resolvedStatus == 'active') ==
        true;

    return CrmRelationshipCategoryModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.kIdKey, 'id') ?? '')
          .toString(),
      nameEn:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.NAME_EN_KEY, 'nameEn') ??
                  '')
              .toString(),
      nameAr:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.NAME_AR_KEY, 'nameAr') ??
                  '')
              .toString(),
      status: resolvedStatus,
      iconUrl: (CrmFirestoreKeys.read(
                  map, CrmFirestoreKeys.ICON_URL_KEY, 'iconUrl') ??
              '')
          .toString(),
      isActive: resolvedActive,
      isDeleted: resolvedDeleted,
      order: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ORDER_KEY, 'order') ??
              0) is int
          ? CrmFirestoreKeys.read(map, CrmFirestoreKeys.ORDER_KEY, 'order')
              as int
          : int.tryParse(
                (CrmFirestoreKeys.read(
                          map,
                          CrmFirestoreKeys.ORDER_KEY,
                          'order',
                        ) ??
                        '0')
                    .toString(),
              ) ??
              0,
      audit: auditData == null
          ? null
          : CrmAuditModel.fromMap(Map<String, dynamic>.from(auditData as Map)),
      types: resolvedTypes,
    );
  }

  CrmRelationshipCategoryModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? status,
    String? iconUrl,
    bool? isActive,
    bool? isDeleted,
    int? order,
    CrmAuditModel? audit,
    List<CrmRelationshipTypeModel>? types,
  }) {
    return CrmRelationshipCategoryModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      status: status ?? this.status,
      iconUrl: iconUrl ?? this.iconUrl,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      audit: audit ?? this.audit,
      types: types ?? this.types,
    );
  }
}
