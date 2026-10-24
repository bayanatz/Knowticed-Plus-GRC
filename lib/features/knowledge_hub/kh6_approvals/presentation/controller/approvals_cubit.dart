/// Module: knowledge_hub/kh6_approvals/presentation/controller
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_cubit.dart
/// Description: Contains all the functions to view Submitted files with filtering.
/// Author: Amr Mesbah
/// Created at: 14/10/2025
/// Updated: Supervisor-based approval system
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_people.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/notifications/knowledge_hub_notification_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/approvals_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/domain/base_repository/approvals_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';

part 'approvals_cubit.part.1.dart';
part 'approvals_cubit.part.2.dart';
part 'approvals_cubit.part.1/approvals_cubit_part1_methods.dart';

class ApprovalsCubit extends ApprovalsCubitBase
    with ApprovalsCubitPart1, ApprovalsCubitPart1Methods2, ApprovalsCubitPart2 {
  ApprovalsCubit(super.repository, super.people);
}

/// The state shared by the approvals mixins.
abstract class ApprovalsCubitBase extends Cubit<ApprovalsStates> {
  final ApprovalsBaseRepository _repository;

  /// Signed-in employee + employee / department lookups (injected).
  final KhPeople people;

  int selectedStatusIndex = 0;

  int selectedInnerStatusIndex = 0;

  String? selectedDocumentType;

  String? selectedStatus; // Upper category status

  /// Whether the FILTER DIALOG has anything applied — what lights the Filter
  /// button up.
  ///
  bool dialogFilterActive = false;
  String? selectedInnerStatus; // Inner status filter
  DateTime? selectedStartDate;

  DateTime? selectedEndDate;

  /// The department picked in the Approvals dropdown (null = all). Kept so
  /// every other filter (tab, search, dialog, refresh) re-applies it.
  String? selectedDepartmentId;

  List<CreateKnowledgeModel> allKnowledge = [];

  /// How many documents could not be read on the last load (KH-APPROVE-10).
  int unreadableDocuments = 0;

  List<CreateKnowledgeModel> filteredKnowledge = [];

  List<CreateKnowledgeModel> upperCategoryFiltered =
      []; // Stores upper category results
  String searchQuery = '';

  List<CreateNewCommentModel> currentComments = [];

  String? currentKnowledgeId;

  // ✅ Current logged-in user email
  String? currentUserEmail;

  // ✅ Cache for user data to avoid repeated fetches
  final Map<String, EmployeeData> _usersCache = {};

  // ✅ Cache for department names to avoid repeated fetches
  final Map<String, String> _departmentsCache = {};

  // Status counts for UI
  Map<String, int> statusCounts = {
    'All': 0,
    'Approved': 0,
    'Pending': 0,
    'Rejected': 0,
    'Removed': 0,
    'Archive': 0,
  };

  ApprovalsCubitBase(this._repository, this.people) : super(ApprovalsInitial());

  @override
  void emit(ApprovalsStates state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// The reason saved with the document's last "removed" status: taken from
  /// the loaded queue when the document is there, otherwise read once.
  Future<String?> getRemovalReason(String knowledgeId) async {
    for (final doc in allKnowledge) {
      if (doc.currentKnowledgeId == knowledgeId ||
          doc.knowledgeId.contains(knowledgeId)) {
        final reason = doc.removalReason;
        return reason.isEmpty ? null : reason;
      }
    }
    try {
      return await _repository.getRemovalReason(knowledgeId);
    } catch (e) {
      khLog('getRemovalReason failed: $e', name: 'ApprovalsCubit');
      return null;
    }
  }

  // Implemented in ApprovalsCubitPart2, used by Part1 and Part1Methods2.
  String _mapDisplayStatusToActual(String displayStatus);
  Future<EmployeeData?> getUserDataByEmail(String email);
  Future<String> getDepartmentName(String departmentId);
  // Implemented in ApprovalsCubitPart1Methods2, used by Part1.
  Future<void> fetchAllSubmissions({bool silent = false});

  final LiveRefresh _live = LiveRefresh();

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  Map<String, EmployeeData> get usersCache => _usersCache;

  Map<String, String> get departmentsCache => _departmentsCache;
}
