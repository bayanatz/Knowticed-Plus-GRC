// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rule_form_state.dart
// Purpose: Immutable editing state for a delivery fee rule
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/entities/crm_delivery_rule.dart';

class CrmDeliveryRuleFormState {
  final CrmDeliveryRule rule;
  final bool isSaving;
  final bool isSuccess;
  final String? errorMessage;

  const CrmDeliveryRuleFormState({
    required this.rule,
    this.isSaving = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  CrmDeliveryRuleFormState copyWith({
    CrmDeliveryRule? rule,
    bool? isSaving,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CrmDeliveryRuleFormState(
        rule: rule ?? this.rule,
        isSaving: isSaving ?? this.isSaving,
        isSuccess: isSuccess ?? this.isSuccess,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
