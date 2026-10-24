/// Module: knowledge_hub/kh4_submissions/presentation/controller
/// ************************* FILE INFO *************************** ///
/// File Name: submissions_cubit.dart
/// Description: Contains all the functions to view Submitted files with filtering.
/// Author: Amr Mesbah
/// Created at: 14/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_people.dart';

import 'dart:io';

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_states.dart';

import 'package:knowticed_plus/core/constants/app_constants.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/domain/base_repository/submissions_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';

part 'submissions_cubit.part.1.dart';
part 'submissions_cubit.part.2.dart';
part 'submissions_cubit.part.3.dart';
part 'submissions_cubit.part.2/submissions_cubit_part2_methods.dart';

/// The submissions cubit.
///
/// The behaviour lives in four real mixins, one per file, on
/// [SubmissionsCubitBase] (all the state), so they can call [emit] like any
/// subclass member — no `extension … on …` and no
/// `ignore_for_file: invalid_use_of_protected_member`.
///   * [SubmissionsCubitPart2Methods2] — date filters
///   * [SubmissionsCubitPart1]         — loading, comments, archive notice
///   * [SubmissionsCubitPart2]         — status flow, counts, filters, search
///   * [SubmissionsCubitPart3]         — dialog filters, comments, users
class SubmissionsCubit extends SubmissionsCubitBase
    with
        SubmissionsCubitPart2Methods2,
        SubmissionsCubitPart1,
        SubmissionsCubitPart2,
        SubmissionsCubitPart3 {
  SubmissionsCubit(super.repository, super.people);
}

/// The state shared by the submissions mixins.
abstract class SubmissionsCubitBase extends Cubit<SubmissionsStates> {
  final SubmissionsBaseRepository _repository;

  /// Signed-in employee + employee / department lookups (injected).
  final KhPeople people;

  int selectedStatusIndex = 0;

  int selectedInnerStatusIndex = 0;

  String? selectedDocumentType;

  String? selectedStatus;

  String? selectedInnerStatus;

  String? selectedDepartment;

  DateTime? selectedStartDate;

  DateTime? selectedEndDate;

  List<CreateKnowledgeModel> allKnowledge = [];

  List<CreateKnowledgeModel> filteredKnowledge = [];

  List<CreateKnowledgeModel> upperCategoryFiltered = [];

  String searchQuery = '';

  List<CreateNewCommentModel> currentComments = [];

  String? currentKnowledgeId;

  final Map<String, EmployeeData> _usersCache = {};

  Map<String, int> statusCounts = {
    'All': 0,
    'Published': 0,
    'Approved': 0,
    'Pending': 0,
    'Rejected': 0,
    'Removed': 0,
    'Archive': 0,
  };

  List<String> availableDepartments = [];

  // Current user email for filtering
  String? _currentUserEmail;

  SubmissionsCubitBase(this._repository, this.people)
      : super(SubmissionsInitial());

  /// Rule Bug 5 — "check isClosed before emit". Every emit in the submissions
  /// mixins goes through here, so a result that arrives after the screen has
  /// closed the cubit is dropped instead of throwing.
  @override
  void emit(SubmissionsStates state) {
    if (isClosed) return;
    // A live refresh re-applies the user's filters without flashing the
    // loader.
    if (_silentRefresh && state is FetchingSubmissionsLoadingState) return;
    // every list the screen shows goes out through this
    // state, so sorting here covers fetch, tabs, search and filters alike.
    if (state is FetchingSubmissionsSuccessState) {
      _sortByLastEditNewestFirst(state.knowledgeList);
    }
    super.emit(state);
  }

  /// Newest "Last Edit" first. The card's Last Edit date is the LAST entry of
  /// [CreateKnowledgeModel.timestamps], so the same value orders the grid.
  /// Older records may hold seconds instead of milliseconds — normalised so
  /// both kinds sort together. Documents with no timestamp go last.
  static void _sortByLastEditNewestFirst(List<CreateKnowledgeModel> list) {
    int lastEdit(CreateKnowledgeModel k) {
      final int? t = k.timestamps.isNotEmpty ? k.timestamps.last : null;
      if (t == null) return 0;
      return t < 100000000000 ? t * 1000 : t; // seconds → millis
    }

    try {
      list.sort((a, b) => lastEdit(b).compareTo(lastEdit(a)));
    } on UnsupportedError {
      // An unmodifiable list: leave the order as it came.
    }
  }

  // Implemented in one mixin and used by another.
  Future<bool> _autoArchiveExpiredDocuments();
  void _calculateStatusCounts();
  Future<void> fetchCommentsByKnowledgeId(String knowledgeId);
  Future<void> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  });
  void _applyDateFilters();
  String? _getCurrentUserEmail();
  String _mapDisplayStatusToActual(String displayStatus);
  Future<bool> _sendArchiveNotification({
    required String knowledgeId,
    required String recipientEmail,
    required String documentNameEnglish,
    required String documentNameArabic,
    required DateTime archivedDate,
  });
  Future<void> fetchMySubmissions();
  Future<void> filterByStatus(String status, int index);
  Future<void> filterByInnerStatus(String innerStatus, int index);
  void _applySearch();

  Map<String, EmployeeData> get usersCache => _usersCache;

  final LiveRefresh _live = LiveRefresh();
  bool _silentRefresh = false;

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
