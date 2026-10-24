// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reason.dart
// Purpose: Immutable domain entity for a bilingual CRM client-status reason
// Author: Mohand Adel
// Created At: 07/10/2026

class CrmReason {
  final String nameEn;
  final String nameAr;

  const CrmReason({required this.nameEn, required this.nameAr});
}

class CrmReasonSetDefinition {
  final String id;
  final String title;

  const CrmReasonSetDefinition({required this.id, required this.title});
}
