// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commission_package_model.dart
// Purpose: Firestore serialization for commission packages
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';

class CrmCommissionPackageModel {
  static const String _id = 'Id';
  static const String _nameEn = 'Name_En';
  static const String _nameAr = 'Name_Ar';
  static const String _countries = 'Countries';
  static const String _compensationCategory = 'Compensation_Category';
  static const String _compensationType = 'Compensation_Type';
  static const String _value = 'Value';
  static const String _domains = 'Domains';
  static const String _categoryIds = 'Category_Ids';
  static const String _productIds = 'Product_Ids';
  static const String _targetType = 'Target_Type';
  static const String _targetValue = 'Target_Value';
  static const String _frequency = 'Frequency';
  static const String _billingCycle = 'Billing_Cycle';
  static const String _targetCurrency = 'Target_Currency';
  static const String _applyOn = 'Apply_On';
  static const String _productCommissions = 'Product_Commissions';
  static const String _serviceCommissions = 'Service_Commissions';
  static const String _licenseCommissions = 'License_Commissions';
  static const String _tiersType = 'Tiers_Type';
  static const String _tiersFrequency = 'Tiers_Frequency';
  static const String _tierRanges = 'Tier_Ranges';
  static const String _currency = 'Currency';
  static const String _partialCompensation = 'Partial_Compensation';
  static const String _partialCompensationType = 'Partial_Compensation_Type';
  static const String _commissionTrigger = 'Commission_Trigger';
  static const String _commissionAfterTargetRanges =
      'Commission_After_Target_Ranges';
  static const String _from = 'From';
  static const String _to = 'To';
  static const String _isDeleted = 'Is_Deleted';
  static const String _updatedAt = 'Updated_At';
  static const String _updatedBy = 'Updated_By';

  final CrmCommissionPackage package;

  const CrmCommissionPackageModel(this.package);

  Map<String, dynamic> toMap() => <String, dynamic>{
        _id: package.id,
        _nameEn: package.nameEn,
        _nameAr: package.nameAr,
        _countries: package.countries,
        _compensationCategory: package.compensationCategory,
        _compensationType: package.compensationType,
        _value: package.value,
        _domains: package.domains
            .map((CrmCommissionDomain domain) => <String, dynamic>{
                  _categoryIds: domain.categoryIds,
                  _applyOn: domain.applyOn,
                  _productIds: domain.productIds,
                  _targetType: domain.targetType,
                  _targetValue: domain.targetValue,
                  _frequency: domain.frequency,
                  _billingCycle: domain.billingCycle,
                  _targetCurrency: domain.currency,
                })
            .toList(),
        _serviceCommissions: _commissionMaps(package.serviceCommissions),
        _licenseCommissions: _commissionMaps(package.licenseCommissions),
        _productCommissions: _commissionMaps(package.productCommissions),
        _tiersType: package.tiersType,
        _tiersFrequency: package.tiersFrequency,
        _tierRanges: _rangeMaps(package.tierRanges),
        _currency: package.currency,
        _partialCompensation: package.partialCompensation,
        _partialCompensationType: package.partialCompensationType,
        _commissionTrigger: package.commissionTrigger,
        _commissionAfterTargetRanges:
            _rangeMaps(package.commissionAfterTargetRanges),
        _isDeleted: package.isDeleted,
        _updatedAt: package.updatedAt.toIso8601String(),
        _updatedBy: package.updatedBy,
      };

