// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commission_form_cubit.dart
// Purpose: Owns commission package validation and persistence
// Author: Mohand Adel
// Created At: 08/10/2026

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/interfaces/crm_commissions_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/controller/crm_commission_form_state.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/interfaces/crm_products_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/domain/interfaces/crm_services_base_repository.dart';

class CrmCommissionFormCubit extends Cubit<CrmCommissionFormState> {
  final CrmCommissionsBaseRepository _repository;
  final CrmProductsBaseRepository _productsRepository;
  final CrmServicesBaseRepository _servicesRepository;
  final CrmCommissionPackage? _existingPackage;
  StreamSubscription<Either<Failure, List<CrmProductCategoryModel>>>?
      _categoriesSubscription;
  StreamSubscription<Either<Failure, List<CrmProductItemModel>>>?
      _productsSubscription;
  StreamSubscription<Either<Failure, List<CrmServiceCategoryModel>>>?
      _serviceCategoriesSubscription;
  StreamSubscription<Either<Failure, List<CrmServiceItemModel>>>?
      _servicesSubscription;

  CrmCommissionFormCubit({
    required CrmCommissionsBaseRepository repository,
    required CrmProductsBaseRepository productsRepository,
    required CrmServicesBaseRepository servicesRepository,
    CrmCommissionPackage? package,
  })  : _repository = repository,
        _productsRepository = productsRepository,
        _servicesRepository = servicesRepository,
        _existingPackage = package,
        super(_initialState(package));

  static CrmCommissionFormState _initialState(CrmCommissionPackage? package) =>
      package == null
          ? const CrmCommissionFormState()
          : CrmCommissionFormState(
              nameEn: package.nameEn,
              nameAr: package.nameAr,
              countries: package.countries,
              value: package.value.toString(),
              compensationCategory: package.compensationCategory,
              compensationType: package.compensationType,
              domains: package.domains.isEmpty
                  ? const <CrmCommissionDomain>[CrmCommissionDomain()]
                  : package.domains,
              productCommissions: package.productCommissions,
              serviceCommissions: package.serviceCommissions,
              licenseCommissions: package.licenseCommissions,
              tiersType: package.tiersType,
              tiersFrequency: package.tiersFrequency,
              tierRanges: package.tierRanges.isEmpty
                  ? const <CrmCommissionTierRange>[CrmCommissionTierRange()]
                  : package.tierRanges,
              currency: package.currency,
              partialCompensation: package.partialCompensation,
              partialCompensationType: package.partialCompensationType,
              commissionTrigger: package.commissionTrigger,
              commissionAfterTargetRanges:
                  package.commissionAfterTargetRanges.isEmpty
                      ? const <CrmCommissionTierRange>[
                          CrmCommissionTierRange(),
                        ]
                      : package.commissionAfterTargetRanges,
            );

  bool get isEditing => _existingPackage != null;

  void init() {
    emit(state.copyWith(isLoadingOptions: true, clearError: true));
    _categoriesSubscription = _productsRepository.watchCategories().listen(
          (Either<Failure, List<CrmProductCategoryModel>> result) =>
              result.fold(
            (Failure failure) => _showOptionsError(failure.message),
            (List<CrmProductCategoryModel> categories) {
              if (!isClosed) {
                emit(state.copyWith(
                    categories: categories, isLoadingOptions: false));
              }
            },
          ),
        );
    _productsSubscription = _productsRepository.watchProducts().listen(
          (Either<Failure, List<CrmProductItemModel>> result) => result.fold(
            (Failure failure) => _showOptionsError(failure.message),
            (List<CrmProductItemModel> products) {
              if (!isClosed) emit(state.copyWith(products: products));
            },
          ),
        );
    _serviceCategoriesSubscription =
        _servicesRepository.watchCategories().listen(
              (Either<Failure, List<CrmServiceCategoryModel>> result) =>
                  result.fold(
                (Failure failure) => _showOptionsError(failure.message),
                (List<CrmServiceCategoryModel> categories) {
                  if (!isClosed) {
                    emit(state.copyWith(serviceCategories: categories));
                  }
                },
              ),
            );
    _servicesSubscription = _servicesRepository.watchServices().listen(
          (Either<Failure, List<CrmServiceItemModel>> result) => result.fold(
            (Failure failure) => _showOptionsError(failure.message),
            (List<CrmServiceItemModel> services) {
              if (!isClosed) emit(state.copyWith(services: services));
            },
          ),
        );
  }

