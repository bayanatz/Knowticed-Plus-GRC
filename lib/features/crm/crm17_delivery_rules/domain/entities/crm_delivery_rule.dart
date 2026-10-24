// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rule.dart
// Purpose: Immutable delivery fee rule entities
// Author: Mohand Adel
// Created At: 08/10/2026

class CrmDeliveryRange {
  final double from;
  final double to;
  final double fee;

  const CrmDeliveryRange({this.from = 0, this.to = 0, this.fee = 0});

  CrmDeliveryRange copyWith({double? from, double? to, double? fee}) =>
      CrmDeliveryRange(
        from: from ?? this.from,
        to: to ?? this.to,
        fee: fee ?? this.fee,
      );
}

class CrmDeliveryZone {
  final List<String> counties;
  final List<String> cities;
  final double fee;

  const CrmDeliveryZone({
    this.counties = const <String>[],
    this.cities = const <String>[],
    this.fee = 0,
  });

  CrmDeliveryZone copyWith({
    List<String>? counties,
    List<String>? cities,
    double? fee,
  }) =>
      CrmDeliveryZone(
        counties: counties ?? this.counties,
        cities: cities ?? this.cities,
        fee: fee ?? this.fee,
      );
}

class CrmDeliveryCriterion {
  final String name;
  final double weight;
  final List<CrmDeliveryRange> ranges;

  const CrmDeliveryCriterion({
    this.name = 'Price',
    this.weight = 0,
    this.ranges = const <CrmDeliveryRange>[CrmDeliveryRange()],
  });

  CrmDeliveryCriterion copyWith({
    String? name,
    double? weight,
    List<CrmDeliveryRange>? ranges,
  }) =>
      CrmDeliveryCriterion(
        name: name ?? this.name,
        weight: weight ?? this.weight,
        ranges: ranges ?? this.ranges,
      );
}

class CrmDeliveryRule {
  final String id;
  final String nameEn;
  final String nameAr;
  final String basedOn;
  final String currency;
  final List<CrmDeliveryRange> ranges;
  final List<CrmDeliveryZone> zones;
  final List<CrmDeliveryCriterion> criteria;
  final double deliveryFrom;
  final double deliveryTo;
  final String deliveryUnit;
  final bool isActive;
  final bool isDeleted;
  final DateTime updatedAt;
  final String updatedBy;

  const CrmDeliveryRule({
    this.id = '',
    this.nameEn = '',
    this.nameAr = '',
    this.basedOn = 'Quantity',
    this.currency = '',
    this.ranges = const <CrmDeliveryRange>[CrmDeliveryRange()],
    this.zones = const <CrmDeliveryZone>[CrmDeliveryZone()],
    this.criteria = const <CrmDeliveryCriterion>[
      CrmDeliveryCriterion(),
      CrmDeliveryCriterion(name: 'Weight'),
    ],
    this.deliveryFrom = 0,
    this.deliveryTo = 0,
    this.deliveryUnit = 'Days',
    this.isActive = true,
    this.isDeleted = false,
    required this.updatedAt,
    this.updatedBy = '',
  });

  CrmDeliveryRule copyWith({
    String? id,
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
    bool? isDeleted,
    DateTime? updatedAt,
    String? updatedBy,
  }) =>
      CrmDeliveryRule(
        id: id ?? this.id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        basedOn: basedOn ?? this.basedOn,
        currency: currency ?? this.currency,
        ranges: ranges ?? this.ranges,
        zones: zones ?? this.zones,
        criteria: criteria ?? this.criteria,
        deliveryFrom: deliveryFrom ?? this.deliveryFrom,
        deliveryTo: deliveryTo ?? this.deliveryTo,
        deliveryUnit: deliveryUnit ?? this.deliveryUnit,
        isActive: isActive ?? this.isActive,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
      );
}
