part of './schedule_controller.dart';

@immutable
sealed class ScheduleState {}

final class ScheduleInitial extends ScheduleState {}

/// Emitted whenever the schedule lists (todos, events, tasks, services,
/// surveys) are refreshed for the selected date.
///
/// A fresh instance is created on every emit so Cubit's equality check does not
/// deduplicate consecutive refreshes.
final class ScheduleUpdated extends ScheduleState {}
