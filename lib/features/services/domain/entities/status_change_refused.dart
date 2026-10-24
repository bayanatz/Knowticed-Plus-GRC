/// Module: services / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: status_change_refused.dart
/// Purpose: Thrown when a provider's status change is not allowed from the
///          request's current status (SVC-PROV-06), for example a request the
///          requester cancelled while the page was open.
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

/// Class Name: [StatusChangeRefused]
///
/// Purpose: The request could not move to the chosen status; nothing was
/// written.
class StatusChangeRefused implements Exception {
  /// The refused move, for logs (e.g. "cancel → done").
  final String detail;

  const StatusChangeRefused(this.detail);

  @override
  String toString() => 'StatusChangeRefused($detail)';
}
