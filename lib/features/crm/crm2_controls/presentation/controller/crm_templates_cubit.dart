// ****************** FILE INFO ******************
// File Name: crm_templates_cubit.dart
// Purpose: Cubit for CRM controls templates listing, filtering, sorting and draft creation
// Author: Mohand Adel
// Created At: 05/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';

import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_templates_state.dart';

class CrmTemplatesCubit extends Cubit<CrmTemplatesState> {
  final CrmControlsBaseRepository repository;
  StreamSubscription<Either<Failure, List<CrmClientTypeModel>>>?
      _clientTypesSubscription;
  StreamSubscription<Either<Failure, List<CrmTemplateModel>>>?
      _templatesSubscription;

  CrmTemplatesCubit({CrmControlsBaseRepository? repository})
      : repository = repository ?? Get.find<CrmControlsBaseRepository>(),
        super(const CrmTemplatesState());

  /// Function Name: init
  ///
  /// Purpose: Initializes repository defaults and sets up live stream subscriptions
  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final Either<Failure, void> defaults =
        await repository.ensureDefaults(userEmail: _currentUserEmail);
    if (defaults.isLeft()) {
      defaults.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (_) {},
      );
      return;
    }
    final Either<Failure, void> syncAll =
        await repository.syncDefaultsForAllTemplates(
      userEmail: _currentUserEmail,
    );
    if (syncAll.isLeft()) {
      syncAll.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (_) {},
      );
      return;
    }
    _watchClientTypes();
    _watchTemplates();
  }

  /// Function Name: selectClientType
  ///
  /// Purpose: Selects the active client type tab and recalculates visible templates
  ///
  /// Parameters:
  /// - clientTypeId: The selected client type identifier
  void selectClientType(String clientTypeId) {
    emit(
      state.copyWith(
        selectedClientTypeId: clientTypeId,
        filteredTemplates: _filterTemplates(
          templates: state.templates,
          clientTypeId: clientTypeId,
          status: state.selectedStatus,
          query: state.searchQuery,
          filterStatus: state.filterStatus,
          filterCreationDate: state.filterCreationDate,
          filterFieldsCountRange: state.filterFieldsCountRange,
          filterCreatedBy: state.filterCreatedBy,
        ),
        clearMessages: true,
      ),
    );
  }

  /// Function Name: selectStatus
  ///
  /// Purpose: Filters templates by top counter chip status
  ///
  /// Parameters:
  /// - status: The status string (e.g. All, Active, Inactive, Deleted)
  void selectStatus(String status) {
    emit(
      state.copyWith(
        selectedStatus: status,
        filteredTemplates: _filterTemplates(
          templates: state.templates,
          clientTypeId: state.selectedClientTypeId,
          status: status,
          query: state.searchQuery,
          filterStatus: state.filterStatus,
          filterCreationDate: state.filterCreationDate,
          filterFieldsCountRange: state.filterFieldsCountRange,
          filterCreatedBy: state.filterCreatedBy,
        ),
        clearMessages: true,
      ),
    );
  }

  /// Function Name: search
  ///
  /// Purpose: Performs real-time search query filtering on templates
  ///
  /// Parameters:
  /// - query: Text entered by the user in the search field
  void search(String query) {
    final String normalizedQuery = query.trim();
    emit(
      state.copyWith(
        searchQuery: normalizedQuery,
        filteredTemplates: _filterTemplates(
          templates: state.templates,
          clientTypeId: state.selectedClientTypeId,
          status: state.selectedStatus,
          query: normalizedQuery,
          filterStatus: state.filterStatus,
          filterCreationDate: state.filterCreationDate,
          filterFieldsCountRange: state.filterFieldsCountRange,
          filterCreatedBy: state.filterCreatedBy,
        ),
        clearMessages: true,
      ),
    );
  }

  /// Function Name: applyFilter
  ///
  /// Purpose: Applies criteria from the Filter dialog and recalculates filtered list
  ///
  /// Parameters:
  /// - status: Filtered status
  /// - creationDate: Filtered creation date
  /// - fieldsCountRange: Filtered fields count range
  /// - createdBy: Filtered creator name
  void applyFilter({
    String? status,
    DateTime? creationDate,
    String? fieldsCountRange,
    String? createdBy,
  }) {
    emit(
      state.copyWith(
        filterStatus: status,
        clearFilterStatus: status == null,
        filterCreationDate: creationDate,
        clearFilterCreationDate: creationDate == null,
        filterFieldsCountRange: fieldsCountRange,
        clearFilterFieldsCountRange: fieldsCountRange == null,
        filterCreatedBy: createdBy,
        clearFilterCreatedBy: createdBy == null,
        filteredTemplates: _filterTemplates(
          templates: state.templates,
          clientTypeId: state.selectedClientTypeId,
          status: state.selectedStatus,
          query: state.searchQuery,
          filterStatus: status,
          filterCreationDate: creationDate,
          filterFieldsCountRange: fieldsCountRange,
          filterCreatedBy: createdBy,
        ),
        clearMessages: true,
      ),
    );
  }

  /// Function Name: resetFilter
  ///
  /// Purpose: Clears all filter dialog criteria
  void resetFilter() {
    emit(
      state.copyWith(
        clearFilterStatus: true,
        clearFilterCreationDate: true,
        clearFilterFieldsCountRange: true,
        clearFilterCreatedBy: true,
        filteredTemplates: _filterTemplates(
          templates: state.templates,
          clientTypeId: state.selectedClientTypeId,
          status: state.selectedStatus,
          query: state.searchQuery,
        ),
        clearMessages: true,
      ),
    );
  }

  /// Function Name: availableCreators
  ///
  /// Purpose: Returns distinct creator names extracted from loaded templates
  List<String> get availableCreators {
    final Set<String> creators = <String>{};
    for (final CrmTemplateModel template in state.templates) {
      final String author = template.audit.createdBy.isNotEmpty
          ? template.audit.createdBy
          : template.audit.updatedBy;
      if (author.trim().isNotEmpty) {
        creators.add(FormatHelper.formatEmailToName(author.trim()));
      }
    }
    return <String>['All', ...creators.toList()..sort()];
  }

  /// Function Name: setToolbarFilter
  ///
  /// Purpose: Sets optional toolbar filter selection
  ///
  /// Parameters:
  /// - filter: Selected toolbar filter string
  void setToolbarFilter(String? filter) {
    emit(filter == null
        ? state.copyWith(clearToolbarFilter: true)
        : state.copyWith(selectedToolbarFilter: filter));
  }

  /// Function Name: setSort
  ///
  /// Purpose: Sets the active sort option ('Newest' or 'Oldest')
  ///
  /// Parameters:
  /// - sort: The sort option name
  void setSort(String? sort) {
    emit(sort == null
        ? state.copyWith(clearSort: true)
        : state.copyWith(selectedSort: sort));
  }

  /// Function Name: visibleTemplates
  ///
  /// Purpose: Returns the filtered templates list sorted according to selectedSort
  List<CrmTemplateModel> visibleTemplates() {
    final List<CrmTemplateModel> result =
        List<CrmTemplateModel>.from(state.filteredTemplates);
    switch (state.selectedSort) {
      case 'Newest':
        result.sort((a, b) => b.audit.createdAt.compareTo(a.audit.createdAt));
      case 'Oldest':
        result.sort((a, b) => a.audit.createdAt.compareTo(b.audit.createdAt));
    }
    return result;
  }

  /// Function Name: createTemplateDraft
  ///
  /// Purpose: Creates a new template draft in the repository
  ///
  /// Parameters:
  /// - nameEn: Template name in English
  /// - nameAr: Template name in Arabic
  Future<CrmTemplateModel?> createTemplateDraft({
    required String nameEn,
    required String nameAr,
  }) async {
    if (nameEn.trim().isEmpty || nameAr.trim().isEmpty) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Template English and Arabic names are required',
        ),
      );
      return null;
    }
    if (state.selectedClientTypeId.isEmpty) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Select client type before creating a template',
        ),
      );
      return null;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, CrmTemplateModel> result =
        await repository.createTemplateDraft(
      clientTypeId: state.selectedClientTypeId,
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      userEmail: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(
          state.copyWith(isSaving: false, errorMessage: failure.errMessage),
        );
        return null;
      },
      (template) {
        emit(
          state.copyWith(isSaving: false, successMessage: 'created'),
        );
        return template;
      },
    );
  }

  /// Function Name: clearMessages
  ///
  /// Purpose: Clears transient error and success messages from state
  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  /// Function Name: _watchClientTypes
  ///
  /// Purpose: Subscribes to client types stream from repository
  void _watchClientTypes() {
    _clientTypesSubscription?.cancel();
    _clientTypesSubscription = repository.watchClientTypes().listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (items) {
          final String selectedId = state.selectedClientTypeId.isNotEmpty
              ? state.selectedClientTypeId
              : (items.isEmpty ? '' : items.first.id);
          emit(
            state.copyWith(
              clientTypes: items,
              selectedClientTypeId: selectedId,
              filteredTemplates: _filterTemplates(
                templates: state.templates,
                clientTypeId: selectedId,
                status: state.selectedStatus,
                query: state.searchQuery,
                filterStatus: state.filterStatus,
                filterCreationDate: state.filterCreationDate,
                filterFieldsCountRange: state.filterFieldsCountRange,
                filterCreatedBy: state.filterCreatedBy,
              ),
              isLoading: false,
              clearMessages: true,
            ),
          );
        },
      );
    });
  }

  /// Function Name: _watchTemplates
  ///
  /// Purpose: Subscribes to templates stream from repository
  void _watchTemplates() {
    _templatesSubscription?.cancel();
    _templatesSubscription = repository.watchTemplates().listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (templates) => emit(
          state.copyWith(
            templates: templates,
            filteredTemplates: _filterTemplates(
              templates: templates,
              clientTypeId: state.selectedClientTypeId,
              status: state.selectedStatus,
              query: state.searchQuery,
              filterStatus: state.filterStatus,
              filterCreationDate: state.filterCreationDate,
              filterFieldsCountRange: state.filterFieldsCountRange,
              filterCreatedBy: state.filterCreatedBy,
            ),
            isLoading: false,
            clearMessages: true,
          ),
        ),
      );
    });
  }

  /// Function Name: _filterTemplates
  ///
  /// Purpose: Filters list of templates based on all active criteria
  List<CrmTemplateModel> _filterTemplates({
    required List<CrmTemplateModel> templates,
    required String clientTypeId,
    required String status,
    required String query,
    String? filterStatus,
    DateTime? filterCreationDate,
    String? filterFieldsCountRange,
    String? filterCreatedBy,
  }) {
    final String normalizedQuery = query.trim().toLowerCase();
    return templates.where((template) {
      final bool matchesClientType =
          clientTypeId.isEmpty || template.clientTypeId == clientTypeId;

      final String templateStatus = template.status.toLowerCase();
      final String effectiveStatus = (filterStatus != null &&
              filterStatus.isNotEmpty &&
              filterStatus != 'All')
          ? filterStatus.toLowerCase()
          : status.toLowerCase();

      final bool matchesStatus = effectiveStatus == 'all' ||
          templateStatus == effectiveStatus ||
          (effectiveStatus == 'inactive' && templateStatus == 'draft');

      final bool matchesQuery = normalizedQuery.isEmpty ||
          template.nameEn.toLowerCase().contains(normalizedQuery) ||
          template.nameAr.toLowerCase().contains(normalizedQuery);

      bool matchesCreationDate = true;
      if (filterCreationDate != null) {
        final DateTime createdAt = template.audit.createdAt;
        matchesCreationDate = createdAt.year == filterCreationDate.year &&
            createdAt.month == filterCreationDate.month &&
            createdAt.day == filterCreationDate.day;
      }

      bool matchesFieldsCount = true;
      if (filterFieldsCountRange != null &&
          filterFieldsCountRange.isNotEmpty &&
          filterFieldsCountRange != 'All') {
        final int count = template.fieldCount;
        switch (filterFieldsCountRange) {
          case '1 - 5':
            matchesFieldsCount = count >= 1 && count <= 5;
          case '6 - 10':
            matchesFieldsCount = count >= 6 && count <= 10;
          case '11 - 20':
            matchesFieldsCount = count >= 11 && count <= 20;
          case '20+':
            matchesFieldsCount = count > 20;
          default:
            matchesFieldsCount = true;
        }
      }

      bool matchesCreatedBy = true;
      if (filterCreatedBy != null &&
          filterCreatedBy.isNotEmpty &&
          filterCreatedBy != 'All') {
        final String author = template.audit.createdBy.isNotEmpty
            ? template.audit.createdBy
            : template.audit.updatedBy;
        final String formattedAuthor =
            FormatHelper.formatEmailToName(author).toLowerCase();
        matchesCreatedBy =
            formattedAuthor == filterCreatedBy.trim().toLowerCase() ||
                author.toLowerCase() == filterCreatedBy.trim().toLowerCase();
      }

      return matchesClientType &&
          matchesStatus &&
          matchesQuery &&
          matchesCreationDate &&
          matchesFieldsCount &&
          matchesCreatedBy;
    }).toList();
  }

  String get _currentUserEmail {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final String? email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim().toLowerCase();
      }
    }
    final String? fallbackEmail = Constant.emailUser;
    if (fallbackEmail != null && fallbackEmail.trim().isNotEmpty) {
      return fallbackEmail.trim().toLowerCase();
    }
    return 'system';
  }

  @override
  Future<void> close() async {
    await _clientTypesSubscription?.cancel();
    await _templatesSubscription?.cancel();
    return super.close();
  }
}
