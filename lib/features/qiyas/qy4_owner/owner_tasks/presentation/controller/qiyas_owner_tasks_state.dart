part of 'qiyas_owner_core_cubit.dart';

@immutable
sealed class QiyasTasksState {}

final class QiyasTasksInitial extends QiyasTasksState {}

final class QiyasTasksStatusUpdated extends QiyasTasksState {}

final class SectionViewUpdated extends QiyasTasksState {}

final class QiyasTasksFileSelected extends QiyasTasksState {}

final class QiyasTasksEvidenceSubmitted extends QiyasTasksState {}

final class QiyasTasksSubmissionsUpdated extends QiyasTasksState {}
