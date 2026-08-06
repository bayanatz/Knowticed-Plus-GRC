part of './system_logs_controller.dart';

@immutable
sealed class SystemLogsState {}

final class SystemLogsInitial extends SystemLogsState {}

/// Emitted whenever the logs list, filters or sort order change.
///
/// Replaces the GetX `update()` calls, which were all undifferentiated
/// "rebuild everything" notifications. A fresh instance is created on every
/// emit so Cubit's equality check does not deduplicate consecutive changes
/// (e.g. two filter updates in a row).
final class SystemLogsUpdated extends SystemLogsState {}
