/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: submission_state.dart
/// Description: `SubmissionsState` and its states. The answers live on the
///              field controllers, which the page owns; the state holds only
///              flags and the result of a submission.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:equatable/equatable.dart';

/// Base state of [FormSubmissionsCubit].
abstract class SubmissionsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Before [FormSubmissionsCubit.init].
class SubmissionsInitial extends SubmissionsState {}

/// The form is open for reading or filling out.
class SubmissionsLoaded extends SubmissionsState {
  /// True once the user tried to submit (shows the field errors).
  final bool isSubmitted;

  /// True while the answers cannot be changed.
  final bool isReadOnly;

  /// True while a submission is in flight (double-tap guard).
  final bool isSubmitting;

  /// FB-RESULT-08: true when the answer may still be edited.
  final bool canEdit;

  /// Bumped on every answer change so the page rebuilds.
  final int revision;

  /// A translated message to show once (failed submission), or null.
  final String? errorMessage;

  /// Increases with every new [errorMessage], so the same message twice is
  /// still shown twice.
  final int errorId;

  SubmissionsLoaded({
    required this.isSubmitted,
    required this.isReadOnly,
    this.isSubmitting = false,
    this.canEdit = false,
    this.revision = 0,
    this.errorMessage,
    this.errorId = 0,
  });

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given fields changed.
  ///
  /// Returns: the new state.
  SubmissionsLoaded copyWith({
    bool? isSubmitted,
    bool? isReadOnly,
    bool? isSubmitting,
    bool? canEdit,
    int? revision,
    String? errorMessage,
    int? errorId,
  }) {
    return SubmissionsLoaded(
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      canEdit: canEdit ?? this.canEdit,
      revision: revision ?? this.revision,
      errorMessage: errorMessage ?? this.errorMessage,
      errorId: errorId ?? this.errorId,
    );
  }

  @override
  List<Object?> get props => [
        isSubmitted,
        isReadOnly,
        isSubmitting,
        canEdit,
        revision,
        errorMessage,
        errorId,
      ];
}
