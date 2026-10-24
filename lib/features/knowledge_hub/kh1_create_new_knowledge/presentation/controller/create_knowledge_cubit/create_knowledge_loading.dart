/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_loading.dart
/// Description: Loading the hub documents, departments and one document.
/// Author: Amr Mesbah
/// Created at: 15/10/2026

part of '../create_knowledge_cubit.dart';

mixin CreateKnowledgeLoading on CreateKnowledgeCubitBase {
  void setCurrentUser({String? department, String? email}) {
    currentUserDepartment = department?.toLowerCase().trim();
    currentUserEmail = email?.toLowerCase().trim();
  }

  /// Loads the published documents the user may see.
  Future<void> fetchAllKnowledge({bool silent = false}) async {
    if (!silent) emit(FetchingKnowledgeLoadingState());
    try {
      final List<CreateKnowledgeModel> fetched = await _repository
          .fetchVisibleKnowledge(userDepartment: currentUserDepartment);
      unreadableDocuments = _repository.lastUnreadableCount;
      final DateTime now = DateTime.now();
      // KH-SUBMIT-03: the schedule decides visibility for every viewer.
      allKnowledge = fetched
          .where((k) => k.isLiveAt(now) && _hasAccessToDocument(k))
          .toList();
      filteredKnowledge = List.of(allKnowledge);
      if (silent) {
        // Live refresh: put the user's tab / inner tab / dialog filters /
        // search back on top of the fresh data instead of resetting them.
        final String? inner = selectedInnerCategory;
        if (inner != null) {
          await filterByInnerCategory(inner, selectedInnerIndex);
        } else {
          await applyFilters(
            documentType: selectedDocumentType,
            owningDepartment: owningDepartmentFromFilterDialog
                ? selectedOwningDepartment
                : null,
            owningStatus: selectedOwningStatus,
            publishFrom: selectedPublishFromDate,
            publishTo: selectedPublishToDate,
          );
        }
      } else {
        _emitFiltered();
      }
      _live.watchPaths([
        getBaseUrl(FirebaseCollections.createKnowledge),
      ], () => fetchAllKnowledge(silent: true));
    } catch (e) {
      khLog('fetchAllKnowledge failed: $e', name: 'CreateKnowledgeCubit');
      if (!silent) emit(FetchingKnowledgeErrorState(e.toString()));
    }
  }

  /// KH-CREATE-02: a restriction that cannot be read is a restriction.
  bool _hasAccessToDocument(CreateKnowledgeModel knowledge) {
    if (knowledge.departmentsUnreadable) return false;
    final List<String> limited =
        (CreateKnowledgeModel.decodeDepartments(
                  knowledge.limitedDepartments
                      .map((e) => e.toString())
                      .toList(),
                ) ??
                const <String>[])
            .map((e) => e.toLowerCase().trim())
            .toList();
    if (limited.isEmpty) return true;
    final String department = currentUserDepartment ?? '';
    return department.isNotEmpty && limited.contains(department);
  }

  Future<void> fetchAllDepartments() async {
    emit(FetchingDepartmentLoadingState());
    try {
      allDepartments = await _repository.fetchAllDepartments();
      emit(FetchingDepartmentSuccessState(allDepartments));
    } catch (e) {
      emit(FetchingDepartmentErrorState(e.toString()));
    }
  }

  Future<void> fetchKnowledgeByKnowledgeId(String knowledgeId) async {
    emit(FetchingKnowledgeByIdLoadingState());
    try {
      final CreateKnowledgeModel? knowledge = await _repository
          .fetchKnowledgeByKnowledgeId(knowledgeId);
      if (knowledge == null) {
        emit(FetchingKnowledgeByIdErrorState(knowledgeId));
        return;
      }
      currentKnowledgeDocument = knowledge;
      emit(FetchingKnowledgeByIdSuccessState(knowledge));
    } catch (e) {
      emit(FetchingKnowledgeByIdErrorState(e.toString()));
    }
  }

  /// The signed-in employee's supervisor e-mail, or null when none is known.
  Future<String?> getSupervisorEmail() async {
    final employee = people.signedInEmployee;
    if (employee == null) return null;
    final String direct = employee.supervisor ?? '';
    if (direct.isNotEmpty) return direct;
    try {
      final String? resolved = await _repository.getSupervisorEmail(
        employeeId: employee.id,
        departmentId: employee.departmentId,
      );
      return (resolved == null || resolved.isEmpty) ? null : resolved;
    } catch (e) {
      khLog('getSupervisorEmail failed: $e', name: 'CreateKnowledgeCubit');
      return null;
    }
  }
}
