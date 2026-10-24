// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rules_cubit.dart
// Purpose: Streams, filters, and deletes delivery fee rules
// Author: Mohand Adel
// Created At: 08/10/2026

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/entities/crm_delivery_rule.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/interfaces/crm_delivery_rules_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/presentation/controller/crm_delivery_rules_state.dart';

class CrmDeliveryRulesCubit extends Cubit<CrmDeliveryRulesState> {
  final CrmDeliveryRulesBaseRepository _repository;
  StreamSubscription<List<CrmDeliveryRule>>? _subscription;

  CrmDeliveryRulesCubit({required CrmDeliveryRulesBaseRepository repository})
      : _repository = repository,
        super(const CrmDeliveryRulesState());

  void init() {
    emit(state.copyWith(isLoading: true, clearError: true));
    _subscription = _repository.watchRules().listen(
      (List<CrmDeliveryRule> rules) {
        if (!isClosed) emit(state.copyWith(rules: rules, isLoading: false));
      },
      onError: (Object error) {
        if (!isClosed) {
          emit(
              state.copyWith(isLoading: false, errorMessage: error.toString()));
        }
      },
    );
  }

  void search(String value) => emit(state.copyWith(query: value));
  void setStatus(String value) => emit(state.copyWith(status: value));
  void setSort(String? value) => emit(state.copyWith(sort: value));
  void clearError() => emit(state.copyWith(clearError: true));

  Future<bool> deleteRule(CrmDeliveryRule rule) async {
    try {
      await _repository.deleteRule(rule.copyWith(updatedAt: DateTime.now()));
      return true;
    } catch (error) {
      if (!isClosed) emit(state.copyWith(errorMessage: error.toString()));
      return false;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
