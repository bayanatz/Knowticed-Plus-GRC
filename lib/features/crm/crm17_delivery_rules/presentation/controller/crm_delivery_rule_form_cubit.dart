// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rule_form_cubit.dart
// Purpose: Owns delivery fee rule form validation and persistence
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/entities/crm_delivery_rule.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/interfaces/crm_delivery_rules_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/presentation/controller/crm_delivery_rule_form_state.dart';

class CrmDeliveryRuleFormCubit extends Cubit<CrmDeliveryRuleFormState> {
  final CrmDeliveryRulesBaseRepository _repository;
  final CrmDeliveryRule? _existingRule;

  CrmDeliveryRuleFormCubit({
    required CrmDeliveryRulesBaseRepository repository,
    CrmDeliveryRule? rule,
  })  : _repository = repository,
        _existingRule = rule,
        super(CrmDeliveryRuleFormState(
          rule: rule ?? CrmDeliveryRule(updatedAt: DateTime.now()),
        ));

  bool get isEditing => _existingRule != null;
  bool get isReadOnly => _existingRule != null && !state.isSaving;

  void updateNameEn(String value) => _update(nameEn: value);
  void updateNameAr(String value) => _update(nameAr: value);
  void updateCurrency(String value) => _update(currency: value);
  void updateActive(bool value) => _update(isActive: value);
  void updateDeliveryFrom(String value) =>
      _update(deliveryFrom: _number(value));
  void updateDeliveryTo(String value) => _update(deliveryTo: _number(value));
  void updateDeliveryUnit(String value) => _update(deliveryUnit: value);

  void updateBasedOn(String value) {
    final CrmDeliveryRule rule = state.rule.copyWith(basedOn: value);
    emit(state.copyWith(rule: rule));
  }

  void addRange({int? criterionIndex}) {
    if (criterionIndex == null) {
      _update(ranges: <CrmDeliveryRange>[
        ...state.rule.ranges,
        const CrmDeliveryRange()
      ]);
      return;
    }
    final List<CrmDeliveryCriterion> criteria =
        List<CrmDeliveryCriterion>.from(state.rule.criteria);
    final CrmDeliveryCriterion criterion = criteria[criterionIndex];
    criteria[criterionIndex] = criterion.copyWith(
      ranges: <CrmDeliveryRange>[...criterion.ranges, const CrmDeliveryRange()],
    );
    _update(criteria: criteria);
  }

  void removeRange(int index, {int? criterionIndex}) {
    final List<CrmDeliveryRange> ranges = criterionIndex == null
        ? List<CrmDeliveryRange>.from(state.rule.ranges)
        : List<CrmDeliveryRange>.from(
            state.rule.criteria[criterionIndex].ranges);
    if (ranges.length <= 1) return;
    ranges.removeAt(index);
    if (criterionIndex == null) {
      _update(ranges: ranges);
      return;
    }
    final List<CrmDeliveryCriterion> criteria =
        List<CrmDeliveryCriterion>.from(state.rule.criteria);
    criteria[criterionIndex] =
        criteria[criterionIndex].copyWith(ranges: ranges);
    _update(criteria: criteria);
  }

  void updateRange(int index, String field, String value,
      {int? criterionIndex}) {
    final List<CrmDeliveryRange> ranges = criterionIndex == null
        ? List<CrmDeliveryRange>.from(state.rule.ranges)
        : List<CrmDeliveryRange>.from(
            state.rule.criteria[criterionIndex].ranges);
    final CrmDeliveryRange current = ranges[index];
    final double number = _number(value);
    ranges[index] = switch (field) {
      'from' => current.copyWith(from: number),
      'to' => current.copyWith(to: number),
      _ => current.copyWith(fee: number),
    };
    if (criterionIndex == null) {
      _update(ranges: ranges);
      return;
    }
    final List<CrmDeliveryCriterion> criteria =
        List<CrmDeliveryCriterion>.from(state.rule.criteria);
    criteria[criterionIndex] =
        criteria[criterionIndex].copyWith(ranges: ranges);
    _update(criteria: criteria);
  }

  void addZone() => _update(
      zones: <CrmDeliveryZone>[...state.rule.zones, const CrmDeliveryZone()]);
  void removeZone(int index) {
    if (state.rule.zones.length <= 1) return;
    final List<CrmDeliveryZone> zones =
        List<CrmDeliveryZone>.from(state.rule.zones)..removeAt(index);
    _update(zones: zones);
  }

