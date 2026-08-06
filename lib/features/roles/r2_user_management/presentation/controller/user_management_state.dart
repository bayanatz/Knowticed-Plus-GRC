part of './user_management_cubit.dart';

@immutable
sealed class UserManagementAccessState {}

final class UserManagementInitial extends UserManagementAccessState {}

final class UserPermissionsDataLoaded extends UserManagementAccessState {}

class UserManagementAccessError extends UserManagementAccessState {
  final String message;
  UserManagementAccessError(this.message);
}

final class UserPermissionsDataLoading extends UserManagementAccessState {}
final class EmployeeToGiveAccessDataLoaded extends UserManagementAccessState {}




class UserPermissionsDataError extends UserManagementAccessState {
  final String message;
  UserPermissionsDataError(this.message);
}

