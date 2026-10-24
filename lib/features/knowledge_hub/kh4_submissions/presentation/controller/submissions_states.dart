/// Module: knowledge_hub/kh4_submissions/presentation/controller
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_states.dart
/// Description: `SubmissionsStates` state, `SubmissionsInitial` state, `ChangeIndexSuccessState` state and 21 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: submissions_states.dart
/// Purpose: Contains all the states of Submissions screen.
/// Author: Youssef Khaled
/// Created At: 14/10/2025

abstract class SubmissionsStates {}

class SubmissionsInitial extends SubmissionsStates {}

class ChangeIndexSuccessState extends SubmissionsStates {
  final int index;
  ChangeIndexSuccessState(this.index);
}

class ChangeInnerIndexSuccessState extends SubmissionsStates {
  final int index;
  ChangeInnerIndexSuccessState(this.index);
}

class FetchingSubmissionsLoadingState extends SubmissionsStates {}

class FetchingSubmissionsSuccessState extends SubmissionsStates {
  final List<CreateKnowledgeModel> knowledgeList;
  FetchingSubmissionsSuccessState(this.knowledgeList);
}

class FetchingSubmissionsEmptyState extends SubmissionsStates {}

class FetchingSubmissionsErrorState extends SubmissionsStates {
  final String error;
  FetchingSubmissionsErrorState(this.error);
}

class FetchingCommentsLoadingState extends SubmissionsStates {}

class FetchingCommentsSuccessState extends SubmissionsStates {
  final List<CreateNewCommentModel> comments;
  FetchingCommentsSuccessState(this.comments);
}

class FetchingCommentsEmptyState extends SubmissionsStates {}

class FetchingCommentsErrorState extends SubmissionsStates {
  final String error;
  FetchingCommentsErrorState(this.error);
}

class AddingCommentLoadingState extends SubmissionsStates {}

class AddingCommentSuccessState extends SubmissionsStates {}

class AddingCommentErrorState extends SubmissionsStates {
  final String error;
  AddingCommentErrorState(this.error);
}

class RecordFileActionLoading extends SubmissionsStates {}

class RecordFileActionSuccess extends SubmissionsStates {
  final String typeOfAction;

  RecordFileActionSuccess(this.typeOfAction);
}

class RecordFileActionFailure extends SubmissionsStates {
  final String error;

  RecordFileActionFailure(this.error);
}

class UpdatingCommentLoadingState extends SubmissionsStates {}

class UpdatingCommentSuccessState extends SubmissionsStates {}

class UpdatingCommentErrorState extends SubmissionsStates {
  final String error;
  UpdatingCommentErrorState(this.error);
}

// ============= DELETE COMMENT STATES =============
class DeletingCommentLoadingState extends SubmissionsStates {}

class DeletingCommentSuccessState extends SubmissionsStates {}

class DeletingCommentErrorState extends SubmissionsStates {
  final String error;
  DeletingCommentErrorState(this.error);
}
