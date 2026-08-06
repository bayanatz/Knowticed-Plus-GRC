part of './user_management_controller.dart';

@immutable
sealed class UserManagementControllerState {}

final class UserManagementControllerInitial
    extends UserManagementControllerState {}

final class UserManagementControllerLoading
    extends UserManagementControllerState {}

final class UserManagementControllerLoaded
    extends UserManagementControllerState {}

/// Emitted whenever the members / permissions lists change.
///
/// Replaces the old GetX `update(['editRoleMembersList'])` notifications. It is
/// deliberately a fresh instance each time so consecutive list mutations are
/// not deduplicated by Cubit's equality check.
final class UserManagementMembersUpdated
    extends UserManagementControllerState {}

class UserManagementControllerError extends UserManagementControllerState {
  final String message;
  UserManagementControllerError(this.message);
}
