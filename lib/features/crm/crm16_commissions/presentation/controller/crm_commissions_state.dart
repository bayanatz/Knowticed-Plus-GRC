// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commissions_state.dart
// Purpose: Immutable state for commission package list controls
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';

class CrmCommissionsState {
  final List<CrmCommissionPackage> packages;
  final String query;
  final String category;
  final String? selectedSort;
  final bool isLoading;
  final String? errorMessage;

  const CrmCommissionsState({
    this.packages = const <CrmCommissionPackage>[],
    this.query = '',
    this.category = 'All',
    this.selectedSort,
    this.isLoading = false,
    this.errorMessage,
  });

  List<CrmCommissionPackage> get visiblePackages {
    final String normalized = query.trim().toLowerCase();
    final List<CrmCommissionPackage> result = packages
        .where((CrmCommissionPackage item) =>
            (category == 'All' || item.compensationCategory == category) &&
            item.nameEn.toLowerCase().contains(normalized))
        .toList();
    if (selectedSort == 'name_asc') {
      result.sort((CrmCommissionPackage a, CrmCommissionPackage b) =>
          a.nameEn.compareTo(b.nameEn));
    } else if (selectedSort == 'name_desc') {
      result.sort((CrmCommissionPackage a, CrmCommissionPackage b) =>
          b.nameEn.compareTo(a.nameEn));
    }
    return result;
  }

  CrmCommissionsState copyWith({
    List<CrmCommissionPackage>? packages,
    String? query,
    String? category,
    String? selectedSort,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CrmCommissionsState(
        packages: packages ?? this.packages,
        query: query ?? this.query,
        category: category ?? this.category,
        selectedSort: selectedSort ?? this.selectedSort,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
