// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rules_state.dart
// Purpose: Immutable state for the delivery rules list
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/entities/crm_delivery_rule.dart';

class CrmDeliveryRulesState {
  final List<CrmDeliveryRule> rules;
  final String query;
  final String status;
  final String? sort;
  final bool isLoading;
  final String? errorMessage;

  const CrmDeliveryRulesState({
    this.rules = const <CrmDeliveryRule>[],
    this.query = '',
    this.status = 'All',
    this.sort,
    this.isLoading = false,
    this.errorMessage,
  });

  int get activeCount =>
      rules.where((CrmDeliveryRule item) => item.isActive).length;
  int get inactiveCount => rules.length - activeCount;
  List<CrmDeliveryRule> get visibleRules {
    final String normalized = query.trim().toLowerCase();
    final List<CrmDeliveryRule> result = rules
        .where(
          (CrmDeliveryRule item) =>
              (status == 'All' ||
                  (status == 'Active' ? item.isActive : !item.isActive)) &&
              item.nameEn.toLowerCase().contains(normalized),
        )
        .toList();
    if (sort == 'name_asc') {
      result.sort((CrmDeliveryRule a, CrmDeliveryRule b) =>
          a.nameEn.compareTo(b.nameEn));
    }
    if (sort == 'name_desc') {
      result.sort((CrmDeliveryRule a, CrmDeliveryRule b) =>
          b.nameEn.compareTo(a.nameEn));
    }
    return result;
  }

  CrmDeliveryRulesState copyWith({
    List<CrmDeliveryRule>? rules,
    String? query,
    String? status,
    String? sort,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CrmDeliveryRulesState(
        rules: rules ?? this.rules,
        query: query ?? this.query,
        status: status ?? this.status,
        sort: sort ?? this.sort,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