  void updateNameEn(String value) => emit(state.copyWith(nameEn: value));
  void updateNameAr(String value) => emit(state.copyWith(nameAr: value));
  void updateCountries(List<String> values) =>
      emit(state.copyWith(countries: values));
  void updateValue(String value) => emit(state.copyWith(value: value));
  void updateCompensationCategory(String value) => emit(state.copyWith(
        compensationCategory: value,
        compensationType: value == 'Compensation' ? 'Amount' : 'Flat Rate',
        partialCompensation: value == 'Compensation',
      ));
  void updateCompensationType(String value) =>
      emit(state.copyWith(compensationType: value));
  void updateCurrency(String value) => emit(state.copyWith(currency: value));
  void updatePartialCompensation(bool value) =>
      emit(state.copyWith(partialCompensation: value));
  void updatePartialCompensationType(String value) =>
      emit(state.copyWith(partialCompensationType: value));
  void updateCommissionTrigger(String value) =>
      emit(state.copyWith(commissionTrigger: value));
  void updateTiersType(String value) => emit(state.copyWith(tiersType: value));
  void updateTiersFrequency(String value) =>
      emit(state.copyWith(tiersFrequency: value));
  void clearError() => emit(state.copyWith(clearError: true));

  void addDomain() {
    final List<CrmCommissionDomain> domains = <CrmCommissionDomain>[
      ...state.domains,
      const CrmCommissionDomain(),
    ];
    emit(state.copyWith(
      domains: domains,
      productCommissions: _synchronizedProductCommissions(domains),
      serviceCommissions: _synchronizedServiceCommissions(domains),
      licenseCommissions: _synchronizedLicenseCommissions(domains),
    ));
  }

  void removeDomain(int index) {
    if (state.domains.length <= 1) return;
    final List<CrmCommissionDomain> domains =
        List<CrmCommissionDomain>.from(state.domains)..removeAt(index);
    emit(state.copyWith(
      domains: domains,
      productCommissions: _synchronizedProductCommissions(domains),
      serviceCommissions: _synchronizedServiceCommissions(domains),
      licenseCommissions: _synchronizedLicenseCommissions(domains),
    ));
  }

  void updateDomainCategories(int index, List<String> values) => _updateDomain(
      index,
      state.domains[index]
          .copyWith(categoryIds: values, productIds: const <String>[]));
  void updateDomainApplyOn(int index, String value) => _updateDomain(
      index,
      state.domains[index].copyWith(
          applyOn: value,
          categoryIds: const <String>[],
          productIds: const <String>[],
          billingCycle: '',
          currency: ''));
  void updateDomainProducts(int index, List<String> values) =>
      _updateDomain(index, state.domains[index].copyWith(productIds: values));
  void updateDomainTargetType(int index, String value) =>
      _updateDomain(index, state.domains[index].copyWith(targetType: value));
  void updateDomainTargetValue(int index, String value) => _updateDomain(
        index,
        state.domains[index].copyWith(targetValue: double.tryParse(value) ?? 0),
      );
  void updateDomainFrequency(int index, String value) =>
      _updateDomain(index, state.domains[index].copyWith(frequency: value));
  void updateDomainBillingCycle(int index, String value) =>
      _updateDomain(index, state.domains[index].copyWith(billingCycle: value));
  void updateDomainCurrency(int index, String value) =>
      _updateDomain(index, state.domains[index].copyWith(currency: value));

  void addTierRange() =>
      emit(state.copyWith(tierRanges: <CrmCommissionTierRange>[
        ...state.tierRanges,
        const CrmCommissionTierRange(),
      ]));

  void removeTierRange(int index) {
    if (state.tierRanges.length <= 1) return;
    final List<CrmCommissionTierRange> ranges =
        List<CrmCommissionTierRange>.from(state.tierRanges)..removeAt(index);
    emit(state.copyWith(tierRanges: ranges));
  }

