/// Module: services / sv2_create_single_services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: sla_notification_state.dart
/// Purpose: State classes for SLA notification cubit Created by: Amr Mesbah
///          Last Update: 30/8/2025
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:equatable/equatable.dart';

abstract class SlaNotificationState extends Equatable {
  const SlaNotificationState();

  @override
  List<Object?> get props => [];
}

class SlaNotificationInitial extends SlaNotificationState {}

class SlaNotificationLoading extends SlaNotificationState {}

class SlaNotificationDraftSaved extends SlaNotificationState {
  const SlaNotificationDraftSaved();
}

class SlaNotificationLoaded extends SlaNotificationState {
  final String? currentDocId;
  final bool notifyRequesterChecked;
  final bool notifyProviderChecked;
  final bool notifyManagerChecked;
  final bool notifyRequesterSwitch0;
  final bool notifyManagerSwitch1;
  final List<String> extraSlaList;
  final List<String> extraSlaTwoList;
  final Map<String, Map<int, bool>> notificationSwitches;

  const SlaNotificationLoaded({
    this.currentDocId,
    required this.notifyRequesterChecked,
    required this.notifyProviderChecked,
    required this.notifyManagerChecked,
    required this.notifyRequesterSwitch0,
    required this.notifyManagerSwitch1,
    required this.extraSlaList,
    required this.extraSlaTwoList,
    required this.notificationSwitches,
  });

  @override
  List<Object?> get props => [
        currentDocId,
        notifyRequesterChecked,
        notifyProviderChecked,
        notifyManagerChecked,
        notifyRequesterSwitch0,
        notifyManagerSwitch1,
        extraSlaList,
        extraSlaTwoList,
        notificationSwitches,
      ];
}

class SlaNotificationSaving extends SlaNotificationState {}

class SlaNotificationSaved extends SlaNotificationState {}

class SlaNotificationError extends SlaNotificationState {
  final String message;

  const SlaNotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Why the SLA page could not go on (C6/C11: the cubit reports the reason;
/// the page shows it in the reader's language).
enum SlaValidationIssue {
  wholeNumbersOnly,
  numbersOnly,
  enableSection,
  enableSectionWithSla,
  draftNotSaved,
  saveFailed,
}

class SlaNotificationValidationError extends SlaNotificationState {
  final SlaValidationIssue issue;

  /// The notification section the issue is about (for [enableSection] and
  /// [enableSectionWithSla]).
  final String section;

  const SlaNotificationValidationError(this.issue, {this.section = ''});

  @override
  List<Object?> get props => [issue, section];
}
