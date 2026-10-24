/// Module: settings / helpers / debug
///
///************************ FILE INFO ****************************///
/// File Name: settings_view_tests.dart
/// Purpose: DEBUG ONLY (owner-approved, 22/10/2026). Sends the signed-in user
///          one change-request notification per View landing, each carrying a
///          REAL change request's id: the two reviewer pages (personal info;
///          health insurance / emergency contact) and the requester's page.
///          Reads requests only — writes notification docs only.
/// Created at: 22/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/features/notification/data/repository/settings_notification_service.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/models/change_request_mapper.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';

/// Function Name: [sendSettingsViewTests]
///
/// Purpose: One notification per Settings change-request landing, all to
/// [receiverEmail], through `SettingsNotificationService` (same templates,
/// page keys and `Request_Id` as the real flow). Never throws.
///
/// The reviewer kinds prefer someone else's request (the reviewer screen
/// blocks deciding your own); the requester kind prefers the receiver's own.
///
/// Returns: how many were sent.
Future<int> sendSettingsViewTests({
  required String receiverEmail,
  required bool isArabic,
}) async {
  final String me = receiverEmail.trim().toLowerCase();
  if (me.isEmpty) {
    debugPrint('SettingsViewTests: no receiver email — nothing sent.');
    return 0;
  }
  try {
    final QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
        .instance
        .doc(RequestCollectionPaths.rolesDoc)
        .collection(RequestCollectionPaths.requestsCollection)
        .limit(50)
        .get();

    final List<ChangeRequest> all = <ChangeRequest>[];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
      try {
        all.add(ChangeRequestMapper.fromDocument(doc.id, doc.data()));
      } catch (_) {
        continue; // Malformed legacy doc.
      }
    }
    if (all.isEmpty) {
      debugPrint('SettingsViewTests: no change request found — skipped.');
      return 0;
    }

    bool mine(ChangeRequest r) => r.employeeEmail.trim().toLowerCase() == me;
    ChangeRequest pick(bool Function(ChangeRequest) kind, {required bool own}) {
      return all.firstWhere((ChangeRequest r) => kind(r) && mine(r) == own,
          orElse: () => all.firstWhere(kind, orElse: () => all.first));
    }

    bool isHealth(ChangeRequest r) =>
        SettingsRequestKind.fromSection(r.section) !=
        SettingsRequestKind.personalInformation;
    bool isPersonal(ChangeRequest r) => !isHealth(r);

    int sent = 0;

    // PreviewChangesPage → reviewer's Approve / Reject screen.
    final ChangeRequest personal = pick(isPersonal, own: false);
    sent += await SettingsNotificationService.changeRequestSubmitted(
      requestId: personal.id,
      section: SettingsRequestKind.personalInformation.sectionName,
      employeeEmail: personal.employeeEmail,
      employeeName: personal.employeeName,
      isArabic: isArabic,
      reviewersOverride: <String>[receiverEmail],
    );

    // PreviewHealthInsuranceChangesPage → reviewer's Approve / Reject screen.
    final ChangeRequest health = pick(isHealth, own: false);
    sent += await SettingsNotificationService.changeRequestSubmitted(
      requestId: health.id,
      section: SettingsRequestKind.healthInsurance.sectionName,
      employeeEmail: health.employeeEmail,
      employeeName: health.employeeName,
      isArabic: isArabic,
      reviewersOverride: <String>[receiverEmail],
    );

    // MyRequestPage → the requester's own request.
    final ChangeRequest own = pick((ChangeRequest _) => true, own: true);
    if (await SettingsNotificationService.changeRequestApproved(
      requestId: own.id,
      section: own.section,
      employeeEmail: receiverEmail,
      approverEmail: receiverEmail,
      isArabic: isArabic,
    )) {
      sent++;
    }

    debugPrint('SettingsViewTests: sent $sent '
        '(reviewer ${personal.id}, ${health.id}; requester ${own.id}).');
    return sent;
  } catch (e) {
    debugPrint('SettingsViewTests: failed — $e');
    return 0;
  }
}
