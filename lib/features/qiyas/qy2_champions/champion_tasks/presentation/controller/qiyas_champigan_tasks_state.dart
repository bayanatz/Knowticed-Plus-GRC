part of 'qiyas_champigan_tasks_cubit.dart';

@immutable
sealed class QiyasTasksState {}

final class QiyasTasksInitial extends QiyasTasksState {}

final class QiyasTasksStatusUpdated extends QiyasTasksState {}

// ✅ ADD THESE:
class QiyasTasksUploading extends QiyasTasksState {}

class QiyasTasksUploadError extends QiyasTasksState {
  final String message;
  QiyasTasksUploadError(this.message);
}

final class SectionViewUpdated extends QiyasTasksState {}

final class QiyasTasksFileSelected extends QiyasTasksState {}

final class QiyasTasksEvidenceSubmitted extends QiyasTasksState {}

final class QiyasTasksSubmissionsUpdated extends QiyasTasksState {}
