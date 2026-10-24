// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_types_state.dart
// Purpose: Immutable state for the Team Types list
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm18_team_types/domain/entities/crm_team_type.dart';

/// Holds list filtering, loading, and error state for Team Types.
class CrmTeamTypesState {
  final List<CrmTeamType> items;
  final String query;
  final String status;
  final bool isLoading;
  final String? errorMessage;

  const CrmTeamTypesState({
    this.items = const <CrmTeamType>[],
    this.query = '',
    this.status = 'All',
    this.isLoading = false,
    this.errorMessage,
  });

  int get activeCount =>
      items.where((CrmTeamType item) => item.isActive).length;
  int get inactiveCount => items.length - activeCount;
  List<CrmTeamType> get visibleItems {
    final String normalized = query.trim().toLowerCase();
    return items
        .where(
          (CrmTeamType item) =>
              (status == 'All' ||
                  (status == 'Active' ? item.isActive : !item.isActive)) &&
              (item.nameEn.toLowerCase().contains(normalized) ||
                  item.nameAr.toLowerCase().contains(normalized)),
        )
        .toList();
  }

  /// Returns a state copy with selected fields changed.
  CrmTeamTypesState copyWith({
    List<CrmTeamType>? items,
    String? query,
    String? status,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CrmTeamTypesState(
        items: items ?? this.items,
        query: query ?? this.query,
        status: status ?? this.status,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
