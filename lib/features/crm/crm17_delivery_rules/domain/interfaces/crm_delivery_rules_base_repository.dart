// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rules_base_repository.dart
// Purpose: Contract for managing delivery fee rules
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/entities/crm_delivery_rule.dart';

abstract class CrmDeliveryRulesBaseRepository {
  Stream<List<CrmDeliveryRule>> watchRules();
  Future<void> createRule(CrmDeliveryRule rule);
  Future<void> updateRule(CrmDeliveryRule rule);
  Future<void> deleteRule(CrmDeliveryRule rule);
}
