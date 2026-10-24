/// Module: knowledge_hub/kh6_approvals/presentation/controller
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_states.dart
/// Description: `ApprovalsStates` state, `ApprovalsInitial` state, `FetchingApprovalsLoadingState` state and 20 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: approvals_states.dart
/// Purpose: States for ApprovalsCubit
/// Author: Youssef Khaled

abstract class ApprovalsStates {}

enum ApprovalsErrorKey {
  unknown,
  accountNotLoaded,
  loadFailed,
  sessionExpired,
  statusUpdateFailed,
  noApprovePermission,
  noRejectPermission,
  notPendingInQueue,
  approveFailed,
  rejectFailed,
  addCommentFailed,
  recordActionFailed,
}

class ApprovalsInitial extends ApprovalsStates {}

// ==================== Fetching Approvals States ====================
class FetchingApprovalsLoadingState extends ApprovalsStates {}

class FetchingApprovalsSuccessState extends ApprovalsStates {
  final List<CreateKnowledgeModel> approvals;
  FetchingApprovalsSuccessState(this.approvals);
}

class FetchingApprovalsEmptyState extends ApprovalsStates {}

class FetchingApprovalsErrorState extends ApprovalsStates {
  /// Technical detail (an exception text) — may be empty.
  final String error;
  final ApprovalsErrorKey key;
  FetchingApprovalsErrorState(
    this.error, {
    this.key = ApprovalsErrorKey.unknown,
  });
}

// ==================== Status Index States ====================
class ChangeIndexSuccessState extends ApprovalsStates {
  final int index;
  ChangeIndexSuccessState(this.index);
}

// ==================== Comments States ====================
class FetchingCommentsLoadingState extends ApprovalsStates {}

class FetchingCommentsSuccessState extends ApprovalsStates {
  final List<CreateNewCommentModel> comments;
  FetchingCommentsSuccessState(this.comments);
}

class FetchingCommentsEmptyState extends ApprovalsStates {}

class FetchingCommentsErrorState extends ApprovalsStates {
  /// Technical detail (an exception text) — may be empty.
  final String error;
  final ApprovalsErrorKey key;
  FetchingCommentsErrorState(
    this.error, {
    this.key = ApprovalsErrorKey.unknown,
  });
}

// ==================== Adding Comment States ====================
class AddingCommentLoadingState extends ApprovalsStates {}

class AddingCommentSuccessState extends ApprovalsStates {}

class AddingCommentErrorState extends ApprovalsStates {
  /// Technical detail (an exception text) — may be empty.
  final String error;
  final ApprovalsErrorKey key;
  AddingCommentErrorState(this.error, {this.key = ApprovalsErrorKey.unknown});
}

// ==================== File Action States ====================
class RecordFileActionLoading extends ApprovalsStates {}

class RecordFileActionSuccess extends ApprovalsStates {
  final String typeOfAction;
  RecordFileActionSuccess({required this.typeOfAction});
}

class RecordFileActionFailure extends ApprovalsStates {
  /// Technical detail (an exception text) — may be empty.
  final String error;
  final ApprovalsErrorKey key;
  RecordFileActionFailure(this.error, {this.key = ApprovalsErrorKey.unknown});
}

// ==================== Approve Knowledge States ====================
class ApprovingKnowledgeLoadingState extends ApprovalsStates {}

class ApprovingKnowledgeSuccessState extends ApprovalsStates {}

class ApprovingKnowledgeErrorState extends ApprovalsStates {
  /// Technical detail (an exception text) — may be empty.
  final String error;
  final ApprovalsErrorKey key;
  ApprovingKnowledgeErrorState(
    this.error, {
    this.key = ApprovalsErrorKey.unknown,
  });
}

// ==================== Reject Knowledge States ====================
class RejectingKnowledgeLoadingState extends ApprovalsStates {}

class RejectingKnowledgeSuccessState extends ApprovalsStates {}

class RejectingKnowledgeErrorState extends ApprovalsStates {
  /// Technical detail (an exception text) — may be empty.
  final String error;
  final ApprovalsErrorKey key;
  RejectingKnowledgeErrorState(
    this.error, {
    this.key = ApprovalsErrorKey.unknown,
  });
}
