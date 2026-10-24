// ****************** FILE INFO ******************
// File Name: crm_billing_contracts_state.dart
// Purpose: State definition for CRM Billing and Contracts management
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/models/crm_billing_contract_model.dart';

class CrmBillingContractsState {
  final bool isLoading;
  final bool isSaving;
  final List<CrmBillingContractModel> items;
  final List<CrmBillingContractModel> filteredItems;
  final String selectedStatusFilter;
  final String selectedSort;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const CrmBillingContractsState({
    this.isLoading = false,
    this.isSaving = false,
    this.items = const <CrmBillingContractModel>[],
    this.filteredItems = const <CrmBillingContractModel>[],
    this.selectedStatusFilter = 'All',
    this.selectedSort = 'name_asc',
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  CrmBillingContractsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<CrmBillingContractModel>? items,
    List<CrmBillingContractModel>? filteredItems,
    String? selectedStatusFilter,
    String? selectedSort,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CrmBillingContractsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      selectedSort: selectedSort ?? this.selectedSort,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}
