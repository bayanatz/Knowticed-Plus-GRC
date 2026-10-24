// ******************* FILE INFO *******************
// File Name: services_view_tests
// Description: DEBUG ONLY (owner-approved, 22/10/2026). Sends the signed-in
//              user one Services notification per View landing, each carrying
//              a REAL request's id, so "View opens the record" can be checked
//              on a device: approver details, provider details, requester's
//              request. Reads requests only — writes notification docs only.
// Module: services_management_module / helpers / debug
// *************************************************

import 'package:knowticed_plus/features/services/domain/entities/parent_service_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/parent_service_details_fetcher.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';

/// Function Name: [sendServicesViewTests]
///
/// Purpose: One notification per Services landing, all to [receiverEmail],
/// through `ServicesNotificationService` (same templates, page keys and
/// `Request_Id` as the real flow). Never throws.
///
/// Returns: how many were sent (0 when no request exists).
Future<int> sendServicesViewTests({
  required String receiverEmail,
  required bool isArabic,
}) async {
  if (receiverEmail.trim().isEmpty) {
    debugPrint('ServicesViewTests: no receiver email — nothing sent.');
    return 0;
  }
  try {
    final QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
        .instance
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .limit(25)
        .get();

    ServicesHistoryModel? request;
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
      try {
        final ServicesHistoryModel m =
            ServicesHistoryModel.fromJson(doc.data(), doc.id);
        if (m.isDeleted) continue;
        request = m;
        break;
      } catch (_) {
        continue; // Malformed legacy doc — try the next one.
      }
    }
    if (request == null) {
      debugPrint('ServicesViewTests: no service request found — skipped.');
      return 0;
    }

    String serviceName = isArabic
        ? request.currentServiceNameArabic
        : request.currentServiceNameEnglish;
    if (serviceName.isEmpty && request.currentParentServiceId.isNotEmpty) {
      final ParentServiceDetails details =
          await ParentServiceDetailsFetcher(FirebaseFirestore.instance)
              .fetch(request.currentParentServiceId);
      serviceName = isArabic ? details.nameArabic : details.nameEnglish;
    }
    if (serviceName.isEmpty) serviceName = request.currentId;

    final String requesterName =
        '${request.currentFirstNameRequester} ${request.currentLastNameRequester}'
            .trim();
    final String id = request.currentId;
    int sent = 0;

    // ApprovalRequestCard → approver's details (Approve / Reject).
    if (await const ServicesNotificationService().notifyApproverOfNewRequest(
      requestId: id,
      senderEmail: receiverEmail,
      approverEmail: receiverEmail,
      serviceName: serviceName,
      requesterName: requesterName.isEmpty ? '-' : requesterName,
      isArabic: isArabic,
    )) {
      sent++;
    }
    // ServiceProviderDashboard → provider's details.
    if (await const ServicesNotificationService().notifyProviderOfAssignment(
      requestId: id,
      senderEmail: receiverEmail,
      providerEmail: receiverEmail,
      serviceName: serviceName,
      isArabic: isArabic,
    )) {
      sent++;
    }
    // RequestServicesToggle → requester's request.
    if (await const ServicesNotificationService().notifyRequesterOfSubmission(
      requestId: id,
      senderEmail: receiverEmail,
      requesterEmail: receiverEmail,
      serviceName: serviceName,
      isArabic: isArabic,
    )) {
      sent++;
    }

    debugPrint('ServicesViewTests: sent $sent for request $id.');
    return sent;
  } catch (e) {
    debugPrint('ServicesViewTests: failed — $e');
    return 0;
  }
}