  void addCommissionAfterTargetRange() =>
      emit(state.copyWith(commissionAfterTargetRanges: <CrmCommissionTierRange>[
        ...state.commissionAfterTargetRanges,
        const CrmCommissionTierRange(),
      ]));

  void removeCommissionAfterTargetRange(int index) {
    if (state.commissionAfterTargetRanges.length <= 1) return;
    final List<CrmCommissionTierRange> ranges =
        List<CrmCommissionTierRange>.from(state.commissionAfterTargetRanges)
          ..removeAt(index);
    emit(state.copyWith(commissionAfterTargetRanges: ranges));
  }

  void updateTierRangeFrom(int index, String value) => _updateTierRange(index,
      state.tierRanges[index].copyWith(from: double.tryParse(value) ?? 0));
  void updateTierRangeTo(int index, String value) => _updateTierRange(
      index, state.tierRanges[index].copyWith(to: double.tryParse(value) ?? 0));
  void updateTierRangeValue(int index, String value) => _updateTierRange(index,
      state.tierRanges[index].copyWith(value: double.tryParse(value) ?? 0));
  void updateCommissionAfterTargetRangeFrom(int index, String value) =>
      _updateCommissionAfterTargetRange(
          index,
          state.commissionAfterTargetRanges[index]
              .copyWith(from: double.tryParse(value) ?? 0));
  void updateCommissionAfterTargetRangeTo(int index, String value) =>
      _updateCommissionAfterTargetRange(
          index,
          state.commissionAfterTargetRanges[index]
              .copyWith(to: double.tryParse(value) ?? 0));
  void updateCommissionAfterTargetRangeValue(int index, String value) =>
      _updateCommissionAfterTargetRange(
          index,
          state.commissionAfterTargetRanges[index]
              .copyWith(value: double.tryParse(value) ?? 0));
  void updateProductCommissionValue(int index, String value) {
    final List<CrmProductCommission> items =
        List<CrmProductCommission>.from(state.productCommissions)
          ..[index] = state.productCommissions[index]
              .copyWith(value: double.tryParse(value) ?? 0);
    emit(state.copyWith(productCommissions: items));
  }

  void updateServiceCommissionValue(int index, String value) {
    final List<CrmProductCommission> items =
        List<CrmProductCommission>.from(state.serviceCommissions)
          ..[index] = state.serviceCommissions[index]
              .copyWith(value: double.tryParse(value) ?? 0);
    emit(state.copyWith(serviceCommissions: items));
  }

  void updateLicenseCommissionValue(int index, String value) {
    final List<CrmProductCommission> items =
        List<CrmProductCommission>.from(state.licenseCommissions)
          ..[index] = state.licenseCommissions[index]
              .copyWith(value: double.tryParse(value) ?? 0);
    emit(state.copyWith(licenseCommissions: items));
  }

  List<CrmProductItemModel> productsForDomain(CrmCommissionDomain domain) =>
      domain.categoryIds.isEmpty
          ? state.products
          : state.products
              .where((CrmProductItemModel item) =>
                  domain.categoryIds.contains(item.categoryId))
              .toList();

  List<CrmServiceItemModel> servicesForDomain(CrmCommissionDomain domain) =>
      domain.categoryIds.isEmpty
          ? state.services
          : state.services
              .where((CrmServiceItemModel item) =>
                  domain.categoryIds.contains(item.categoryId))
              .toList();