  void updateZone(int index,
      {List<String>? counties, List<String>? cities, String? fee}) {
    final List<CrmDeliveryZone> zones =
        List<CrmDeliveryZone>.from(state.rule.zones);
    zones[index] = zones[index].copyWith(
        counties: counties,
        cities: cities,
        fee: fee == null ? null : _number(fee));
    _update(zones: zones);
  }

  void updateCriterionName(int index, String value) => _replaceCriterion(
      index, state.rule.criteria[index].copyWith(name: value));
  void updateCriterionWeight(int index, String value) => _replaceCriterion(
      index, state.rule.criteria[index].copyWith(weight: _number(value)));
  void addCriterion() => _update(criteria: <CrmDeliveryCriterion>[
        ...state.rule.criteria,
        const CrmDeliveryCriterion(name: 'Criteria')
      ]);

  Future<bool> save() async {
    final String? validation = _validationError();
    if (validation != null) {
      emit(state.copyWith(errorMessage: validation));
      return false;
    }
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final CrmDeliveryRule rule = state.rule.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: _currentUserName,
      );
      if (isEditing) {
        await _repository.updateRule(rule);
      } else {
        await _repository.createRule(rule);
      }
      if (!isClosed) {
        emit(state.copyWith(rule: rule, isSaving: false, isSuccess: true));
      }
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      }
      return false;
    }
  }

  Future<bool> delete() async {
    final CrmDeliveryRule? rule = _existingRule;
    if (rule == null) return false;
    try {
      await _repository.deleteRule(rule.copyWith(updatedAt: DateTime.now()));
      return true;
    } catch (error) {
      if (!isClosed) emit(state.copyWith(errorMessage: error.toString()));
      return false;
    }
  }

  void clearError() => emit(state.copyWith(clearError: true));
  void clearSuccess() => emit(state.copyWith(isSuccess: false));

  void _replaceCriterion(int index, CrmDeliveryCriterion criterion) {
    final List<CrmDeliveryCriterion> criteria =
        List<CrmDeliveryCriterion>.from(state.rule.criteria)
          ..[index] = criterion;
    _update(criteria: criteria);
  }

  void _update({
    String? nameEn,
    String? nameAr,
    String? basedOn,
    String? currency,
    List<CrmDeliveryRange>? ranges,
    List<CrmDeliveryZone>? zones,
    List<CrmDeliveryCriterion>? criteria,
    double? deliveryFrom,
    double? deliveryTo,
    String? deliveryUnit,
    bool? isActive,
  }) =>
      emit(state.copyWith(
          rule: state.rule.copyWith(
        nameEn: nameEn,
        nameAr: nameAr,
        basedOn: basedOn,
        currency: currency,
        ranges: ranges,
        zones: zones,
        criteria: criteria,
        deliveryFrom: deliveryFrom,
        deliveryTo: deliveryTo,
        deliveryUnit: deliveryUnit,
        isActive: isActive,
      )));

  String? _validationError() {
    final CrmDeliveryRule rule = state.rule;
    if (rule.nameEn.trim().isEmpty || rule.nameAr.trim().isEmpty) {
      return 'Rule names are required.';
    }
    if (rule.currency.isEmpty) return 'Choose a currency.';
    if (rule.deliveryTo <= rule.deliveryFrom) {
      return 'Delivery time To must be greater than From.';
    }
    if (rule.basedOn == 'Zone' &&
        rule.zones.any((CrmDeliveryZone item) =>
            item.counties.isEmpty || item.cities.isEmpty || item.fee <= 0)) {
      return 'Complete all zone rows with a fee.';
    }
    final List<CrmDeliveryRange> ranges = rule.basedOn == 'Criteria'
        ? rule.criteria
            .expand((CrmDeliveryCriterion item) => item.ranges)
            .toList()
        : rule.ranges;
    if (ranges.any(
        (CrmDeliveryRange item) => item.to <= item.from || item.fee <= 0)) {
      return 'Each range needs From, To, and a positive delivery fee.';
    }
    if (rule.basedOn == 'Criteria' &&
        rule.criteria.any((CrmDeliveryCriterion item) =>
            item.name.trim().isEmpty || item.weight <= 0)) {
      return 'Complete all criteria weights.';
    }
    return null;
  }

  double _number(String value) => double.tryParse(value) ?? 0;

  String get _currentUserName {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final employee = Get.find<MainCoreEmployeeController>().employeeEntity;
      final String fullName = <String?>[
        employee?.firstName,
        employee?.lastName,
      ].whereType<String>().where((String s) => s.trim().isNotEmpty).join(' ');
      if (fullName.isNotEmpty) {
        return fullName;
      }
      final String? email = employee?.email;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim().toLowerCase();
      }
    }
    return 'Aya Ali';
  }
}
