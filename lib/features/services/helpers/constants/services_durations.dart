/// Module: services / helpers / constants
///
///*************************** FILE INFO ****************************///
/// File Name: services_durations.dart
/// Purpose: Named durations used by the services screens (rule "Constants,
///          no magic values"; Create S2 — no unexplained fixed waits).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

/// Class Name: [ServicesDurations]
///
/// Purpose: How long timed UI (auto-closing success dialogs) stays visible.
/// These are display times, not waits for work to finish — work is awaited.
abstract final class ServicesDurations {
  /// A success dialog that closes by itself stays this long.
  static const Duration successDialog = Duration(seconds: 2);

  /// An error dialog that closes by itself stays this long.
  static const Duration errorDialog = Duration(seconds: 5);

  /// A chart scrolling to its first bar with a value.
  static const Duration chartScroll = Duration(milliseconds: 300);
}
