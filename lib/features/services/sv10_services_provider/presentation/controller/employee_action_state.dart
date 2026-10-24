/// Module: services / sv10_services_provider / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: employee_action_state.dart
/// Purpose: State of a provider's status change on the request page: busy,
///          saved (with whether the requester was notified), refused or
///          failed. The page listens and shows the matching message.
/// Author: Knowticed Team
/// Created At: 02/07/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): Saved / Refused / Failed states replace the
///     page's try/catch (Provider rule 8).
library;

import 'package:equatable/equatable.dart';

abstract class EmployeeActionState extends Equatable {
  const EmployeeActionState();

  @override
  List<Object?> get props => [];
}

class EmployeeActionIdle extends EmployeeActionState {
  const EmployeeActionIdle();
}

class EmployeeActionBusy extends EmployeeActionState {
  const EmployeeActionBusy();
}

/// The new status is saved.
class EmployeeActionSaved extends EmployeeActionState {
  /// The status the request moved to.
  final String newState;

  /// True when the requester could not be notified (SVC-PROV-12).
  final bool notificationFailed;

  const EmployeeActionSaved({
    required this.newState,
    required this.notificationFailed,
  });

  @override
  List<Object?> get props => [newState, notificationFailed];
}

/// The move is not allowed from the request's current status (SVC-PROV-06).
class EmployeeActionRefused extends EmployeeActionState {
  const EmployeeActionRefused();
}

/// The save failed.
class EmployeeActionFailed extends EmployeeActionState {
  /// English detail for logs only — never shown to the user.
  final String message;

  const EmployeeActionFailed(this.message);

  @override
  List<Object?> get props => [message];
}
