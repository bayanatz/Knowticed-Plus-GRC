/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/controller
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_cubit.dart
/// Description: Loads, filters and saves Knowledge Hub documents.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_people.dart';

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/notifications/knowledge_hub_notification_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/domain/base_repository/create_knowledge_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/domain/entities/knowledge_draft.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_state.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

part 'create_knowledge_cubit/create_knowledge_loading.dart';
part 'create_knowledge_cubit/create_knowledge_filters.dart';
part 'create_knowledge_cubit/create_knowledge_submission.dart';
part 'create_knowledge_cubit/create_knowledge_tools.dart';

class CreateKnowledgeCubit extends CreateKnowledgeCubitBase
    with
        CreateKnowledgeLoading,
        CreateKnowledgeFilters,
        CreateKnowledgeSubmission,
        CreateKnowledgeTools {
  CreateKnowledgeCubit(super.repository, super.people);
}

/// State shared by the cubit's mixins.
abstract class CreateKnowledgeCubitBase extends Cubit<CreateKnowledgeState> {
  CreateKnowledgeCubitBase(this._repository, this.people)
    : super(CreateKnowledgeInitial());

  final CreateKnowledgeBaseRepository _repository;

  /// Signed-in employee + employee / department lookups (injected).
  final KhPeople people;

  /// Documents the hub could not read on the last load (KH-CREATE-21).
  int unreadableDocuments = 0;

  List<CreateKnowledgeModel> allKnowledge = [];
  List<DepartmentModelPro> allDepartments = [];
  List<CreateKnowledgeModel> filteredKnowledge = [];

  int selectedDepartmentIndex = 0;
  String? selectedDocumentType;

  /// Department chip filter; null means all departments.
  String? selectedOwningDepartment;

  /// (Moataz: the Filter button lit up after only picking a
  /// department tab): true only while [selectedOwningDepartment] was set by
  /// the Filter dialog's Apply. A department tab sets the same field but is
  /// not a dialog filter, so it leaves this false and the button stays plain.
  bool owningDepartmentFromFilterDialog = false;
  String searchQuery = '';
  int selectedInnerIndex = 0;
  String? selectedInnerCategory;
  String? selectedOwningStatus;

  /// Publish-date range from the filter dialog; either end may be null.
  DateTime? selectedPublishFromDate;
  DateTime? selectedPublishToDate;

  String? currentUserDepartment;
  String? currentUserEmail;
  CreateKnowledgeModel? currentKnowledgeDocument;
  Map<String, String> departmentIdToNameMap = {};

  @override
  void emit(CreateKnowledgeState state) {
    if (isClosed) return;
    super.emit(state);
  }

  final LiveRefresh _live = LiveRefresh();

  // Implemented in CreateKnowledgeFilters, used by CreateKnowledgeLoading.
  Future<void> filterByInnerCategory(String category, int index);
  Future<void> applyFilters({
    String? documentType,
    String? owningDepartment,
    String? owningStatus,
    DateTime? publishFrom,
    DateTime? publishTo,
  });

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  /// Emits the current [filteredKnowledge] as success or empty.
  void _emitFiltered() {
    if (filteredKnowledge.isEmpty) {
      emit(FetchingKnowledgeEmptyState());
    } else {
      emit(FetchingKnowledgeSuccessState(filteredKnowledge));
    }
  }
}
