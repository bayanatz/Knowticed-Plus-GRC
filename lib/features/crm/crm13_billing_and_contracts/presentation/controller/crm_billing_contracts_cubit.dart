// ****************** FILE INFO ******************
// File Name: crm_billing_contracts_cubit.dart
// Purpose: Cubit for CRM Billing & Contracts state management and operations
// Author: Mohand Adel
// Created At: 06/10/2026

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/models/crm_billing_contract_model.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/domain/interfaces/crm_billing_contracts_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/presentation/controller/crm_billing_contracts_state.dart';

class CrmBillingContractsCubit extends Cubit<CrmBillingContractsState> {
  final CrmBillingContractsBaseRepository repository;
  StreamSubscription<Either<Failure, List<CrmBillingContractModel>>>?
      _subscription;

  CrmBillingContractsCubit({
    CrmBillingContractsBaseRepository? repository,
  })  : repository =
            repository ?? Get.find<CrmBillingContractsBaseRepository>(),
        super(const CrmBillingContractsState());

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

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    await _subscription?.cancel();

    _subscription = repository
        .watchBillingContracts()
        .listen((Either<Failure, List<CrmBillingContractModel>> result) {
      result.fold(
        (Failure failure) => emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.errMessage,
          ),
        ),
        (List<CrmBillingContractModel> items) => emit(
          state.copyWith(
            items: items,
            filteredItems: _applyFilters(
              items: items,
              query: state.searchQuery,
              statusFilter: state.selectedStatusFilter,
              sort: state.selectedSort,
            ),
            isLoading: false,
            clearMessages: true,
          ),
        ),
      );
    });
  }

  void search(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filteredItems: _applyFilters(
        items: state.items,
        query: query,
        statusFilter: state.selectedStatusFilter,
        sort: state.selectedSort,
      ),
    ));
  }

  void setStatusFilter(String status) {
    emit(state.copyWith(
      selectedStatusFilter: status,
      filteredItems: _applyFilters(
        items: state.items,
        query: state.searchQuery,
        statusFilter: status,
        sort: state.selectedSort,
      ),
    ));
  }

  void setSort(String? sort) {
    final String s = sort ?? 'name_asc';
    emit(state.copyWith(
      selectedSort: s,
      filteredItems: _applyFilters(
        items: state.items,
        query: state.searchQuery,
        statusFilter: state.selectedStatusFilter,
        sort: s,
      ),
    ));
  }

  Future<bool> createBillingContract(CrmBillingContractModel item) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, CrmBillingContractModel> result =
        await repository.createBillingContract(
      item: item,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: failure.errMessage,
        ));
        return false;
      },
      (CrmBillingContractModel created) {
        emit(state.copyWith(
          isSaving: false,
          successMessage: 'Saved successfully',
        ));
        return true;
      },
    );
  }

  Future<bool> updateBillingContract(CrmBillingContractModel item) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.updateBillingContract(
      item: item,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: failure.errMessage,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          isSaving: false,
          successMessage: 'Updated successfully',
        ));
        return true;
      },
    );
  }

  Future<String?> uploadContentFile({
    required String controlId,
    required String field,
    required List<int> bytes,
    required String fileName,
  }) async {
    final Either<Failure, String> result = await repository.uploadContentFile(
      controlId: controlId,
      field: field,
      bytes: bytes,
      fileName: fileName,
    );
    return result.fold(
      (Failure failure) {
        emit(state.copyWith(errorMessage: failure.errMessage));
        return null;
      },
      (String url) => url,
    );
  }

  Future<bool> deleteBillingContract(String id) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.deleteBillingContract(
      id: id,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: failure.errMessage,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          isSaving: false,
          successMessage: 'Deleted successfully',
        ));
        return true;
      },
    );
  }

  Future<bool> toggleStatus(String id, bool isActive) async {
    final Either<Failure, void> result =
        await repository.toggleBillingContractStatus(
      id: id,
      isActive: isActive,
      changedBy: _currentUserEmail,
    );

    return result.isRight();
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  List<CrmBillingContractModel> _applyFilters({
    required List<CrmBillingContractModel> items,
    required String query,
    required String statusFilter,
    required String sort,
  }) {
    List<CrmBillingContractModel> filtered =
        List<CrmBillingContractModel>.from(items);

    if (statusFilter != 'all' && statusFilter != 'All') {
      final bool activeExpected = statusFilter.toLowerCase() == 'active';
      filtered = filtered
          .where((item) => activeExpected ? item.isActive : !item.isActive)
          .toList();
    }

    if (query.trim().isNotEmpty) {
      final String q = query.trim().toLowerCase();
      filtered = filtered.where((item) {
        return item.nameEn.toLowerCase().contains(q) ||
            item.nameAr.toLowerCase().contains(q) ||
            item.code.toLowerCase().contains(q) ||
            item.billingCycle.toLowerCase().contains(q) ||
            item.paymentTerms.toLowerCase().contains(q);
      }).toList();
    }

    switch (sort) {
      case 'name_desc':
        filtered.sort((a, b) => b.nameEn.compareTo(a.nameEn));
        break;
      case 'newest':
        filtered.sort((a, b) {
          final DateTime aDate = a.createdAt ?? DateTime(2000);
          final DateTime bDate = b.createdAt ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
        break;
      case 'oldest':
        filtered.sort((a, b) {
          final DateTime aDate = a.createdAt ?? DateTime(2000);
          final DateTime bDate = b.createdAt ?? DateTime(2000);
          return aDate.compareTo(bDate);
        });
        break;
      case 'name_asc':
      default:
        filtered.sort((a, b) => a.nameEn.compareTo(b.nameEn));
        break;
    }

    return filtered;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
