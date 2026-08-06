part of './notification_cubit.dart';

sealed class MainCoreNotificationState {
  const MainCoreNotificationState();
}

final class MainCoreNotificationInitial extends MainCoreNotificationState {
  const MainCoreNotificationInitial();
}

final class MainCoreNotificationLoading extends MainCoreNotificationState {
  const MainCoreNotificationLoading();
}

final class MainCoreNotificationLoaded extends MainCoreNotificationState {
  final List<NotificationModel> notifications;

  const MainCoreNotificationLoaded({required this.notifications});
}

final class MainCoreNotificationError extends MainCoreNotificationState {
  final String message;

  const MainCoreNotificationError(this.message);
}