  Future<bool> save() async {
    final String? validationMessage = _validationMessage;
    if (validationMessage != null) {
      emit(state.copyWith(errorMessage: validationMessage));
      return false;
    }
    final CrmCommissionPackage package = CrmCommissionPackage(
      id: _existingPackage?.id ?? '',
      nameEn: state.nameEn.trim(),
      nameAr: state.nameAr.trim(),
      countries: state.countries,
      compensationCategory: state.compensationCategory,
      value: double.tryParse(state.value.trim()) ?? 0,
      domains: state.domains,
      compensationType: state.compensationType,
      productCommissions: state.productCommissions,
      serviceCommissions: state.serviceCommissions,
      licenseCommissions: state.licenseCommissions,
      tiersType: state.tiersType,
      tiersFrequency: state.tiersFrequency,
      tierRanges: state.tierRanges,
      currency: state.currency,
      partialCompensation: state.partialCompensation,
      partialCompensationType: state.partialCompensationType,
      commissionTrigger: state.commissionTrigger,
      commissionAfterTargetRanges: state.commissionAfterTargetRanges,
      updatedAt: DateTime.now(),
      updatedBy: _currentUserEmail,
    );
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      if (isEditing) {
        await _repository.updatePackage(package);
      } else {
        await _repository.createPackage(package);
      }
      if (!isClosed) emit(state.copyWith(isSaving: false));
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      }
      return false;
    }
  }

  Future<bool> delete() async {
    final CrmCommissionPackage? package = _existingPackage;
    if (package == null) return false;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.deletePackage(
        package.copyWith(isDeleted: true, updatedAt: DateTime.now()),
      );
      if (!isClosed) emit(state.copyWith(isSaving: false));
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      }
      return false;
    }
  }

  String? get _validationMessage {
    if (state.nameEn.trim().isEmpty || state.nameAr.trim().isEmpty) {
      return 'Package name is required in English and Arabic.';
    }
    if (state.countries.isEmpty) return 'Choose at least one country.';
    if (state.compensationCategory == 'Commission' &&
        state.compensationType == 'Flat Rate' &&
        (double.tryParse(state.value.trim()) == null ||
            double.parse(state.value.trim()) <= 0)) {
      return 'Enter a valid flat-rate value.';
    }
    if (state.compensationCategory == 'Compensation' &&
        (double.tryParse(state.value.trim()) == null ||
            double.parse(state.value.trim()) <= 0)) {
      return 'Enter a valid compensation value.';
    }
    if (state.compensationCategory == 'Compensation' &&
        state.compensationType == 'Amount' &&
        state.currency.isEmpty) {
      return 'Choose a currency for the compensation amount.';
    }
    if (state.compensationCategory == 'Commission' &&
        state.compensationType == 'Tiers' &&
        state.domains.any((CrmCommissionDomain domain) =>
            domain.categoryIds.isEmpty ||
            (domain.applyOn == 'License' && domain.productIds.isEmpty))) {
      return 'Each tier domain requires at least one category.';
    }
    if ((state.compensationCategory == 'Compensation' ||
            state.compensationType != 'Tiers') &&
        state.domains.any((CrmCommissionDomain domain) =>
            domain.productIds.isEmpty ||
            (state.compensationType != 'Product Based' &&
                domain.targetValue <= 0))) {
      return 'Each domain requires selected items and a target value.';
    }
    if (state.domains.any((CrmCommissionDomain domain) =>
        domain.applyOn == 'License' &&
        (domain.billingCycle.isEmpty ||
            (domain.targetType == 'Amount' && domain.currency.isEmpty)))) {
      return 'Each license domain requires a billing cycle and amount currency.';
    }
    if (state.compensationCategory == 'Commission' &&
        state.compensationType == 'Product Based' &&
        ((state.productCommissions.isEmpty &&
                state.serviceCommissions.isEmpty &&
                state.licenseCommissions.isEmpty) ||
            state.productCommissions
                .any((CrmProductCommission item) => item.value <= 0) ||
            state.serviceCommissions
                .any((CrmProductCommission item) => item.value <= 0) ||
            state.licenseCommissions
                .any((CrmProductCommission item) => item.value <= 0))) {
      return 'Enter a commission value for every selected item.';
    }
    if (state.compensationCategory == 'Commission' &&
        state.compensationType == 'Tiers' &&
        state.tierRanges.any((CrmCommissionTierRange item) =>
            item.to <= item.from || item.value <= 0)) {
      return 'Each tier range needs a valid From, To, and commission value.';
    }
    if (state.compensationCategory == 'Compensation' &&
        state.partialCompensation) {
      if (state.commissionTrigger.isEmpty) {
        return 'Choose a commission trigger.';
      }
      if (state.commissionAfterTargetRanges.any((CrmCommissionTierRange item) =>
          item.to <= item.from || item.value <= 0)) {
        return 'Each after-target range needs a valid From, To, and value.';
      }
    }
    return null;
  }

  void _updateDomain(int index, CrmCommissionDomain domain) {
    final List<CrmCommissionDomain> domains =
        List<CrmCommissionDomain>.from(state.domains)..[index] = domain;
    emit(state.copyWith(
      domains: domains,
      productCommissions: _synchronizedProductCommissions(domains),
      serviceCommissions: _synchronizedServiceCommissions(domains),
      licenseCommissions: _synchronizedLicenseCommissions(domains),
    ));
  }

  List<CrmProductCommission> _synchronizedProductCommissions(
      List<CrmCommissionDomain> domains) {
    final Map<String, CrmProductCommission> existing =
        <String, CrmProductCommission>{
      for (final CrmProductCommission item in state.productCommissions)
        item.productId: item,
    };
    return domains
        .where((CrmCommissionDomain domain) => domain.applyOn == 'Products')
        .expand((CrmCommissionDomain domain) => domain.productIds)
        .toSet()
        .map((String productId) {
      final CrmProductItemModel? product = state.products
          .cast<CrmProductItemModel?>()
          .firstWhere((CrmProductItemModel? item) => item?.id == productId,
              orElse: () => null);
      return existing[productId] ??
          CrmProductCommission(
            categoryId: product?.categoryId ?? '',
            productId: productId,
          );
    }).toList();
  }

  List<CrmProductCommission> _synchronizedServiceCommissions(
      List<CrmCommissionDomain> domains) {
    final Map<String, CrmProductCommission> existing =
        <String, CrmProductCommission>{
      for (final CrmProductCommission item in state.serviceCommissions)
        item.productId: item,
    };
    return domains
        .where((CrmCommissionDomain domain) => domain.applyOn == 'Services')
        .expand((CrmCommissionDomain domain) => domain.productIds)
        .toSet()
        .map((String serviceId) {
      final CrmServiceItemModel? service = state.services
          .cast<CrmServiceItemModel?>()
          .firstWhere((CrmServiceItemModel? item) => item?.id == serviceId,
              orElse: () => null);
      return existing[serviceId] ??
          CrmProductCommission(
            categoryId: service?.categoryId ?? '',
            productId: serviceId,
          );
    }).toList();
  }

  List<CrmProductCommission> _synchronizedLicenseCommissions(
      List<CrmCommissionDomain> domains) {
    final Map<String, CrmProductCommission> existing =
        <String, CrmProductCommission>{
      for (final CrmProductCommission item in state.licenseCommissions)
        item.productId: item,
    };
    return domains
        .where((CrmCommissionDomain domain) => domain.applyOn == 'License')
        .expand((CrmCommissionDomain domain) => domain.productIds)
        .toSet()
        .map((String licenseId) {
      final CrmProductItemModel? license = state.products
          .cast<CrmProductItemModel?>()
          .firstWhere((CrmProductItemModel? item) => item?.id == licenseId,
              orElse: () => null);
      return existing[licenseId] ??
          CrmProductCommission(
            categoryId: license?.categoryId ?? '',
            productId: licenseId,
          );
    }).toList();
  }

  void _updateTierRange(int index, CrmCommissionTierRange range) {
    final List<CrmCommissionTierRange> ranges =
        List<CrmCommissionTierRange>.from(state.tierRanges)..[index] = range;
    emit(state.copyWith(tierRanges: ranges));
  }

  void _updateCommissionAfterTargetRange(
    int index,
    CrmCommissionTierRange range,
  ) {
    final List<CrmCommissionTierRange> ranges =
        List<CrmCommissionTierRange>.from(state.commissionAfterTargetRanges)
          ..[index] = range;
    emit(state.copyWith(commissionAfterTargetRanges: ranges));
  }

  void _showOptionsError(String message) {
    if (!isClosed) {
      emit(state.copyWith(isLoadingOptions: false, errorMessage: message));
    }
  }

  String get _currentUserEmail {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final String? email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim().toLowerCase();
      }
    }
    return 'system';
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    _productsSubscription?.cancel();
    _serviceCategoriesSubscription?.cancel();
    _servicesSubscription?.cancel();
    return super.close();
  }
}
