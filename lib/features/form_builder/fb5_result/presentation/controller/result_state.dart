/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: result_state.dart
/// Description: `ResultState` and its states. No controllers here: the
///              pages own their TabController and text controllers.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:equatable/equatable.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/user_grid_item.dart';

/// Base state of [ResultCubit].
abstract class ResultState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Before [ResultCubit.initialize].
class ResultInitial extends ResultState {}

/// While the page sets up.
class ResultLoading extends ResultState {}

/// What a one-time [ResultNotice] tells the page to show.
enum ResultNoticeType {
  /// Something still works but may be incomplete (e.g. departments).
  warning,

  /// The CSV export failed.
  exportFailed,

  /// The CSV export was saved.
  exported,
}

/// A message the page shows once (dialog). A new [id] means a new notice.
class ResultNotice extends Equatable {
  final ResultNoticeType type;
  final String message;
  final int id;

  const ResultNotice(
      {required this.type, required this.message, required this.id});

  @override
  List<Object?> get props => [type, message, id];
}

/// The Results page with its people.
class ResultLoaded extends ResultState {
  final FormEntity? formEntity;
  final UserGridItem? selectedUser;
  final List<UserGridItem> pendingUsers;
  final List<UserGridItem> filteredPendingUsers;
  final List<UserGridItem> submittedUsers;
  final List<UserGridItem> filteredSubmittedUsers;

  /// Department ids picked in the Department filter; empty = everyone.
  final List<String> selectedDepartmentIds;

  /// The text typed in the search box.
  final String searchQuery;

  /// True on the Pending tab, false on Submissions.
  final bool isPendingScreen;
  final bool isGridView;

  /// True for the Users view, false for Analytics.
  final bool isUser;

  /// True from the moment the page opens until the pending / submitted users
  /// have arrived. While true the lists are empty because they are LOADING,
  /// so the tabs show the loading circle, not the "no data" state.
  final bool isLoadingUsers;

  /// A message to show once, or null.
  final ResultNotice? notice;

  /// Bumped when a person in the lists changed in place (e.g. a reminder
  /// was sent), so the page rebuilds.
  final int revision;

  ResultLoaded({
    this.formEntity,
    this.selectedUser,
    required this.pendingUsers,
    required this.filteredPendingUsers,
    required this.submittedUsers,
    required this.filteredSubmittedUsers,
    this.selectedDepartmentIds = const [],
    this.searchQuery = '',
    this.isPendingScreen = true,
    this.isGridView = true,
    this.isUser = true,
    this.isLoadingUsers = false,
    this.notice,
    this.revision = 0,
  });

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given fields changed.
  ///
  /// Returns: the new state.
  ResultLoaded copyWith({
    FormEntity? formEntity,
    UserGridItem? selectedUser,
    List<UserGridItem>? pendingUsers,
    List<UserGridItem>? filteredPendingUsers,
    List<UserGridItem>? submittedUsers,
    List<UserGridItem>? filteredSubmittedUsers,
    List<String>? selectedDepartmentIds,
    String? searchQuery,
    bool? isPendingScreen,
    bool? isGridView,
    bool? isUser,
    bool? isLoadingUsers,
    ResultNotice? notice,
    int? revision,
  }) {
    return ResultLoaded(
      formEntity: formEntity ?? this.formEntity,
      selectedUser: selectedUser ?? this.selectedUser,
      pendingUsers: pendingUsers ?? this.pendingUsers,
      filteredPendingUsers: filteredPendingUsers ?? this.filteredPendingUsers,
      submittedUsers: submittedUsers ?? this.submittedUsers,
      filteredSubmittedUsers:
          filteredSubmittedUsers ?? this.filteredSubmittedUsers,
      selectedDepartmentIds:
          selectedDepartmentIds ?? this.selectedDepartmentIds,
      searchQuery: searchQuery ?? this.searchQuery,
      isPendingScreen: isPendingScreen ?? this.isPendingScreen,
      isGridView: isGridView ?? this.isGridView,
      isUser: isUser ?? this.isUser,
      isLoadingUsers: isLoadingUsers ?? this.isLoadingUsers,
      notice: notice ?? this.notice,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [
        formEntity,
        selectedUser,
        pendingUsers,
        filteredPendingUsers,
        submittedUsers,
        filteredSubmittedUsers,
        selectedDepartmentIds,
        searchQuery,
        isPendingScreen,
        isGridView,
        isUser,
        isLoadingUsers,
        notice,
        revision,
      ];
}

/// The users could not be loaded.
class ResultError extends ResultState {
  final String message;

  ResultError(this.message);

  @override
  List<Object?> get props => [message];
}
