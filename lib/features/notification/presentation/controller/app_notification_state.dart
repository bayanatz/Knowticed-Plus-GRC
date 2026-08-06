part of './app_notification_cubit.dart';

sealed class AppNotificationState {
  const AppNotificationState();
}

final class AppNotificationInitial extends AppNotificationState {
  const AppNotificationInitial();
}
