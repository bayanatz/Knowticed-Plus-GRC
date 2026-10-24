// ****************** FILE INFO ******************
// File Name: crm_templates_state.dart
// Purpose: State model for CRM controls templates listing
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';

class CrmTemplatesState {
  final List<CrmClientTypeModel> clientTypes;
  final List<CrmTemplateModel> templates;
  final List<CrmTemplateModel> filteredTemplates;
  final String selectedClientTypeId;
  final String selectedStatus;
  final String searchQuery;
  final String? selectedToolbarFilter;
  final String? selectedSort;
  final String? filterStatus;
  final DateTime? filterCreationDate;
  final String? filterFieldsCountRange;
  final String? filterCreatedBy;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const CrmTemplatesState({
    this.clientTypes = const [],
    this.templates = const [],
    this.filteredTemplates = const [],
    this.selectedClientTypeId = '',
    this.selectedStatus = 'All',
    this.searchQuery = '',
    this.selectedToolbarFilter,
    this.selectedSort,
    this.filterStatus,
    this.filterCreationDate,
    this.filterFieldsCountRange,
    this.filterCreatedBy,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isFilterActive =>
      (filterStatus != null &&
          filterStatus!.isNotEmpty &&
          filterStatus != 'All') ||
      filterCreationDate != null ||
      (filterFieldsCountRange != null &&
          filterFieldsCountRange!.isNotEmpty &&
          filterFieldsCountRange != 'All') ||
      (filterCreatedBy != null &&
          filterCreatedBy!.isNotEmpty &&
          filterCreatedBy != 'All');

  CrmTemplatesState copyWith({
    List<CrmClientTypeModel>? clientTypes,
    List<CrmTemplateModel>? templates,
    List<CrmTemplateModel>? filteredTemplates,
    String? selectedClientTypeId,
    String? selectedStatus,
    String? searchQuery,
    String? selectedToolbarFilter,
    String? selectedSort,
    String? filterStatus,
    DateTime? filterCreationDate,
    String? filterFieldsCountRange,
    String? filterCreatedBy,
    bool clearFilterStatus = false,
    bool clearFilterCreationDate = false,
    bool clearFilterFieldsCountRange = false,
    bool clearFilterCreatedBy = false,
    bool clearToolbarFilter = false,
    bool clearSort = false,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CrmTemplatesState(
      clientTypes: clientTypes ?? this.clientTypes,
      templates: templates ?? this.templates,
      filteredTemplates: filteredTemplates ?? this.filteredTemplates,
      selectedClientTypeId: selectedClientTypeId ?? this.selectedClientTypeId,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedToolbarFilter: clearToolbarFilter
          ? null
          : (selectedToolbarFilter ?? this.selectedToolbarFilter),
      selectedSort: clearSort ? null : (selectedSort ?? this.selectedSort),
      filterStatus:
          clearFilterStatus ? null : (filterStatus ?? this.filterStatus),
      filterCreationDate: clearFilterCreationDate
          ? null
          : (filterCreationDate ?? this.filterCreationDate),
      filterFieldsCountRange: clearFilterFieldsCountRange
          ? null
          : (filterFieldsCountRange ?? this.filterFieldsCountRange),
      filterCreatedBy: clearFilterCreatedBy
          ? null
          : (filterCreatedBy ?? this.filterCreatedBy),
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }
}
