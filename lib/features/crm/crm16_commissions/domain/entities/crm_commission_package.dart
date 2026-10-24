// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commission_package.dart
// Purpose: Immutable domain entities for commission packages
// Author: Mohand Adel
// Created At: 08/10/2026

class CrmCommissionDomain {
  final String applyOn;
  final List<String> categoryIds;
  final List<String> productIds;
  final String targetType;
  final double targetValue;
  final String frequency;
  final String billingCycle;
  final String currency;

  const CrmCommissionDomain({
    this.applyOn = 'Products',
    this.categoryIds = const <String>[],
    this.productIds = const <String>[],
    this.targetType = 'Count',
    this.targetValue = 0,
    this.frequency = 'Monthly',
    this.billingCycle = '',
    this.currency = '',
  });

  CrmCommissionDomain copyWith({
    String? applyOn,
    List<String>? categoryIds,
    List<String>? productIds,
    String? targetType,
    double? targetValue,
    String? frequency,
    String? billingCycle,
    String? currency,
  }) =>
      CrmCommissionDomain(
        applyOn: applyOn ?? this.applyOn,
        categoryIds: categoryIds ?? this.categoryIds,
        productIds: productIds ?? this.productIds,
        targetType: targetType ?? this.targetType,
        targetValue: targetValue ?? this.targetValue,
        frequency: frequency ?? this.frequency,
        billingCycle: billingCycle ?? this.billingCycle,
        currency: currency ?? this.currency,
      );
}

class CrmProductCommission {
  final String categoryId;
  final String productId;
  final double value;

  const CrmProductCommission({
    required this.categoryId,
    required this.productId,
    this.value = 0,
  });

  CrmProductCommission copyWith({double? value}) => CrmProductCommission(
        categoryId: categoryId,
        productId: productId,
        value: value ?? this.value,
      );
}

class CrmCommissionTierRange {
  final double from;
  final double to;
  final double value;

  const CrmCommissionTierRange({
    this.from = 0,
    this.to = 0,
    this.value = 0,
  });

  CrmCommissionTierRange copyWith({double? from, double? to, double? value}) =>
      CrmCommissionTierRange(
        from: from ?? this.from,
        to: to ?? this.to,
        value: value ?? this.value,
      );
}

class CrmCommissionPackage {
  final String id;
  final String nameEn;
  final String nameAr;
  final List<String> countries;
  final String compensationCategory;
  final String compensationType;
  final double value;
  final List<CrmCommissionDomain> domains;
  final List<CrmProductCommission> productCommissions;
  final List<CrmProductCommission> serviceCommissions;
  final List<CrmProductCommission> licenseCommissions;
  final String tiersType;
  final String tiersFrequency;
  final List<CrmCommissionTierRange> tierRanges;
  final String currency;
  final bool partialCompensation;
  final String partialCompensationType;
  final String commissionTrigger;
  final List<CrmCommissionTierRange> commissionAfterTargetRanges;
  final bool isDeleted;
  final DateTime updatedAt;
  final String updatedBy;

  const CrmCommissionPackage({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.countries,
    required this.value,
    required this.updatedAt,
    this.compensationCategory = 'Commission',
    this.compensationType = 'Flat Rate',
    this.domains = const <CrmCommissionDomain>[],
    this.productCommissions = const <CrmProductCommission>[],
    this.serviceCommissions = const <CrmProductCommission>[],
    this.licenseCommissions = const <CrmProductCommission>[],
    this.tiersType = 'Count',
    this.tiersFrequency = 'Monthly',
    this.tierRanges = const <CrmCommissionTierRange>[],
    this.currency = '',
    this.partialCompensation = false,
    this.partialCompensationType = 'Default',
    this.commissionTrigger = '',
    this.commissionAfterTargetRanges = const <CrmCommissionTierRange>[],
    this.isDeleted = false,
    this.updatedBy = '',
  });

  CrmCommissionPackage copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    List<String>? countries,
    String? compensationCategory,
    String? compensationType,
    double? value,
    List<CrmCommissionDomain>? domains,
    List<CrmProductCommission>? productCommissions,
    List<CrmProductCommission>? serviceCommissions,
    List<CrmProductCommission>? licenseCommissions,
    String? tiersType,
    String? tiersFrequency,
    List<CrmCommissionTierRange>? tierRanges,
    String? currency,
    bool? partialCompensation,
    String? partialCompensationType,
    String? commissionTrigger,
    List<CrmCommissionTierRange>? commissionAfterTargetRanges,
    bool? isDeleted,
    DateTime? updatedAt,
    String? updatedBy,
  }) =>
      CrmCommissionPackage(
        id: id ?? this.id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        countries: countries ?? this.countries,
        compensationCategory: compensationCategory ?? this.compensationCategory,
        compensationType: compensationType ?? this.compensationType,
        value: value ?? this.value,
        domains: domains ?? this.domains,
        productCommissions: productCommissions ?? this.productCommissions,
        serviceCommissions: serviceCommissions ?? this.serviceCommissions,
        licenseCommissions: licenseCommissions ?? this.licenseCommissions,
        tiersType: tiersType ?? this.tiersType,
        tiersFrequency: tiersFrequency ?? this.tiersFrequency,
        tierRanges: tierRanges ?? this.tierRanges,
        currency: currency ?? this.currency,
        partialCompensation: partialCompensation ?? this.partialCompensation,
        partialCompensationType:
            partialCompensationType ?? this.partialCompensationType,
        commissionTrigger: commissionTrigger ?? this.commissionTrigger,
        commissionAfterTargetRanges:
            commissionAfterTargetRanges ?? this.commissionAfterTargetRanges,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
      );
}
