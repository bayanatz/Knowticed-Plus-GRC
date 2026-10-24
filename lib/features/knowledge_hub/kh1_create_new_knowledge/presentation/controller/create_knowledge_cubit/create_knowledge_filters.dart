/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_filters.dart
/// Description: Department, category, search and dialog filters of the hub.
/// Author: Amr Mesbah
/// Created at: 15/10/2026

part of '../create_knowledge_cubit.dart';

/// Stable values of the "Owner / Contributor" filters.
class KnowledgeOwnership {
  const KnowledgeOwnership._();
  static const String all = 'all';
  static const String owner = 'owner';
  static const String contributor = 'contributor';
}

mixin CreateKnowledgeFilters on CreateKnowledgeCubitBase {
  /// Documents of [department] (null = all departments).
  List<CreateKnowledgeModel> _inDepartment(String? department) {
    if (department == null || department.isEmpty) return List.of(allKnowledge);
    final String target = department.trim().toLowerCase();
    return allKnowledge
        .where((k) => k.currentOwningDepartment.trim().toLowerCase() == target)
        .toList();
  }

  bool _isOwner(CreateKnowledgeModel knowledge) {
    final String creator = knowledge.currentCreatedByEmail.toLowerCase().trim();
    final String me = (currentUserEmail ?? '').toLowerCase().trim();
    return creator.isNotEmpty && creator == me;
  }

  /// [department] null means "All".
  Future<void> filterByDepartment(String? department, int index) async {
    selectedDepartmentIndex = index;
    selectedOwningDepartment = department;
    owningDepartmentFromFilterDialog = false;
    emit(ChangedIndexSuccessState(index));
    selectedInnerIndex = 0;
    selectedInnerCategory = null;
    emit(ChangedInnerIndexSuccessState(0));
    filteredKnowledge = _inDepartment(department);
    if (searchQuery.isNotEmpty) _applySearch();
    _emitFiltered();
  }

  /// Number of documents in [department] (null = all departments).
  int getKnowledgeCountByDepartment(String? department) =>
      _inDepartment(department).length;

  Future<void> searchKnowledge(String query) async {
    searchQuery = query;
    if (query.isEmpty) {
      filteredKnowledge = _inDepartment(selectedOwningDepartment);
    } else {
      _applySearch();
    }
    _emitFiltered();
  }

  void _applySearch() {
    final String q = searchQuery.toLowerCase();
    filteredKnowledge = _inDepartment(selectedOwningDepartment)
        .where(
          (k) =>
              k.currentNameEnglish.toLowerCase().contains(q) ||
              k.currentNameArabic.toLowerCase().contains(q) ||
              k.currentDescriptionEnglish.toLowerCase().contains(q) ||
              k.currentDescriptionArabic.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<void> applyFilters({
    String? documentType,
    String? owningDepartment,
    String? owningStatus,
    DateTime? publishFrom,
    DateTime? publishTo,
  }) async {
    selectedDocumentType = documentType;
    final bool departmentFromDialog =
        owningDepartment != null && owningDepartment.isNotEmpty;
    // No department in the dialog keeps the department TAB's choice (it is
    // still the selected tab); clearing a dialog department shows all.
    if (departmentFromDialog) {
      selectedOwningDepartment = owningDepartment;
    } else if (owningDepartmentFromFilterDialog) {
      selectedOwningDepartment = null;
    }
    owningDepartmentFromFilterDialog = departmentFromDialog;
    selectedOwningStatus = owningStatus;
    selectedPublishFromDate = publishFrom;
    selectedPublishToDate = publishTo;

    List<CreateKnowledgeModel> result = _inDepartment(selectedOwningDepartment);

    if (documentType != null && documentType.isNotEmpty) {
      final String type = documentType.trim().toLowerCase();
      result = result
          .where(
            (k) => k.currentKnowledgeDocumentType.trim().toLowerCase() == type,
          )
          .toList();
    }

    if (owningStatus == KnowledgeOwnership.owner) {
      result = result.where(_isOwner).toList();
    } else if (owningStatus == KnowledgeOwnership.contributor) {
      result = result.where((k) => !_isOwner(k)).toList();
    }

    if (publishFrom != null || publishTo != null) {
      final DateTime? from = publishFrom == null
          ? null
          : DateTime(publishFrom.year, publishFrom.month, publishFrom.day);
      final DateTime? to = publishTo == null
          ? null
          : DateTime(
              publishTo.year,
              publishTo.month,
              publishTo.day,
              23,
              59,
              59,
              999,
            );
      result = result.where((k) {
        final DateTime? published = k.publishedAt;
        if (published == null) return false;
        if (from != null && published.isBefore(from)) return false;
        if (to != null && published.isAfter(to)) return false;
        return true;
      }).toList();
    }

    filteredKnowledge = result;
    if (searchQuery.isNotEmpty) {
      final String q = searchQuery.toLowerCase();
      filteredKnowledge = filteredKnowledge
          .where(
            (k) =>
                k.currentNameEnglish.toLowerCase().contains(q) ||
                k.currentNameArabic.toLowerCase().contains(q) ||
                k.currentDescriptionEnglish.toLowerCase().contains(q) ||
                k.currentDescriptionArabic.toLowerCase().contains(q),
          )
          .toList();
    }
    _emitFiltered();
  }

  Future<void> resetFilters() async {
    selectedDocumentType = null;
    selectedOwningDepartment = null;
    owningDepartmentFromFilterDialog = false;
    selectedOwningStatus = null;
    selectedPublishFromDate = null;
    selectedPublishToDate = null;
    searchQuery = '';
    selectedDepartmentIndex = 0;
    selectedInnerIndex = 0;
    selectedInnerCategory = null;
    filteredKnowledge = List.of(allKnowledge);
    emit(ChangedIndexSuccessState(0));
    emit(ChangedInnerIndexSuccessState(0));
    _emitFiltered();
  }

  void chooseIndex(int index) {
    selectedDepartmentIndex = index;
    emit(ChangedIndexSuccessState(index));
  }

  /// [category] is one of [KnowledgeOwnership].
  @override
  Future<void> filterByInnerCategory(String category, int index) async {
    selectedInnerIndex = index;
    selectedInnerCategory = category;
    emit(ChangedInnerIndexSuccessState(index));
    final List<CreateKnowledgeModel> base = _inDepartment(
      selectedOwningDepartment,
    );
    if (category == KnowledgeOwnership.owner) {
      filteredKnowledge = base.where(_isOwner).toList();
    } else if (category == KnowledgeOwnership.contributor) {
      filteredKnowledge = base.where((k) => !_isOwner(k)).toList();
    } else {
      filteredKnowledge = base;
    }
    if (searchQuery.isNotEmpty) {
      final String q = searchQuery.toLowerCase();
      filteredKnowledge = filteredKnowledge
          .where(
            (k) =>
                k.currentNameEnglish.toLowerCase().contains(q) ||
                k.currentNameArabic.toLowerCase().contains(q),
          )
          .toList();
    }
    _emitFiltered();
  }
}
