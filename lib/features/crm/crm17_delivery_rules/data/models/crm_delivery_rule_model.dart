// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rule_model.dart
// Purpose: Firestore serialization for delivery fee rules
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/entities/crm_delivery_rule.dart';

class CrmDeliveryRuleModel {
  static const String _id = 'Id';
  static const String _nameEn = 'Name_En';
  static const String _nameAr = 'Name_Ar';
  static const String _basedOn = 'Based_On';
  static const String _currency = 'Currency';
  static const String _ranges = 'Ranges';
  static const String _zones = 'Zones';
  static const String _criteria = 'Criteria';
  static const String _from = 'From';
  static const String _to = 'To';
  static const String _fee = 'Delivery_Fee';
  static const String _counties = 'Counties';
  static const String _cities = 'Cities';
  static const String _name = 'Name';
  static const String _weight = 'Weight';
  static const String _deliveryFrom = 'Delivery_From';
  static const String _deliveryTo = 'Delivery_To';
  static const String _deliveryUnit = 'Delivery_Unit';
  static const String _isActive = 'Is_Active';
  static const String _isDeleted = 'Is_Deleted';
  static const String _updatedAt = 'Updated_At';
  static const String _updatedBy = 'Updated_By';

  final CrmDeliveryRule rule;

  const CrmDeliveryRuleModel(this.rule);

  Map<String, dynamic> toMap() => <String, dynamic>{
        _id: rule.id,
        _nameEn: rule.nameEn,
        _nameAr: rule.nameAr,
        _basedOn: rule.basedOn,
        _currency: rule.currency,
        _ranges: _rangesMap(rule.ranges),
        _zones: rule.zones
            .map((CrmDeliveryZone item) => <String, dynamic>{
                  _counties: item.counties,
                  _cities: item.cities,
                  _fee: item.fee,
                })
            .toList(),
        _criteria: rule.criteria
            .map((CrmDeliveryCriterion item) => <String, dynamic>{
                  _name: item.name,
                  _weight: item.weight,
                  _ranges: _rangesMap(item.ranges),
                })
            .toList(),
        _deliveryFrom: rule.deliveryFrom,
        _deliveryTo: rule.deliveryTo,
        _deliveryUnit: rule.deliveryUnit,
        _isActive: rule.isActive,
        _isDeleted: rule.isDeleted,
        _updatedAt: rule.updatedAt.toIso8601String(),
        _updatedBy: rule.updatedBy,
      };

  factory CrmDeliveryRuleModel.fromMap(Map<String, dynamic> map) =>
      CrmDeliveryRuleModel(
        CrmDeliveryRule(
          id: (map[_id] ?? '').toString(),
          nameEn: (map[_nameEn] ?? '').toString(),
          nameAr: (map[_nameAr] ?? '').toString(),
          basedOn: (map[_basedOn] ?? 'Quantity').toString(),
          currency: (map[_currency] ?? '').toString(),
          ranges: _rangesFrom(map[_ranges]),
          zones: ((map[_zones] as List?) ?? const <dynamic>[])
              .whereType<Map>()
              .map(
                (Map<dynamic, dynamic> item) => CrmDeliveryZone(
                  counties:
                      List<String>.from(item[_counties] ?? const <String>[]),
                  cities: List<String>.from(item[_cities] ?? const <String>[]),
                  fee: (item[_fee] as num?)?.toDouble() ?? 0,
                ),
              )
              .toList(),
          criteria: ((map[_criteria] as List?) ?? const <dynamic>[])
              .whereType<Map>()
              .map(
                (Map<dynamic, dynamic> item) => CrmDeliveryCriterion(
                  name: (item[_name] ?? '').toString(),
                  weight: (item[_weight] as num?)?.toDouble() ?? 0,
                  ranges: _rangesFrom(item[_ranges]),
                ),
              )
              .toList(),
          deliveryFrom: (map[_deliveryFrom] as num?)?.toDouble() ?? 0,
          deliveryTo: (map[_deliveryTo] as num?)?.toDouble() ?? 0,
          deliveryUnit: (map[_deliveryUnit] ?? 'Days').toString(),
          isActive: map[_isActive] != false,
          isDeleted: map[_isDeleted] == true,
          updatedAt: DateTime.tryParse((map[_updatedAt] ?? '').toString()) ??
              DateTime.now(),
          updatedBy: (map[_updatedBy] ?? '').toString(),
        ),
      );

  static List<Map<String, dynamic>> _rangesMap(List<CrmDeliveryRange> ranges) =>
      ranges
          .map((CrmDeliveryRange item) => <String, dynamic>{
                _from: item.from,
                _to: item.to,
                _fee: item.fee,
              })
          .toList();

  static List<CrmDeliveryRange> _rangesFrom(dynamic value) =>
      ((value as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (Map<dynamic, dynamic> item) => CrmDeliveryRange(
              from: (item[_from] as num?)?.toDouble() ?? 0,
              to: (item[_to] as num?)?.toDouble() ?? 0,
              fee: (item[_fee] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList();
}
