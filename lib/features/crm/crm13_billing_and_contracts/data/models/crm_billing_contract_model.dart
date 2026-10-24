// ****************** FILE INFO ******************
// File Name: crm_billing_contract_model.dart
// Purpose: Data model for CRM Billing and Contracts configuration
// Author: Mohand Adel
// Created At: 06/10/2026

// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class CrmBilingualNoteModel {
  final String textEn;
  final String textAr;

  static const String TEXT_EN = 'text_en';
  static const String TEXT_AR = 'text_ar';

  const CrmBilingualNoteModel({
    this.textEn = '',
    this.textAr = '',
  });

  factory CrmBilingualNoteModel.fromMap(Map<String, dynamic> map) {
    return CrmBilingualNoteModel(
      textEn: (map[TEXT_EN] ?? map['textEn'] ?? '').toString(),
      textAr: (map[TEXT_AR] ?? map['textAr'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      TEXT_EN: textEn,
      TEXT_AR: textAr,
    };
  }

  CrmBilingualNoteModel copyWith({
    String? textEn,
    String? textAr,
  }) {
    return CrmBilingualNoteModel(
      textEn: textEn ?? this.textEn,
      textAr: textAr ?? this.textAr,
    );
  }
}

class CrmBillingContractModel {
  final String id;
  final String code;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String status;
  final bool isDeleted;

  // Visual & File Assets
  final String logoUrl;
  final String digitalSealUrl;
  final String watermarkUrl;
  final String signatureUrl;

  // Bilingual Messages
  final String messageEn;
  final String messageAr;

  // Dynamic Notes List
  final List<CrmBilingualNoteModel> notes;

  // Colors
  final String textColorHex;
  final String highlightColorHex;

  // Legacy / Configuration Fields
  final String billingCycle;
  final String paymentTerms;
  final int contractDuration;
  final String currency;
  final double lateFeePercentage;
  final double taxPercentage;
  final bool requireDeposit;
  final double depositPercentage;
  final bool autoRenewal;
  final int gracePeriodDays;
  final String contractTerms;
  final String contractTermsAr;
  final List<CrmBilingualNoteModel> contractSections;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String updatedBy;

  static const String billingControlId = 'billing';
  static const String contractControlId = 'contracts';

  static const String kId = 'id';
  static const String CODE = 'code';
  static const String kNameEn = 'name_en';
  static const String kNameAr = 'name_ar';
  static const String DESCRIPTION_EN = 'description_en';
  static const String DESCRIPTION_AR = 'description_ar';
  static const String kStatus = 'status';
  static const String kIsDeleted = 'is_deleted';

  static const String LOGO_URL = 'logo_url';
  static const String DIGITAL_SEAL_URL = 'digital_seal_url';
  static const String WATERMARK_URL = 'watermark_url';
  static const String SIGNATURE_URL = 'signature_url';

  static const String MESSAGE_EN = 'message_en';
  static const String MESSAGE_AR = 'message_ar';

  static const String NOTES = 'notes';

  static const String TEXT_COLOR_HEX = 'text_color_hex';
  static const String HIGHLIGHT_COLOR_HEX = 'highlight_color_hex';

  static const String BILLING_CYCLE = 'billing_cycle';
  static const String PAYMENT_TERMS = 'payment_terms';
  static const String CONTRACT_DURATION = 'contract_duration';
  static const String CURRENCY = 'currency';
  static const String LATE_FEE_PERCENTAGE = 'late_fee_percentage';
  static const String TAX_PERCENTAGE = 'tax_percentage';
  static const String REQUIRE_DEPOSIT = 'require_deposit';
  static const String DEPOSIT_PERCENTAGE = 'deposit_percentage';
  static const String AUTO_RENEWAL = 'auto_renewal';
  static const String GRACE_PERIOD_DAYS = 'grace_period_days';
  static const String CONTRACT_TERMS = 'contract_terms';
  static const String CONTRACT_TERMS_AR = 'contract_terms_ar';
  static const String CONTRACT_SECTIONS = 'contract_sections';
  static const String kCreatedAt = 'created_at';
  static const String kUpdatedAt = 'updated_at';
  static const String kUpdatedBy = 'updated_by';

  const CrmBillingContractModel({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    this.descriptionEn = '',
    this.descriptionAr = '',
    this.status = 'Active',
    this.isDeleted = false,
    this.logoUrl = '',
    this.digitalSealUrl = '',
    this.watermarkUrl = '',
    this.signatureUrl = '',
    this.messageEn = '',
    this.messageAr = '',
    this.notes = const <CrmBilingualNoteModel>[],
    this.textColorHex = '#2d2d2d',
    this.highlightColorHex = '#9e9e9e',
    this.billingCycle = 'Monthly',
    this.paymentTerms = 'Net 30',
    this.contractDuration = 12,
    this.currency = 'SAR',
    this.lateFeePercentage = 0.0,
    this.taxPercentage = 15.0,
    this.requireDeposit = false,
    this.depositPercentage = 0.0,
    this.autoRenewal = true,
    this.gracePeriodDays = 14,
    this.contractTerms = '',
    this.contractTermsAr = '',
    this.contractSections = const <CrmBilingualNoteModel>[],
    this.createdAt,
    this.updatedAt,
    this.updatedBy = 'system',
  });

  bool get isActive => status.toLowerCase() == 'active' && !isDeleted;
  bool get isStaticControl => id == billingControlId || id == contractControlId;

  factory CrmBillingContractModel.getEmptyModel() {
    return const CrmBillingContractModel(
      id: '',
      code: '',
      nameEn: '',
      nameAr: '',
      descriptionEn: '',
      descriptionAr: '',
      status: 'Active',
      isDeleted: false,
      logoUrl: '',
      digitalSealUrl: '',
      watermarkUrl: '',
      signatureUrl: '',
      messageEn: '',
      messageAr: '',
      notes: <CrmBilingualNoteModel>[
        CrmBilingualNoteModel(),
        CrmBilingualNoteModel(),
        CrmBilingualNoteModel(),
      ],
      textColorHex: '#2d2d2d',
      highlightColorHex: '#9e9e9e',
      billingCycle: 'Monthly',
      paymentTerms: 'Net 30',
      contractDuration: 12,
      currency: 'SAR',
      lateFeePercentage: 0.0,
      taxPercentage: 15.0,
      requireDeposit: false,
      depositPercentage: 0.0,
      autoRenewal: true,
      gracePeriodDays: 14,
      contractTerms: '',
      contractTermsAr: '',
      contractSections: <CrmBilingualNoteModel>[
        CrmBilingualNoteModel(),
        CrmBilingualNoteModel(),
        CrmBilingualNoteModel(),
      ],
      updatedBy: 'system',
    );
  }

  factory CrmBillingContractModel.fromMap(Map<String, dynamic> map,
      [String? docId]) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final List<CrmBilingualNoteModel> parsedNotes =
        _parseBilingualItems(map[NOTES] ?? map['notes']);
    final List<CrmBilingualNoteModel> parsedContractSections =
        _parseBilingualItems(
      map[CONTRACT_SECTIONS] ?? map['contractSections'],
    );

    return CrmBillingContractModel(
      id: (docId != null && docId.isNotEmpty)
          ? docId
          : (map[kId] ?? map['id'] ?? '').toString(),
      code: (map[CODE] ?? map['code'] ?? '').toString(),
      nameEn: (map[kNameEn] ?? map['nameEn'] ?? map['name'] ?? '').toString(),
      nameAr: (map[kNameAr] ?? map['nameAr'] ?? '').toString(),
      descriptionEn:
          (map[DESCRIPTION_EN] ?? map['descriptionEn'] ?? '').toString(),
      descriptionAr:
          (map[DESCRIPTION_AR] ?? map['descriptionAr'] ?? '').toString(),
      status: (map[kStatus] ?? map['status'] ?? 'Active').toString(),
      isDeleted:
          (map[kIsDeleted] ?? map['isDeleted'] ?? false) as bool? ?? false,
      logoUrl: (map[LOGO_URL] ?? map['logoUrl'] ?? '').toString(),
      digitalSealUrl:
          (map[DIGITAL_SEAL_URL] ?? map['digitalSealUrl'] ?? '').toString(),
      watermarkUrl:
          (map[WATERMARK_URL] ?? map['watermarkUrl'] ?? '').toString(),
      signatureUrl:
          (map[SIGNATURE_URL] ?? map['signatureUrl'] ?? '').toString(),
      messageEn: (map[MESSAGE_EN] ?? map['messageEn'] ?? '').toString(),
      messageAr: (map[MESSAGE_AR] ?? map['messageAr'] ?? '').toString(),
      notes: parsedNotes.isNotEmpty
          ? parsedNotes
          : const <CrmBilingualNoteModel>[
              CrmBilingualNoteModel(),
              CrmBilingualNoteModel(),
              CrmBilingualNoteModel(),
            ],
      textColorHex:
          (map[TEXT_COLOR_HEX] ?? map['textColorHex'] ?? '#2d2d2d').toString(),
      highlightColorHex:
          (map[HIGHLIGHT_COLOR_HEX] ?? map['highlightColorHex'] ?? '#9e9e9e')
              .toString(),
      billingCycle:
          (map[BILLING_CYCLE] ?? map['billingCycle'] ?? 'Monthly').toString(),
      paymentTerms:
          (map[PAYMENT_TERMS] ?? map['paymentTerms'] ?? 'Net 30').toString(),
      contractDuration:
          (map[CONTRACT_DURATION] ?? map['contractDuration'] ?? 12) as int? ??
              12,
      currency: (map[CURRENCY] ?? map['currency'] ?? 'SAR').toString(),
      lateFeePercentage:
          ((map[LATE_FEE_PERCENTAGE] ?? map['lateFeePercentage'] ?? 0.0) as num)
              .toDouble(),
      taxPercentage:
          ((map[TAX_PERCENTAGE] ?? map['taxPercentage'] ?? 15.0) as num)
              .toDouble(),
      requireDeposit:
          (map[REQUIRE_DEPOSIT] ?? map['requireDeposit'] ?? false) as bool? ??
              false,
      depositPercentage:
          ((map[DEPOSIT_PERCENTAGE] ?? map['depositPercentage'] ?? 0.0) as num)
              .toDouble(),
      autoRenewal:
          (map[AUTO_RENEWAL] ?? map['autoRenewal'] ?? true) as bool? ?? true,
      gracePeriodDays:
          (map[GRACE_PERIOD_DAYS] ?? map['gracePeriodDays'] ?? 14) as int? ??
              14,
      contractTerms:
          (map[CONTRACT_TERMS] ?? map['contractTerms'] ?? '').toString(),
      contractTermsAr:
          (map[CONTRACT_TERMS_AR] ?? map['contractTermsAr'] ?? '').toString(),
      contractSections: parsedContractSections.isNotEmpty
          ? parsedContractSections
          : const <CrmBilingualNoteModel>[
              CrmBilingualNoteModel(),
              CrmBilingualNoteModel(),
              CrmBilingualNoteModel(),
            ],
      createdAt: parseDate(map[kCreatedAt] ?? map['createdAt']),
      updatedAt: parseDate(map[kUpdatedAt] ?? map['updatedAt']),
      updatedBy: (map[kUpdatedBy] ?? map['updatedBy'] ?? 'system').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kId: id,
      CODE: code,
      kNameEn: nameEn,
      kNameAr: nameAr,
      DESCRIPTION_EN: descriptionEn,
      DESCRIPTION_AR: descriptionAr,
      kStatus: status,
      kIsDeleted: isDeleted,
      LOGO_URL: logoUrl,
      DIGITAL_SEAL_URL: digitalSealUrl,
      WATERMARK_URL: watermarkUrl,
      SIGNATURE_URL: signatureUrl,
      MESSAGE_EN: messageEn,
      MESSAGE_AR: messageAr,
      NOTES: notes.map((note) => note.toMap()).toList(),
      TEXT_COLOR_HEX: textColorHex,
      HIGHLIGHT_COLOR_HEX: highlightColorHex,
      BILLING_CYCLE: billingCycle,
      PAYMENT_TERMS: paymentTerms,
      CONTRACT_DURATION: contractDuration,
      CURRENCY: currency,
      LATE_FEE_PERCENTAGE: lateFeePercentage,
      TAX_PERCENTAGE: taxPercentage,
      REQUIRE_DEPOSIT: requireDeposit,
      DEPOSIT_PERCENTAGE: depositPercentage,
      AUTO_RENEWAL: autoRenewal,
      GRACE_PERIOD_DAYS: gracePeriodDays,
      CONTRACT_TERMS: contractTerms,
      CONTRACT_TERMS_AR: contractTermsAr,
      CONTRACT_SECTIONS:
          contractSections.map((section) => section.toMap()).toList(),
      if (createdAt != null) kCreatedAt: Timestamp.fromDate(createdAt!),
      if (updatedAt != null) kUpdatedAt: Timestamp.fromDate(updatedAt!),
      kUpdatedBy: updatedBy,
    };
  }

  CrmBillingContractModel copyWith({
    String? id,
    String? code,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    String? status,
    bool? isDeleted,
    String? logoUrl,
    String? digitalSealUrl,
    String? watermarkUrl,
    String? signatureUrl,
    String? messageEn,
    String? messageAr,
    List<CrmBilingualNoteModel>? notes,
    String? textColorHex,
    String? highlightColorHex,
    String? billingCycle,
    String? paymentTerms,
    int? contractDuration,
    String? currency,
    double? lateFeePercentage,
    double? taxPercentage,
    bool? requireDeposit,
    double? depositPercentage,
    bool? autoRenewal,
    int? gracePeriodDays,
    String? contractTerms,
    String? contractTermsAr,
    List<CrmBilingualNoteModel>? contractSections,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return CrmBillingContractModel(
      id: id ?? this.id,
      code: code ?? this.code,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      logoUrl: logoUrl ?? this.logoUrl,
      digitalSealUrl: digitalSealUrl ?? this.digitalSealUrl,
      watermarkUrl: watermarkUrl ?? this.watermarkUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      messageEn: messageEn ?? this.messageEn,
      messageAr: messageAr ?? this.messageAr,
      notes: notes ?? this.notes,
      textColorHex: textColorHex ?? this.textColorHex,
      highlightColorHex: highlightColorHex ?? this.highlightColorHex,
      billingCycle: billingCycle ?? this.billingCycle,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      contractDuration: contractDuration ?? this.contractDuration,
      currency: currency ?? this.currency,
      lateFeePercentage: lateFeePercentage ?? this.lateFeePercentage,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      requireDeposit: requireDeposit ?? this.requireDeposit,
      depositPercentage: depositPercentage ?? this.depositPercentage,
      autoRenewal: autoRenewal ?? this.autoRenewal,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      contractTerms: contractTerms ?? this.contractTerms,
      contractTermsAr: contractTermsAr ?? this.contractTermsAr,
      contractSections: contractSections ?? this.contractSections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  static List<CrmBilingualNoteModel> _parseBilingualItems(dynamic rawItems) {
    if (rawItems is! List) return <CrmBilingualNoteModel>[];

    return rawItems
        .whereType<Map>()
        .map(
          (Map item) => CrmBilingualNoteModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}
