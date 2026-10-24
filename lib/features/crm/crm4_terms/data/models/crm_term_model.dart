// ****************** FILE INFO ******************
// File Name: crm_term_model.dart
// Purpose: Data model representing a CRM Term group containing clauses
// Author: Mohand Adel
// Created At: 16/08/2026
// ignore_for_file: constant_identifier_names

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_clause_model.dart';

class CrmTermModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String status; // 'active', 'inactive', 'deleted'
  final bool isActive;
  final bool isDeleted;
  final int order;
  final CrmAuditModel? audit;
  final List<CrmTermClauseModel> clauses;
  final String systemKey;

  static const String kId = 'Id';
  static const String kNameEn = 'Name_En';
  static const String kNameAr = 'Name_Ar';
  static const String kStatus = 'Status';
  static const String kIsActive = 'Is_Active';
  static const String kIsDeleted = 'Is_Deleted';
  static const String kOrder = 'Order';
  static const String kAudit = 'Audit';
  static const String CLAUSES = 'Clauses';
  static const String SYSTEM_KEY = 'System_Key';

  const CrmTermModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.status = 'active',
    this.isActive = true,
    this.isDeleted = false,
    this.order = 0,
    this.audit,
    this.clauses = const [],
    this.systemKey = '',
  });

  int get termsCount => clauses.length;

  String get editorName {
    if (audit == null) return 'Admin';
    final String by =
        audit!.updatedBy.isNotEmpty ? audit!.updatedBy : audit!.createdBy;
    if (by.contains('@')) {
      final String username = by.split('@').first;
      return username
          .split('.')
          .map((part) => part.isNotEmpty
              ? '${part[0].toUpperCase()}${part.substring(1)}'
              : '')
          .join(' ');
    }
    return by.isNotEmpty ? by : 'Admin';
  }

  String get lastUpdateFormatted {
    if (audit == null) return '';
    final DateTime dt = audit!.updatedAt;
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String localizedName(bool isArabic) {
    if (isArabic) {
      return nameAr.isNotEmpty ? nameAr : nameEn;
    }
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.kIdKey: id,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      CrmFirestoreKeys.kStatusKey: status,
      CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
      CrmFirestoreKeys.ORDER_KEY: order,
      if (audit != null) CrmFirestoreKeys.AUDIT_KEY: audit!.toMap(),
      CrmFirestoreKeys.CLAUSES_KEY: clauses.map((c) => c.toMap()).toList(),
      SYSTEM_KEY: systemKey,
    };
  }

  factory CrmTermModel.fromMap(Map<String, dynamic> map) {
    final dynamic clausesData =
        CrmFirestoreKeys.read(map, CrmFirestoreKeys.CLAUSES_KEY, 'clauses') ??
            CrmFirestoreKeys.read(map, 'Options', 'options');
    List<CrmTermClauseModel> resolvedClauses = [];
    if (clausesData is List) {
      resolvedClauses = clausesData
          .map((item) => CrmTermClauseModel.fromMap(
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

    return CrmTermModel(
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
      isActive: resolvedActive,
      isDeleted: resolvedDeleted,
      order: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ORDER_KEY, 'order') ??
          0) as int,
      audit: auditData is Map
          ? CrmAuditModel.fromMap(Map<String, dynamic>.from(auditData))
          : null,
      clauses: resolvedClauses,
      systemKey: (CrmFirestoreKeys.read(map, SYSTEM_KEY, 'systemKey') ?? '')
          .toString(),
    );
  }

  factory CrmTermModel.getEmptyModel() {
    return const CrmTermModel(
      id: '',
      nameEn: '',
      nameAr: '',
      status: 'active',
      isActive: true,
      isDeleted: false,
      order: 0,
      clauses: [],
      systemKey: '',
    );
  }

  CrmTermModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? status,
    bool? isActive,
    bool? isDeleted,
    int? order,
    CrmAuditModel? audit,
    List<CrmTermClauseModel>? clauses,
    String? systemKey,
  }) {
    return CrmTermModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      audit: audit ?? this.audit,
      clauses: clauses ?? this.clauses,
      systemKey: systemKey ?? this.systemKey,
    );
  }
}
