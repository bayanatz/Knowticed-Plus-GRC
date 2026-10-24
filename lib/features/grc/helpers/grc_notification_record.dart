/// Module: GRC
///
///*************************** FILE INFO ****************************///
/// File Name: grc_notification_record.dart
/// Purpose: The record a GRC notification points at, written into the
///          notification's `Request_Id` by the GRC senders and read back by
///          `GovernanceRiskAndCompliancePage` when its View is tapped.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// WHY AN ENCODED STRING
/// ---------------------
/// Owner, 22/10/2026: every notification's View opens the record itself.
/// A GRC record lives under its module (and a control under its policy), so a
/// bare document id is not enough to load it. `Request_Id` is one string, so
/// the path goes in it:
///
///     module:<moduleId>
///     policy:<moduleId>/<policyId>
///     control:<moduleId>/<policyId>/<controlId>
///     request:<moduleId>/<requestId>
///
/// Firestore ids never contain '/', so splitting on it is safe. The page key
/// (`name_of_page`) still says WHICH view of the record to open.
library;

enum GrcRecordKind { module, policy, control, request }

class GrcNotificationRecord {
  const GrcNotificationRecord._({
    required this.kind,
    required this.moduleId,
    this.policyId = '',
    this.controlId = '',
    this.requestId = '',
  });

  final GrcRecordKind kind;
  final String moduleId;
  final String policyId;
  final String controlId;
  final String requestId;

  // ── Encoding (senders) ──────────────────────────────────────────────────

  static String module(String moduleId) => _join('module', [moduleId]);

  static String policy(String moduleId, String policyId) =>
      _join('policy', [moduleId, policyId]);

  static String control(String moduleId, String policyId, String controlId) =>
      _join('control', [moduleId, policyId, controlId]);

  static String request(String moduleId, String requestId) =>
      _join('request', [moduleId, requestId]);

  /// '' when any part is missing — an empty `Request_Id` arms nothing, so the
  /// View falls back to the module list instead of a half-path.
  static String _join(String kind, List<String> parts) {
    final List<String> trimmed = parts.map((String p) => p.trim()).toList();
    if (trimmed.any((String p) => p.isEmpty)) return '';
    return '$kind:${trimmed.join('/')}';
  }

  // ── Decoding (GRC root page) ────────────────────────────────────────────

  /// Null for anything this file did not write.
  static GrcNotificationRecord? parse(String raw) {
    final int colon = raw.indexOf(':');
    if (colon <= 0) return null;
    final String kind = raw.substring(0, colon);
    final List<String> parts = raw.substring(colon + 1).split('/');
    if (parts.any((String p) => p.isEmpty)) return null;
    switch (kind) {
      case 'module' when parts.length == 1:
        return GrcNotificationRecord._(
          kind: GrcRecordKind.module,
          moduleId: parts[0],
        );
      case 'policy' when parts.length == 2:
        return GrcNotificationRecord._(
          kind: GrcRecordKind.policy,
          moduleId: parts[0],
          policyId: parts[1],
        );
      case 'control' when parts.length == 3:
        return GrcNotificationRecord._(
          kind: GrcRecordKind.control,
          moduleId: parts[0],
          policyId: parts[1],
          controlId: parts[2],
        );
      case 'request' when parts.length == 2:
        return GrcNotificationRecord._(
          kind: GrcRecordKind.request,
          moduleId: parts[0],
          requestId: parts[1],
        );
    }
    return null;
  }
}
