// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_state.dart
// Purpose: Immutable state for CRM conversion-stage management
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:knowticed_plus/features/crm/crm14_convert/domain/entities/crm_convert_stage.dart';

class CrmConvertState {
  final List<CrmConvertStage> stages;
  final String searchQuery;
  final String selectedStatus;
  final String? selectedSort;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const CrmConvertState({
    this.stages = const <CrmConvertStage>[],
    this.searchQuery = '',
    this.selectedStatus = 'All',
    this.selectedSort,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  int get activeCount =>
      stages.where((CrmConvertStage item) => item.isActive).length;
  int get inactiveCount => stages.length - activeCount;

  List<CrmConvertStage> get visibleStages {
    Iterable<CrmConvertStage> result = stages.where((CrmConvertStage item) {
      final String query = searchQuery.toLowerCase();
      final bool matchingQuery = query.isEmpty ||
          item.nameEn.toLowerCase().contains(query) ||
          item.nameAr.toLowerCase().contains(query);
      final bool matchingStatus = selectedStatus == 'All' ||
          (selectedStatus == 'Active' && item.isActive) ||
          (selectedStatus == 'Inactive' && !item.isActive);
      return matchingQuery && matchingStatus;
    });
    final List<CrmConvertStage> sorted = result.toList();
    switch (selectedSort) {
      case 'name_asc':
        sorted.sort((CrmConvertStage a, CrmConvertStage b) =>
            a.nameEn.compareTo(b.nameEn));
      case 'name_desc':
        sorted.sort((CrmConvertStage a, CrmConvertStage b) =>
            b.nameEn.compareTo(a.nameEn));
      case 'date_desc':
        sorted.sort((CrmConvertStage a, CrmConvertStage b) =>
            b.updatedAt.compareTo(a.updatedAt));
      case 'date_asc':
        sorted.sort((CrmConvertStage a, CrmConvertStage b) =>
            a.updatedAt.compareTo(b.updatedAt));
      default:
        sorted.sort((CrmConvertStage a, CrmConvertStage b) =>
            a.order.compareTo(b.order));
    }
    return sorted;
  }

  CrmConvertState copyWith({
    List<CrmConvertStage>? stages,
    String? searchQuery,
    String? selectedStatus,
    String? selectedSort,
    bool clearSort = false,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CrmConvertState(
        stages: stages ?? this.stages,
        searchQuery: searchQuery ?? this.searchQuery,
        selectedStatus: selectedStatus ?? this.selectedStatus,
        selectedSort: clearSort ? null : selectedSort ?? this.selectedSort,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
