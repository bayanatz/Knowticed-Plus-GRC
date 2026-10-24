// ****************** FILE INFO ******************
// File Name: crm_client_deal_form_cubit.dart
// Purpose: Orchestrates client deal creation using CRM control masters.
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/base_repository/crm_clients_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/interfaces/crm_teams_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_stage_checklist_item_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/entities/crm_deal_pricing.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_client_deals_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_deals_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/use_cases/crm_deal_pricing_calculator.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/interfaces/crm_products_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/domain/interfaces/crm_discounts_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/domain/interfaces/crm_services_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_deal_form_state.dart';

class CrmClientDealFormCubit extends Cubit<CrmClientDealFormState> {
  final CrmClientDealsBaseRepository _clientDeals;
  final CrmClientsBaseRepository _clients;
  final CrmDealsBaseRepository _deals;
  final CrmProductsBaseRepository _products;
  final CrmServicesBaseRepository _services;
  final CrmDiscountsBaseRepository _discounts;
  final CrmTeamsBaseRepository _teams;
  final CrmDealPricingCalculator _calculator;
  String _clientId = '';

  CrmClientDealFormCubit(
      {CrmClientDealsBaseRepository? clientDeals,
      CrmClientsBaseRepository? clients,
      CrmDealsBaseRepository? deals,
      CrmProductsBaseRepository? products,
      CrmServicesBaseRepository? services,
      CrmDiscountsBaseRepository? discounts,
      CrmTeamsBaseRepository? teams,
      CrmDealPricingCalculator? calculator})
      : _clientDeals = clientDeals ?? Get.find<CrmClientDealsBaseRepository>(),
        _clients = clients ?? Get.find<CrmClientsBaseRepository>(),
        _deals = deals ?? Get.find<CrmDealsBaseRepository>(),
        _products = products ?? Get.find<CrmProductsBaseRepository>(),
        _services = services ?? Get.find<CrmServicesBaseRepository>(),
        _discounts = discounts ?? Get.find<CrmDiscountsBaseRepository>(),
        _teams = teams ?? Get.find<CrmTeamsBaseRepository>(),
        _calculator = calculator ?? const CrmDealPricingCalculator(),
        super(const CrmClientDealFormState());

