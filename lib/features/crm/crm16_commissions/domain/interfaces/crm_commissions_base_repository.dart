// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commissions_base_repository.dart
// Purpose: Contract for managing flat-rate CRM commission packages
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';

abstract class CrmCommissionsBaseRepository {
  Stream<List<CrmCommissionPackage>> watchPackages();
  Future<void> createPackage(CrmCommissionPackage package);
  Future<void> updatePackage(CrmCommissionPackage package);
  Future<void> deletePackage(CrmCommissionPackage package);
}
