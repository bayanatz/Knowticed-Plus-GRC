part of 'control_core_cubit.dart';

@immutable
sealed class ControlCoreState {}

final class ControlCoreInitial extends ControlCoreState {}

final class OwnerDataChanged extends ControlCoreState {}

final class VisionsDataChanged extends ControlCoreState {}

final class DropdownSelectionChanged extends ControlCoreState {}

final class OwnersDataLoaded extends ControlCoreState {}

final class AddNewControlDataSuccess extends ControlCoreState {}

final class AddNewControlDataFailed extends ControlCoreState {
  final String errorMessage;

  AddNewControlDataFailed(this.errorMessage);
}

final class DocumentSelectorUpdated extends ControlCoreState {}

final class SectionViewUpdated extends ControlCoreState {}

final class EvidenceSubmissionLoading extends ControlCoreState {}

final class EvidenceSubmissionLoaded extends ControlCoreState {}