  Future<void> init({required String clientId}) async {
    _clientId = clientId;
    _emit(state.copyWith(isLoading: true, clearMessages: true));
    final Either<Failure, CrmClientRecordModel?> clientResult =
        await _clients.watchClientRecord(recordId: clientId).first;
    final CrmClientRecordModel? client = clientResult.fold(
        (Failure _) => null, (CrmClientRecordModel? value) => value);
    if (client == null || client.isBlacklisted) {
      _emit(state.copyWith(
          isLoading: false,
          isClientEligible: false,
          errorMessage: client == null
              ? 'Client record was not found.'
              : 'Blacklisted clients cannot create deals.'));
      return;
    }
    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      _deals.watchCategories().first,
      _deals.watchStages().first,
      _products.watchCategories().first,
      _products.watchProducts().first,
      _services.watchCategories().first,
      _services.watchServices().first,
      _discounts.getDiscounts(),
      _teams.getAvailableEmployees(),
    ]);
    String? failure;
    T values<T>(int index) {
      final Either<Failure, T> result = results[index] as Either<Failure, T>;
      return result.fold((Failure value) {
        failure ??= value.message;
        return throw StateError(value.message);
      }, (T value) => value);
    }

    try {
      final List<CrmDealCategoryModel> categories =
          values<List<CrmDealCategoryModel>>(0)
              .where((CrmDealCategoryModel value) =>
                  value.isActive && !value.isDeleted)
              .toList();
      final List<CrmDealStageModel> stages = values<List<CrmDealStageModel>>(1)
          .where(
              (CrmDealStageModel value) => value.isActive && !value.isDeleted)
          .toList()
        ..sort((CrmDealStageModel a, CrmDealStageModel b) =>
            a.order.compareTo(b.order));
      final productCategories = values(2)
          .where((dynamic value) => value.isActive && !value.isDeleted)
          .toList();
      final List<CrmProductItemModel> products =
          values<List<CrmProductItemModel>>(3)
              .where((CrmProductItemModel value) =>
                  value.isActive && !value.isDeleted)
              .toList();
      final serviceCategories = values(4)
          .where((dynamic value) => value.isActive && !value.isDeleted)
          .toList();
      final List<CrmServiceItemModel> services =
          values<List<CrmServiceItemModel>>(5)
              .where((CrmServiceItemModel value) =>
                  value.isActive && !value.isDeleted)
              .toList();
      final List<CrmDiscountModel> discounts = values<List<CrmDiscountModel>>(6)
          .where((CrmDiscountModel value) => value.isActive && !value.isDeleted)
          .toList();
      final employees = values(7);
      _emit(state.copyWith(
          isLoading: false,
          categories: categories,
          stages: stages,
          productCategories: productCategories,
          products: products,
          serviceCategories: serviceCategories,
          services: services,
          employees: employees,
          discounts: discounts,
          initialStage: stages.isEmpty ? null : stages.first));
    } catch (_) {
      _emit(state.copyWith(
          isLoading: false,
          errorMessage: failure ?? 'Unable to load deal controls.'));
    }
  }

  void updateDetails(
          {String? nameEn,
          String? nameAr,
          String? noteEn,
          String? noteAr,
          String? currency,
          double? expectedValue,
          double? likelihood,
          DateTime? startDate,
          DateTime? closeDate}) =>
      _emit(state.copyWith(
          nameEn: nameEn,
          nameAr: nameAr,
          noteEn: noteEn,
          noteAr: noteAr,
          currency: currency,
          expectedValue: expectedValue,
          likelihood: likelihood,
          startDate: startDate,
          closeDate: closeDate,
          clearMessages: true));
  void selectCategory(CrmDealCategoryModel? category) => _emit(
      state.copyWith(category: category, clearCategory: category == null));
  void selectEmployee(dynamic employee) => _emit(
      state.copyWith(employee: employee, clearEmployee: employee == null));
  void selectProductCategory(String? id) => _emit(
      state.copyWith(productCategoryId: id, clearProductCategory: id == null));
  void selectServiceCategory(String? id) => _emit(
      state.copyWith(serviceCategoryId: id, clearServiceCategory: id == null));
  List<CrmProductItemModel> get visibleProducts => state.products
      .where((CrmProductItemModel item) =>
          state.productCategoryId == null ||
          item.categoryId == state.productCategoryId)
      .toList();
  List<CrmServiceItemModel> get visibleServices => state.services
      .where((CrmServiceItemModel item) =>
          state.serviceCategoryId == null ||
          item.categoryId == state.serviceCategoryId)
      .toList();

  void addProduct(CrmProductItemModel item) => _replaceLines(
      products: <CrmDealLineDraft>[...state.productLines, _fromProduct(item)]);
  void addService(CrmServiceItemModel item) => _replaceLines(
      services: <CrmDealLineDraft>[...state.serviceLines, _fromService(item)]);

  CrmDealLineDraft? productDraftFor({
    required String? productId,
    required double? quantity,
  }) {
    if (productId == null || quantity == null || quantity <= 0) return null;
    for (final CrmProductItemModel product in state.products) {
      if (product.id == productId) {
        return _fromProduct(product).copyWith(quantity: quantity);
      }
    }
    return null;
  }

  CrmDealLineDraft? serviceDraftFor({required String? serviceId}) {
    if (serviceId == null) return null;
    for (final CrmServiceItemModel service in state.services) {
      if (service.id == serviceId) return _fromService(service);
    }
    return null;
  }

  void removeProduct(int index) => _replaceLines(
      products: List<CrmDealLineDraft>.from(state.productLines)
        ..removeAt(index));
  void removeService(int index) => _replaceLines(
      services: List<CrmDealLineDraft>.from(state.serviceLines)
        ..removeAt(index));
  void updateProductLine(int index, {double? quantity, double? unitPrice}) {
    final lines = List<CrmDealLineDraft>.from(state.productLines);
    lines[index] =
        lines[index].copyWith(quantity: quantity, unitPrice: unitPrice);
    _replaceLines(products: lines);
  }

  void updateServiceLine(int index, {double? quantity, double? unitPrice}) {
    final lines = List<CrmDealLineDraft>.from(state.serviceLines);
    lines[index] =
        lines[index].copyWith(quantity: quantity, unitPrice: unitPrice);
    _replaceLines(services: lines);
  }

  void goToStep(int step) {
    if (step >= 1 && step <= 4) {
      _emit(state.copyWith(currentStep: step, clearMessages: true));
    }
  }

  void nextStep() {
    if (_validStep(state.currentStep)) {
      goToStep(state.currentStep + 1);
    } else {
      _emit(state.copyWith(errorMessage: _stepError(state.currentStep)));
    }
  }

  void previousStep() => goToStep(state.currentStep - 1);

  void setDraftLines({
    required List<CrmDealLineDraft> products,
    required List<CrmDealLineDraft> services,
  }) =>
      _replaceLines(products: products, services: services);

  Future<void> submit() async {
    if (_clientId.isEmpty || !_validStep(1)) {
      _emit(state.copyWith(
          errorMessage: 'Complete all required deal details before saving.'));
      return;
    }
    if (state.initialStage == null) {
      _emit(
          state.copyWith(errorMessage: 'No active deal stage is configured.'));
      return;
    }
    if (state.productLines.isEmpty && state.serviceLines.isEmpty) {
      _emit(state.copyWith(
          errorMessage:
              'Select at least one product or service from Controls.'));
      return;
    }

    final CrmDealStageModel activeStage = state.initialStage!;
    final CrmDealCategoryModel activeCategory = state.category!;
    final CrmTeamMemberModel activeEmployee = state.employee!;

    _emit(state.copyWith(
      isSubmitting: true,
      clearMessages: true,
      category: activeCategory,
      initialStage: activeStage,
      employee: activeEmployee,
    ));

    final String userEmail = Get.isRegistered<MainCoreEmployeeController>()
        ? Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? ''
        : '';

    final DateTime start = state.startDate ?? DateTime.now();
    final DateTime close =
        state.closeDate ?? start.add(const Duration(days: 30));
    final double expVal = state.expectedValue ?? state.pricing.grandTotal;

    final CrmClientDealRecordModel draft = CrmClientDealRecordModel(
      id: '',
      clientId: _clientId,
      categoryId: activeCategory.id,
      categoryNameEn: activeCategory.nameEn,
      categoryNameAr: activeCategory.nameAr,
      currentStageId: activeStage.id,
      stageNameEn: activeStage.nameEn,
      stageNameAr: activeStage.nameAr,
      assignedEmployeeId: activeEmployee.id,
      assignedEmployeeName: activeEmployee.name,
      nameEn: state.nameEn.trim().isNotEmpty
          ? state.nameEn.trim()
          : state.nameAr.trim(),
      nameAr: state.nameAr.trim().isNotEmpty
          ? state.nameAr.trim()
          : state.nameEn.trim(),
      noteEn: state.noteEn.trim(),
      noteAr: state.noteAr.trim(),
      currency: state.currency.isNotEmpty ? state.currency : 'EGP',
      expectedValue: expVal,
      likelihood: state.likelihood ?? activeStage.probability.toDouble(),
      startDate: start,
      closeDate: close,
      status: 'active',
      subtotal: state.pricing.subtotal,
      discountTotal: state.pricing.discountTotal,
      taxTotal: state.pricing.taxTotal,
      grandTotal:
          state.pricing.grandTotal > 0 ? state.pricing.grandTotal : expVal,
      productLines: state.productLines
          .map((CrmDealLineDraft line) => _lineMap(line, 'Product'))
          .toList(),
      serviceLines: state.serviceLines
          .map((CrmDealLineDraft line) => _lineMap(line, 'Service'))
          .toList(),
      checklist: activeStage.checklistItems
          .map<Map<String, dynamic>>(
            (CrmStageChecklistItemModel item) => <String, dynamic>{
              'Stage_Id': activeStage.id,
              'Stage_Name_En': activeStage.nameEn,
              'Stage_Name_Ar': activeStage.nameAr,
              'Name_En': item.nameEn,
              'Name_Ar': item.nameAr,
              'Completed': false,
            },
          )
          .toList(),
      createdAt: DateTime.now(),
      createdBy: userEmail,
    );

    final Either<Failure, CrmClientDealRecordModel> result =
        await _clientDeals.createClientDeal(deal: draft);

    result.fold(
      (Failure failure) => _emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        ),
      ),
      (CrmClientDealRecordModel _) => _emit(
        state.copyWith(
          isSubmitting: false,
          successMessage: 'Deal created successfully.',
        ),
      ),
    );
  }

  CrmDealLineDraft _fromProduct(CrmProductItemModel item) {
    final CrmDiscountModel? discount =
        _discountFor(item.id, item.categoryId, 'product', item.discountRule);
    String catEn = item.categoryNameEn;
    String catAr = item.categoryNameAr;
    if (catEn.isEmpty && item.categoryId.isNotEmpty) {
      for (final dynamic cat in state.productCategories) {
        if (cat.id == item.categoryId) {
          catEn = cat.nameEn;
          catAr = cat.nameAr;
          break;
        }
      }
    }
    return CrmDealLineDraft(
      itemId: item.id,
      itemNameEn: item.nameEn,
      itemNameAr: item.nameAr,
      categoryId: item.categoryId,
      categoryNameEn: catEn.isNotEmpty ? catEn : 'Software',
      categoryNameAr: catAr.isNotEmpty ? catAr : 'برمجيات',
      quantity: 1,
      unitPrice: item.unitPrice,
      taxRate: item.tax,
      discountValue: discount?.discountValue ?? 0,
      discountType: discount?.discountType ?? 'percentage',
      discountRuleId: discount?.id ?? '',
    );
  }

  CrmDealLineDraft _fromService(CrmServiceItemModel item) {
    final CrmDiscountModel? discount =
        _discountFor(item.id, item.categoryId, 'service', item.discountRule);
    String catEn = item.categoryNameEn;
    String catAr = item.categoryNameAr;
    if (catEn.isEmpty && item.categoryId.isNotEmpty) {
      for (final dynamic cat in state.serviceCategories) {
        if (cat.id == item.categoryId) {
          catEn = cat.nameEn;
          catAr = cat.nameAr;
          break;
        }
      }
    }
    return CrmDealLineDraft(
      itemId: item.id,
      itemNameEn: item.nameEn,
      itemNameAr: item.nameAr,
      categoryId: item.categoryId,
      categoryNameEn: catEn.isNotEmpty ? catEn : 'Services',
      categoryNameAr: catAr.isNotEmpty ? catAr : 'خدمات',
      quantity: 1,
      unitPrice: item.unitPrice,
      taxRate: item.tax,
      discountValue: discount?.discountValue ?? 0,
      discountType: discount?.discountType ?? 'percentage',
      discountRuleId: discount?.id ?? '',
    );
  }

  CrmDiscountModel? _discountFor(
    String itemId,
    String categoryId,
    String type,
    String configuredDiscountRuleId,
  ) {
    if (configuredDiscountRuleId.isNotEmpty) {
      for (final CrmDiscountModel discount in state.discounts) {
        if (discount.id == configuredDiscountRuleId ||
            discount.nameEn == configuredDiscountRuleId ||
            discount.nameAr == configuredDiscountRuleId) {
          return discount;
        }
      }
    }
    for (final CrmDiscountModel discount in state.discounts) {
      final String scope = discount.type.toLowerCase();
      final bool scopeMatches = scope == 'both' || scope == type;
      final bool categoryMatches =
          discount.categoryId.isEmpty || discount.categoryId == categoryId;
      final bool itemMatches =
          discount.productId.isEmpty || discount.productId == itemId;
      final bool quantityMatches = discount.minQuantity <= 1 &&
          (discount.maxQuantity == 0 || discount.maxQuantity >= 1);
      if (scopeMatches && categoryMatches && itemMatches && quantityMatches) {
        return discount;
      }
    }
    return null;
  }

  void _replaceLines(
      {List<CrmDealLineDraft>? products, List<CrmDealLineDraft>? services}) {
    final productLines = products ?? state.productLines;
    final serviceLines = services ?? state.serviceLines;
    _emit(state.copyWith(
        productLines: productLines,
        serviceLines: serviceLines,
        pricing: _calculator
            .calculate(<CrmDealLineDraft>[...productLines, ...serviceLines])));
  }

  Map<String, dynamic> _lineMap(CrmDealLineDraft line, String type) {
    final totals = _calculator.calculateLine(line);
    return <String, dynamic>{
      'Item_Id': line.itemId,
      'Name_En': line.itemNameEn,
      'Name_Ar': line.itemNameAr,
      '${type}_Name_En': line.itemNameEn,
      '${type}_Name_Ar': line.itemNameAr,
      'Category_Id': line.categoryId,
      'Category_Name_En': line.categoryNameEn,
      'Category_Name_Ar': line.categoryNameAr,
      'Quantity': line.quantity,
      'Unit_Price': line.unitPrice,
      'Tax_Rate': line.taxRate,
      'Discount_Value': line.discountValue,
      'Discount_Type': line.discountType,
      'Discount_Rule_Id': line.discountRuleId,
      'Subtotal': totals.subtotal,
      'Discount': totals.discount,
      'Tax': totals.tax,
      'Total': totals.total
    };
  }

  bool _validStep(int step) =>
      step != 1 ||
      (state.category != null &&
          state.employee != null &&
          state.nameEn.trim().isNotEmpty &&
          state.nameAr.trim().isNotEmpty &&
          state.expectedValue != null &&
          state.expectedValue! >= 0 &&
          state.startDate != null &&
          state.closeDate != null &&
          !state.closeDate!.isBefore(state.startDate!));
  String _stepError(int step) => step == 1
      ? 'Complete all required deal details before continuing.'
      : 'Complete the current step before continuing.';
  void _emit(CrmClientDealFormState value) {
    if (!isClosed) emit(value);
  }
}
