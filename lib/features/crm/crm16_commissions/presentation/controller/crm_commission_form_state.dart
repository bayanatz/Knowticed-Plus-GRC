// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commission_form_state.dart
// Purpose: Immutable editable state for a commission package
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';

class CrmCommissionFormState {
  final String nameEn;
  final String nameAr;
  final List<String> countries;
  final String value;
  final String compensationCategory;
  final String compensationType;
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
  final List<CrmProductCategoryModel> categories;
  final List<CrmProductItemModel> products;
  final List<CrmServiceCategoryModel> serviceCategories;
  final List<CrmServiceItemModel> services;
  final bool isLoadingOptions;
  final bool isSaving;
  final String? errorMessage;

  const CrmCommissionFormState({
    this.nameEn = '',
    this.nameAr = '',
    this.countries = const <String>[],
    this.value = '',
    this.compensationCategory = 'Commission',
    this.compensationType = 'Flat Rate',
    this.domains = const <CrmCommissionDomain>[CrmCommissionDomain()],
    this.productCommissions = const <CrmProductCommission>[],
    this.serviceCommissions = const <CrmProductCommission>[],
    this.licenseCommissions = const <CrmProductCommission>[],
    this.tiersType = 'Count',
    this.tiersFrequency = 'Monthly',
    this.tierRanges = const <CrmCommissionTierRange>[
      CrmCommissionTierRange(),
    ],
    this.currency = '',
    this.partialCompensation = false,
    this.partialCompensationType = 'Default',
    this.commissionTrigger = '',
    this.commissionAfterTargetRanges = const <CrmCommissionTierRange>[
      CrmCommissionTierRange(),
    ],
    this.categories = const <CrmProductCategoryModel>[],
    this.products = const <CrmProductItemModel>[],
    this.serviceCategories = const <CrmServiceCategoryModel>[],
    this.services = const <CrmServiceItemModel>[],
    this.isLoadingOptions = false,
    this.isSaving = false,
    this.errorMessage,
  });

  CrmCommissionFormState copyWith({
    String? nameEn,
    String? nameAr,
    List<String>? countries,
    String? value,
    String? compensationCategory,
    String? compensationType,
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
    List<CrmProductCategoryModel>? categories,
    List<CrmProductItemModel>? products,
    List<CrmServiceCategoryModel>? serviceCategories,
    List<CrmServiceItemModel>? services,
    bool? isLoadingOptions,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CrmCommissionFormState(
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        countries: countries ?? this.countries,
        value: value ?? this.value,
        compensationCategory: compensationCategory ?? this.compensationCategory,
        compensationType: compensationType ?? this.compensationType,
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
        categories: categories ?? this.categories,
        products: products ?? this.products,
        serviceCategories: serviceCategories ?? this.serviceCategories,
        services: services ?? this.services,
        isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
        isSaving: isSaving ?? this.isSaving,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
