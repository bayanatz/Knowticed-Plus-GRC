// ****************** FILE INFO ******************
// File Name: crm_quotes_state.dart
// Purpose: State definition for Deal Quotes feature
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';

class CrmQuotesState {
  final bool isLoading;
  final List<CrmQuoteModel> allQuotes;
  final List<CrmQuoteModel> filteredQuotes;
  final CrmQuoteStatus selectedStatus;
  final String searchQuery;
  final bool isGridView;
  final bool isCompareMode;
  final Set<String> selectedQuoteIds;
  final String? errorMessage;

  const CrmQuotesState({
    this.isLoading = false,
    this.allQuotes = const <CrmQuoteModel>[],
    this.filteredQuotes = const <CrmQuoteModel>[],
    this.selectedStatus = CrmQuoteStatus.all,
    this.searchQuery = '',
    this.isGridView = true,
    this.isCompareMode = false,
    this.selectedQuoteIds = const <String>{},
    this.errorMessage,
  });

  int get allCount => allQuotes.length;
  int get pendingCount =>
      allQuotes.where((q) => q.clientStatus == CrmQuoteStatus.pending).length;
  int get approvedCount =>
      allQuotes.where((q) => q.clientStatus == CrmQuoteStatus.approved).length;
  int get adjustmentCount => allQuotes
      .where((q) => q.clientStatus == CrmQuoteStatus.adjustment)
      .length;
  int get rejectCount =>
      allQuotes.where((q) => q.clientStatus == CrmQuoteStatus.reject).length;
  int get expiredCount =>
      allQuotes.where((q) => q.clientStatus == CrmQuoteStatus.expired).length;

  CrmQuotesState copyWith({
    bool? isLoading,
    List<CrmQuoteModel>? allQuotes,
    List<CrmQuoteModel>? filteredQuotes,
    CrmQuoteStatus? selectedStatus,
    String? searchQuery,
    bool? isGridView,
    bool? isCompareMode,
    Set<String>? selectedQuoteIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CrmQuotesState(
      isLoading: isLoading ?? this.isLoading,
      allQuotes: allQuotes ?? this.allQuotes,
      filteredQuotes: filteredQuotes ?? this.filteredQuotes,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      isGridView: isGridView ?? this.isGridView,
      isCompareMode: isCompareMode ?? this.isCompareMode,
      selectedQuoteIds: selectedQuoteIds ?? this.selectedQuoteIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
