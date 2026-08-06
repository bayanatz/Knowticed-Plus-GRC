sealed class UserAccessState {}

final class UserAccessInitial extends UserAccessState {}

final class UserAccessLoaded extends UserAccessState {}

final class UserAccessLoading extends UserAccessState {}

final class UserAccessError extends UserAccessState {
  final String message;
  UserAccessError(this.message);
}