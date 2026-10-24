/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: services_notification_service.dart
/// Purpose: ALL notifications sent by the Services Management module
///          live here, as intent-named methods. UI pages, widgets and
///          cubits must NOT build NotificationModelSystem or call
///          FirestoreNotificationService / NotificationServiceApp
///          directly — they call this service.
/// Pattern: One `<module>_notification_service.dart` per module
///          (matches role_management_notification_service.dart).
///          All methods delegate to the shared AppNotificationSender.
/// Updated: 22/10/2026 - Every method takes the service request's id
///          (`RequestServices` doc id, e.g. REQ-2026-0042) and saves it as the
///          notification's `Request_Id`, so View opens that request
///          (see `ServicesResponsivePage._consumePendingRecord`).
///
/// ⚠️ REFERENCE IMPLEMENTATION — copy this shape for other modules.
/// Nothing here is a raw string: the event comes from the module's event
/// enum, the landing page from its page enum, and every placeholder from
/// TemplateVariable. `sendEvent` asserts in debug builds that no
/// placeholder the template needs was forgotten.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/features/notification/domain/enums/services/services_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/services/services_notification_pages.dart';
import 'package:knowticed_plus/features/notification/helpers/services/app_notification_sender.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

/// What [ServicesNotificationService.debugSendOverride] receives — the same
/// arguments every method hands `AppNotificationSender.sendEvent`.
typedef ServicesEventSend = Future<bool> Function({
  required ServicesNotificationEvent event,
  required String pageKey,
  required String senderEmail,
  required String receiverEmail,
  required bool isArabic,
  required String requestId,
  required Map<TemplateVariable, String> variables,
  Map<TemplateVariable, String>? variablesAr,
});

class ServicesNotificationService {
  /// Created once at the module root and injected where it is needed.
  const ServicesNotificationService();

  /// Tests only: records the send instead of writing Firestore / FCM.
  @visibleForTesting
  static ServicesEventSend? debugSendOverride;

  static Future<bool> _send({
    required ServicesNotificationEvent event,
    required String pageKey,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String requestId,
    required Map<TemplateVariable, String> variables,
    Map<TemplateVariable, String>? variablesAr,
  }) {
    final ServicesEventSend? override = debugSendOverride;
    if (override != null) {
      return override(
        event: event,
        pageKey: pageKey,
        senderEmail: senderEmail,
        receiverEmail: receiverEmail,
        isArabic: isArabic,
        requestId: requestId,
        variables: variables,
        variablesAr: variablesAr,
      );
    }
    return AppNotificationSender.sendEvent(
      event: event,
      pageKey: pageKey,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      requestId: requestId,
      variables: variables,
      variablesAr: variablesAr ?? const <TemplateVariable, String>{},
    );
  }

  /// A new request needs the approver's action.
  /// Template: services_needs_approval → page: ApprovalRequestCard
  Future<bool> notifyApproverOfNewRequest({
    required String requestId,
    required String senderEmail,
    required String approverEmail,
    required String serviceName,
    required String requesterName,
    required bool isArabic,
    String serviceNameArabic = '',
    String requesterNameArabic = '',
  }) {
    return _send(
      event: ServicesNotificationEvent.needsApproval,
      pageKey: ServicesNotificationPage.approvalRequestCard.key,
      senderEmail: senderEmail,
      receiverEmail: approverEmail,
      isArabic: isArabic,
      requestId: requestId.trim(),
      variables: {
        TemplateVariable.serviceName: serviceName,
        TemplateVariable.requesterName: requesterName,
      },
      variablesAr: {
        if (serviceNameArabic.isNotEmpty)
          TemplateVariable.serviceName: serviceNameArabic,
        if (requesterNameArabic.isNotEmpty)
          TemplateVariable.requesterName: requesterNameArabic,
      },
    );
  }

  /// Confirmation to the requester that their request was submitted.
  /// Template: services_request_submitted → page: RequestServicesToggle
  Future<bool> notifyRequesterOfSubmission({
    required String requestId,
    required String senderEmail,
    required String requesterEmail,
    required String serviceName,
    required bool isArabic,
    String serviceNameArabic = '',
  }) {
    return _send(
      event: ServicesNotificationEvent.requestSubmitted,
      pageKey: ServicesNotificationPage.requestServicesToggle.key,
      senderEmail: senderEmail,
      receiverEmail: requesterEmail,
      isArabic: isArabic,
      requestId: requestId.trim(),
      variables: {TemplateVariable.serviceName: serviceName},
      variablesAr: {
        if (serviceNameArabic.isNotEmpty)
          TemplateVariable.serviceName: serviceNameArabic,
      },
    );
  }

  /// Tell the requester their request was approved or rejected.
  /// Template: services_request_approved / services_request_rejected
  Future<bool> notifyRequesterOfDecision({
    required String requestId,
    required bool approved,
    required String approverEmail,
    required String requesterEmail,
    required String serviceName,
    required String approverName,
    required bool isArabic,
    String approverNameArabic = '',
    String rejectionReason = '',
  }) {
    return _send(
      event: approved
          ? ServicesNotificationEvent.requestApproved
          : ServicesNotificationEvent.requestRejected,
      pageKey: ServicesNotificationPage.requestServicesToggle.key,
      senderEmail: approverEmail,
      receiverEmail: requesterEmail,
      isArabic: isArabic,
      requestId: requestId.trim(),
      variables: {
        TemplateVariable.serviceName: serviceName,
        TemplateVariable.approverName: approverName,
        TemplateVariable.rejectionReason: rejectionReason,
      },
      variablesAr: {
        if (approverNameArabic.isNotEmpty)
          TemplateVariable.approverName: approverNameArabic,
      },
    );
  }

