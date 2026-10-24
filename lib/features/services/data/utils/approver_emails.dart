/// Module: services_management_module
/// ******************* FILE INFO *******************
/// File Name: approver_emails.dart
/// Description: Flat list of approver e-mails stored next to a request's
///              Approval_Cycle so the Approvals screen can QUERY "requests
///              where I am an approver" (SVC-HOME-03) instead of downloading
///              every request and decoding each approval-cycle JSON blob.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
/// *************************************************
library;

import 'dart:convert';

class ApproverEmails {
  const ApproverEmails._();

  /// Firestore field: lower-cased approver e-mails of the CURRENT cycle.
  static const String field = 'Approver_Emails';

  /// Approval_Cycle field name on request documents.
  static const String cycleField = 'Approval_Cycle';

  /// Extracts the lower-cased approver e-mails from an Approval_Cycle value
  /// (a history list whose last entry is a JSON-encoded list of approvers,
  /// or a plain list of approver maps). Returns null when [cycle] has no
  /// readable shape, so callers can leave the field untouched.
  static List<String>? fromCycle(Object? cycle) {
    Object? current = cycle;
    if (current is List && current.isNotEmpty && current.last is String) {
      try {
        current = jsonDecode(current.last as String);
      } on FormatException {
        return null;
      }
    }
    if (current is! List) return null;

    final emails = <String>{};
    for (final item in current) {
      if (item is Map) {
        final email = (item['email'] ?? '').toString().trim().toLowerCase();
        if (email.isNotEmpty) emails.add(email);
      }
    }
    return emails.toList();
  }
}
