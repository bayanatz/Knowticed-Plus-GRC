// ****************** FILE INFO ******************
// File Name: crm_client_deal_form_state.dart
// Purpose: Immutable state for the client deal creation wizard.
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/entities/crm_deal_pricing.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';

class CrmClientDealFormState {
  final bool isLoading;
  final bool isSubmitting;
  final bool isClientEligible;
  final int currentStep;
  final String? errorMessage;
  final String? successMessage;
  final List<CrmDealCategoryModel> categories;
  final List<CrmDealStageModel> stages;
  final List<CrmProductCategoryModel> productCategories;
  final List<CrmProductItemModel> products;
  final List<CrmServiceCategoryModel> serviceCategories;
  final List<CrmServiceItemModel> services;
  final List<CrmTeamMemberModel> employees;
  final List<CrmDiscountModel> discounts;
  final CrmDealCategoryModel? category;
  final CrmDealStageModel? initialStage;
  final CrmTeamMemberModel? employee;
  final String nameEn;
  final String nameAr;
  final String noteEn;
  final String noteAr;
  final String currency;
  final double? expectedValue;
  final double? likelihood;
  final DateTime? startDate;
  final DateTime? closeDate;
  final String? productCategoryId;
  final String? serviceCategoryId;
  final List<CrmDealLineDraft> productLines;
  final List<CrmDealLineDraft> serviceLines;
  final CrmDealPricingSummary pricing;

  const CrmClientDealFormState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isClientEligible = true,
    this.currentStep = 1,
    this.errorMessage,
    this.successMessage,
    this.categories = const [],
    this.stages = const [],
    this.productCategories = const [],
    this.products = const [],
    this.serviceCategories = const [],
    this.services = const [],
    this.employees = const [],
    this.discounts = const [],
    this.category,
    this.initialStage,
    this.employee,
    this.nameEn = '',
    this.nameAr = '',
    this.noteEn = '',
    this.noteAr = '',
    this.currency = 'EGP',
    this.expectedValue,
    this.likelihood,
    this.startDate,
    this.closeDate,
    this.productCategoryId,
    this.serviceCategoryId,
    this.productLines = const [],
    this.serviceLines = const [],
    this.pricing = const CrmDealPricingSummary(),
  });

  CrmClientDealFormState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isClientEligible,
    int? currentStep,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
    List<CrmDealCategoryModel>? categories,
    List<CrmDealStageModel>? stages,
    List<CrmProductCategoryModel>? productCategories,
    List<CrmProductItemModel>? products,
    List<CrmServiceCategoryModel>? serviceCategories,
    List<CrmServiceItemModel>? services,
    List<CrmTeamMemberModel>? employees,
    List<CrmDiscountModel>? discounts,
    CrmDealCategoryModel? category,
    bool clearCategory = false,
    CrmDealStageModel? initialStage,
    CrmTeamMemberModel? employee,
    bool clearEmployee = false,
    String? nameEn,
    String? nameAr,
    String? noteEn,
    String? noteAr,
    String? currency,
    double? expectedValue,
    bool clearExpectedValue = false,
    double? likelihood,
    bool clearLikelihood = false,
    DateTime? startDate,
    DateTime? closeDate,
    String? productCategoryId,
    bool clearProductCategory = false,
    String? serviceCategoryId,
    bool clearServiceCategory = false,
    List<CrmDealLineDraft>? productLines,
    List<CrmDealLineDraft>? serviceLines,
    CrmDealPricingSummary? pricing,
  }) =>
      CrmClientDealFormState(
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isClientEligible: isClientEligible ?? this.isClientEligible,
        currentStep: currentStep ?? this.currentStep,
        errorMessage:
            clearMessages ? null : (errorMessage ?? this.errorMessage),
        successMessage:
            clearMessages ? null : (successMessage ?? this.successMessage),
        categories: categories ?? this.categories,
        stages: stages ?? this.stages,
        productCategories: productCategories ?? this.productCategories,
        products: products ?? this.products,
        serviceCategories: serviceCategories ?? this.serviceCategories,
        services: services ?? this.services,
        employees: employees ?? this.employees,
        discounts: discounts ?? this.discounts,
        category: clearCategory ? null : (category ?? this.category),
        initialStage: initialStage ?? this.initialStage,
        employee: clearEmployee ? null : (employee ?? this.employee),
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        noteEn: noteEn ?? this.noteEn,
        noteAr: noteAr ?? this.noteAr,
        currency: currency ?? this.currency,
        expectedValue:
            clearExpectedValue ? null : (expectedValue ?? this.expectedValue),
        likelihood: clearLikelihood ? null : (likelihood ?? this.likelihood),
        startDate: startDate ?? this.startDate,
        closeDate: closeDate ?? this.closeDate,
        productCategoryId: clearProductCategory
            ? null
            : (productCategoryId ?? this.productCategoryId),
        serviceCategoryId: clearServiceCategory
            ? null
            : (serviceCategoryId ?? this.serviceCategoryId),
        productLines: productLines ?? this.productLines,
        serviceLines: serviceLines ?? this.serviceLines,
        pricing: pricing ?? this.pricing,
      );
}
