// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reasons_base_repository.dart
// Purpose: Contract for managing CRM client-status reason sets
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:knowticed_plus/features/crm/crm15_reasons/domain/entities/crm_reason.dart';

abstract class CrmReasonsBaseRepository {
  Stream<List<CrmReason>> watchReasons(String reasonSetId);
  Future<void> saveReasons({
    required String reasonSetId,
    required List<CrmReason> reasons,
    required String updatedBy,
  });
}
