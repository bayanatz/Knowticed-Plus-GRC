// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rules_repository.dart
// Purpose: Repository implementation for delivery fee rules
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm17_delivery_rules/data/data_source/crm_delivery_rules_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/entities/crm_delivery_rule.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/interfaces/crm_delivery_rules_base_repository.dart';

class CrmDeliveryRulesRepository implements CrmDeliveryRulesBaseRepository {
  final CrmDeliveryRulesRemoteDataSource _remoteDataSource;

  CrmDeliveryRulesRepository(
      {CrmDeliveryRulesRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? CrmDeliveryRulesRemoteDataSource();

  @override
  Stream<List<CrmDeliveryRule>> watchRules() => _remoteDataSource.watchRules();

  @override
  Future<void> createRule(CrmDeliveryRule rule) =>
      _remoteDataSource.createRule(rule);

  @override
  Future<void> updateRule(CrmDeliveryRule rule) =>
      _remoteDataSource.updateRule(rule);

  @override
  Future<void> deleteRule(CrmDeliveryRule rule) =>
      _remoteDataSource.deleteRule(rule);
}
