// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_base_repository.dart
// Purpose: Contract for managing CRM conversion stages
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:knowticed_plus/features/crm/crm14_convert/domain/entities/crm_convert_stage.dart';

abstract class CrmConvertBaseRepository {
  Stream<List<CrmConvertStage>> watchStages();
  Future<void> createStage(CrmConvertStage stage);
  Future<void> updateStage(CrmConvertStage stage);
  Future<void> deleteStage(CrmConvertStage stage);
}
