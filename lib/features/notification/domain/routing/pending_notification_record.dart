/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: pending_notification_record.dart
/// Purpose: The one-shot "open THIS record" hand-off from a notification's
///          View to the module it belongs to.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// WHY THIS EXISTS
/// ---------------
/// Owner, 22/10/2026: every notification's View must open the place you act
/// on it — the request, the document, the user, the role — not the module's
/// main page. A notification stores the record's id as `Request_Id` (see
/// `AppNotificationSender.requestId`) and the screen as `name_of_page`.
///
/// `NotificationRouting.openNotification` puts both here just before the
/// module opens; the module's root widget [take]s its own entry on its first
/// build (initState), loads the record and pushes its details page inside the
/// module, so Back lands on the module's list.
///
/// HOW A MODULE USES IT (one place per module, in its root widget):
///
///     final PendingNotificationRecord? r =
///         PendingNotificationRecord.take(Modules.services);
///     if (r != null) { /* load r.recordId, push its details (r.pageKey
///                          says which view: approver / requester / …) */ }
///
/// To-Do and Time Tracker keep their own older hints (`pendingTodoId`,
/// `pendingRequestId`); they work the same way.
library;

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';

class PendingNotificationRecord {
  const PendingNotificationRecord({
    required this.recordId,
    required this.pageKey,
  });

  /// The record's id, as stored in the notification's `Request_Id`.
  final String recordId;

  /// The notification's `name_of_page` — which view of the record to open.
  final String pageKey;

  static final Map<Modules, PendingNotificationRecord> _pending =
      <Modules, PendingNotificationRecord>{};

  /// Called by `NotificationRouting` only. An empty [recordId] sets nothing.
  static void arm(Modules module, String recordId, String pageKey) {
    final String id = recordId.trim();
    if (id.isEmpty) return;
    _pending[module] =
        PendingNotificationRecord(recordId: id, pageKey: pageKey);
  }

  /// Returns [module]'s pending record and clears it (used or not), so it can
  /// never leak into a later, unrelated visit.
  static PendingNotificationRecord? take(Modules module) =>
      _pending.remove(module);

  /// Clears every pending record (tests).
  static void clear() => _pending.clear();
}