  factory CrmCommissionPackageModel.fromMap(Map<String, dynamic> map) {
    final List<CrmCommissionDomain> domains =
        ((map[_domains] as List?) ?? const <dynamic>[])
            .whereType<Map>()
            .map((Map<dynamic, dynamic> item) => CrmCommissionDomain(
                  applyOn: (item[_applyOn] ?? 'Products').toString(),
                  categoryIds:
                      List<String>.from(item[_categoryIds] ?? const <String>[]),
                  productIds:
                      List<String>.from(item[_productIds] ?? const <String>[]),
                  targetType: (item[_targetType] ?? 'Count').toString(),
                  targetValue: (item[_targetValue] as num?)?.toDouble() ?? 0,
                  frequency: (item[_frequency] ?? 'Monthly').toString(),
                  billingCycle: (item[_billingCycle] ?? '').toString(),
                  currency: (item[_targetCurrency] ?? '').toString(),
                ))
            .toList();
    final List<CrmProductCommission> productCommissions =
        _commissionsFromMap(map, _productCommissions);
    final List<CrmCommissionTierRange> tierRanges =
        _rangesFromMap(map, _tierRanges);
    final List<CrmProductCommission> serviceCommissions =
        _commissionsFromMap(map, _serviceCommissions);
    final List<CrmProductCommission> licenseCommissions =
        _commissionsFromMap(map, _licenseCommissions);
    final List<CrmCommissionTierRange> commissionAfterTargetRanges =
        _rangesFromMap(map, _commissionAfterTargetRanges);
    return CrmCommissionPackageModel(
      CrmCommissionPackage(
        id: (map[_id] ?? '').toString(),
        nameEn: (map[_nameEn] ?? '').toString(),
        nameAr: (map[_nameAr] ?? '').toString(),
        countries: List<String>.from(map[_countries] ?? const <String>[]),
        compensationCategory:
            (map[_compensationCategory] ?? 'Commission').toString(),
        compensationType: (map[_compensationType] ?? 'Flat Rate').toString(),
        value: (map[_value] as num?)?.toDouble() ?? 0,
        domains: domains,
        productCommissions: productCommissions,
        serviceCommissions: serviceCommissions,
        licenseCommissions: licenseCommissions,
        tiersType: (map[_tiersType] ?? 'Count').toString(),
        tiersFrequency: (map[_tiersFrequency] ?? 'Monthly').toString(),
        tierRanges: tierRanges,
        currency: (map[_currency] ?? '').toString(),
        partialCompensation: map[_partialCompensation] == true,
        partialCompensationType:
            (map[_partialCompensationType] ?? 'Default').toString(),
        commissionTrigger: (map[_commissionTrigger] ?? '').toString(),
        commissionAfterTargetRanges: commissionAfterTargetRanges,
        isDeleted: map[_isDeleted] == true,
        updatedAt: DateTime.tryParse((map[_updatedAt] ?? '').toString()) ??
            DateTime.now(),
        updatedBy: (map[_updatedBy] ?? '').toString(),
      ),
    );
  }

  static List<Map<String, dynamic>> _commissionMaps(
    List<CrmProductCommission> commissions,
  ) =>
      commissions
          .map((CrmProductCommission item) => <String, dynamic>{
                _categoryIds: item.categoryId,
                _productIds: item.productId,
                _value: item.value,
              })
          .toList();

  static List<CrmProductCommission> _commissionsFromMap(
    Map<String, dynamic> map,
    String key,
  ) =>
      ((map[key] as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map((Map<dynamic, dynamic> item) => CrmProductCommission(
                categoryId: (item[_categoryIds] ?? '').toString(),
                productId: (item[_productIds] ?? '').toString(),
                value: (item[_value] as num?)?.toDouble() ?? 0,
              ))
          .toList();

  static List<Map<String, dynamic>> _rangeMaps(
    List<CrmCommissionTierRange> ranges,
  ) =>
      ranges
          .map((CrmCommissionTierRange item) => <String, dynamic>{
                _from: item.from,
                _to: item.to,
                _value: item.value,
              })
          .toList();

  static List<CrmCommissionTierRange> _rangesFromMap(
    Map<String, dynamic> map,
    String key,
  ) =>
      ((map[key] as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map((Map<dynamic, dynamic> item) => CrmCommissionTierRange(
                from: (item[_from] as num?)?.toDouble() ?? 0,
                to: (item[_to] as num?)?.toDouble() ?? 0,
                value: (item[_value] as num?)?.toDouble() ?? 0,
              ))
          .toList();
}
