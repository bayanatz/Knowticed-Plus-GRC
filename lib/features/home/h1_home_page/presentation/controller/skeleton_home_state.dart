part of './skeleton_home_controller.dart';

@immutable
sealed class SkeletonHomeState {}

final class SkeletonHomeInitial extends SkeletonHomeState {}

/// Emitted once the daily quote and the allowed module list are resolved.
///
/// A fresh instance is created on every emit so Cubit's equality check does not
/// deduplicate consecutive refreshes.
final class SkeletonHomeReady extends SkeletonHomeState {}
