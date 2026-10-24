// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reason_sets_state.dart
// Purpose: Immutable presentation state for CRM reason-set discovery
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:knowticed_plus/features/crm/crm15_reasons/domain/entities/crm_reason.dart';

class CrmReasonSetsState {
  final List<CrmReasonSetDefinition> reasonSets;
  final String query;
  final String? selectedSort;

  const CrmReasonSetsState({
    required this.reasonSets,
    this.query = '',
    this.selectedSort,
  });

  List<CrmReasonSetDefinition> get visibleReasonSets {
    final String normalizedQuery = query.trim().toLowerCase();
    final List<CrmReasonSetDefinition> visible = reasonSets
        .where((CrmReasonSetDefinition item) =>
            item.title.toLowerCase().contains(normalizedQuery))
        .toList();
    if (selectedSort == 'name_desc') {
      visible.sort((CrmReasonSetDefinition a, CrmReasonSetDefinition b) =>
          b.title.compareTo(a.title));
    } else if (selectedSort == 'name_asc') {
      visible.sort((CrmReasonSetDefinition a, CrmReasonSetDefinition b) =>
          a.title.compareTo(b.title));
    }
    return visible;
  }

  CrmReasonSetsState copyWith({String? query, String? selectedSort}) =>
      CrmReasonSetsState(
        reasonSets: reasonSets,
        query: query ?? this.query,
        selectedSort: selectedSort,
      );
}