  /// Tell the assigned provider the request was approved (it is now in
  /// progress) or rejected.
  /// Template: services_request_in_progress / services_request_rejected
  ///           → page: ServiceProviderDashboard
  Future<bool> notifyProviderOfDecision({
    required bool approved,
    required String senderEmail,
    required String providerEmail,
    required String serviceName,
    required String requesterName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: approved
          ? ServicesNotificationEvent.requestInProgress
          : ServicesNotificationEvent.requestRejected,
      pageKey: ServicesNotificationPage.serviceProviderDashboard.key,
      senderEmail: senderEmail,
      receiverEmail: providerEmail,
      isArabic: isArabic,
      variables: {
        TemplateVariable.serviceName: serviceName,
        TemplateVariable.requesterName: requesterName,
        TemplateVariable.rejectionReason: '',
      },
    );
  }

  /// Tell the requester the request status changed by the employee
  /// (in progress / done).
  /// Template: services_request_in_progress / services_request_done
  Future<bool> notifyRequesterOfProgress({
    required String requestId,
    required bool isDone,
    required String senderEmail,
    required String requesterEmail,
    required String serviceName,
    required bool isArabic,
    Map<TemplateVariable, String> extraVariables = const {},
  }) {
    return _send(
      event: isDone
          ? ServicesNotificationEvent.requestDone
          : ServicesNotificationEvent.requestInProgress,
      pageKey: ServicesNotificationPage.requestServicesToggle.key,
      senderEmail: senderEmail,
      receiverEmail: requesterEmail,
      isArabic: isArabic,
      requestId: requestId.trim(),
      variables: {TemplateVariable.serviceName: serviceName, ...extraVariables},
    );
  }

  /// Tell the assigned provider a new request landed in their queue.
  /// Template: services_new_assignment_provider
  Future<bool> notifyProviderOfAssignment({
    required String requestId,
    required String senderEmail,
    required String providerEmail,
    required String serviceName,
    required bool isArabic,
  }) {
    return _send(
      event: ServicesNotificationEvent.newAssignmentProvider,
      pageKey: ServicesNotificationPage.serviceProviderDashboard.key,
      senderEmail: senderEmail,
      receiverEmail: providerEmail,
      isArabic: isArabic,
      requestId: requestId.trim(),
      variables: {TemplateVariable.serviceName: serviceName},
    );
  }

  /// SLA escalation. `event` picks who is being warned and how urgently:
  /// requester (exceeded), manager (approaching / breached) or the
  /// provider (reminder).
  Future<bool> notifyOfSla({
    required String requestId,
    required ServicesNotificationEvent event,
    required String senderEmail,
    required String receiverEmail,
    required String serviceName,
    required bool isArabic,
  }) {
    assert(
      const {
        ServicesNotificationEvent.requestSlaExceed,
        ServicesNotificationEvent.slaApproachingManager,
        ServicesNotificationEvent.slaBreachedManager,
        ServicesNotificationEvent.slaReminderProvider,
      }.contains(event),
      '${event.key} is not an SLA event',
    );
    return _send(
      event: event,
      pageKey: ServicesNotificationPage.requestServicesToggle.key,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      requestId: requestId.trim(),
      variables: {TemplateVariable.serviceName: serviceName},
    );
  }

  /// Nudge the approver that a request is still sitting unreviewed.
  ///
  /// Distinct from [notifyOfSla]: this fires on the review clock (the
  /// request has not been looked at), whereas the SLA events fire on the
  /// fulfilment clock (the request has not been finished).
  /// Template: services_review_reminder_manager → page: ApprovalRequestCard
  Future<bool> notifyManagerOfPendingReview({
    required String requestId,
    required String senderEmail,
    required String managerEmail,
    required String serviceName,
    required bool isArabic,
  }) {
    return _send(
      event: ServicesNotificationEvent.reviewReminderManager,
      pageKey: ServicesNotificationPage.approvalRequestCard.key,
      senderEmail: senderEmail,
      receiverEmail: managerEmail,
      isArabic: isArabic,
      requestId: requestId.trim(),
      variables: {TemplateVariable.serviceName: serviceName},
    );
  }

  /// Tell the assigned provider a request was cancelled and can be dropped
  /// from their queue.
  /// Template: services_request_cancelled → page: ServiceProviderDashboard
  Future<bool> notifyProviderOfCancellation({
    required String requestId,
    required String senderEmail,
    required String providerEmail,
    required String serviceName,
    required bool isArabic,
  }) {
    return _send(
      event: ServicesNotificationEvent.requestCancelled,
      pageKey: ServicesNotificationPage.serviceProviderDashboard.key,
      senderEmail: senderEmail,
      receiverEmail: providerEmail,
      isArabic: isArabic,
      requestId: requestId.trim(),
      variables: {TemplateVariable.serviceName: serviceName},
    );
  }

  /// Ask the provider to close a request out once the work is done.
  ///
  /// The requester-facing counterpart is [notifyRequesterOfProgress] with
  /// `isDone: true`; this one is addressed to the provider and asks for a
  /// status update rather than announcing the outcome.
  /// Template: services_completion_confirmed_provider
  ///           → page: ServiceProviderDashboard
  Future<bool> notifyProviderOfCompletion({
    required String requestId,
    required String senderEmail,
    required String providerEmail,
    required String serviceName,
    required bool isArabic,
  }) {
    return _send(
      event: ServicesNotificationEvent.completionConfirmedProvider,
      pageKey: ServicesNotificationPage.serviceProviderDashboard.key,
      senderEmail: senderEmail,
      receiverEmail: providerEmail,
      isArabic: isArabic,
      requestId: requestId.trim(),
      variables: {TemplateVariable.serviceName: serviceName},
    );
  }
}
