/// Module: services / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: approval_decision_service.dart
/// Purpose: The ONE approve / reject flow: saves the decision through
///          CreateServicesRepository.decideApproval, then tells the
///          requester, the next approver and (on the final approval or a
///          rejection) the provider through ServicesNotificationService.
///          The approvals list card and the approval details page both use
///          it; they used to keep two copies that had already drifted apart.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/domain/entities/approval_decision.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

/// What came of one approve / reject.
class ApprovalOutcome {
  const ApprovalOutcome._({
    required this.saved,
    this.refusal,
    this.notificationFailed = false,
  });

  /// The decision was saved.
  const ApprovalOutcome.saved({bool notificationFailed = false})
      : this._(saved: true, notificationFailed: notificationFailed);

  /// The decision was refused (see [refusal]) or could not be saved.
  const ApprovalOutcome.notSaved([ApprovalRefusal? refusal])
      : this._(saved: false, refusal: refusal);

  final bool saved;

  /// Why the decision was refused, when it was.
  final ApprovalRefusal? refusal;

  /// Saved, but at least one notification could not be sent.
  final bool notificationFailed;
}

/// The names shown in the notifications, in both languages.
class ApprovalNames {
  const ApprovalNames({
    required this.serviceEnglish,
    required this.serviceArabic,
    required this.requesterEnglish,
    required this.requesterArabic,
  });

  final String serviceEnglish;
  final String serviceArabic;
  final String requesterEnglish;
  final String requesterArabic;
}

class ApprovalDecisionService {
  /// Created once at the module root.
  const ApprovalDecisionService({
    required this.repository,
    required this.notifications,
  });

  final CreateServicesRepository repository;
  final ServicesNotificationService notifications;

  /// Function Name: [decide]
  ///
  /// Purpose: Approves or rejects request [docId] for [approverEmail] and
  /// sends the notifications. Notifications never undo a saved decision.
  ///
  /// Parameters:
  /// - [docId]: the request id.
  /// - [approverEmail]: who decides.
  /// - [approve]: approve (true) or reject (false).
  /// - [comment]: the approver's comment.
  /// - [names]: service and requester names for the notifications.
  /// - [requesterEmail]: the requester, when the caller knows it.
  ///
  /// Returns: the [ApprovalOutcome].
  Future<ApprovalOutcome> decide({
    required String docId,
    required String approverEmail,
    required bool approve,
    required String comment,
    required ApprovalNames names,
    String? requesterEmail,
  }) async {
    final ApprovalDecision decision;
    try {
      decision = await repository.decideApproval(
        docId: docId,
        approverEmail: approverEmail,
        approve: approve,
        comment: comment,
      );
    } on ApprovalNotAllowed catch (e) {
      if (kDebugMode) svcLog('Approval refused: ${e.reason.name}');
      return ApprovalOutcome.notSaved(e.reason);
    } catch (e) {
      if (kDebugMode) svcLog('Saving the approval failed: $e');
      return const ApprovalOutcome.notSaved();
    }

    final requester = (requesterEmail?.isNotEmpty ?? false)
        ? requesterEmail!
        : decision.requesterEmail;
    final results = <bool>[];

    if (requester.isNotEmpty) {
      final approver = await _approverNames(approverEmail);
      results.add(
        await notifications.notifyRequesterOfDecision(
          requestId: docId,
          approved: approve,
          approverEmail: approverEmail,
          requesterEmail: requester,
          serviceName: names.serviceEnglish,
          approverName: approver.$1,
          approverNameArabic: approver.$2,
          isArabic: false,
        ),
      );
    }

    // The provider hears about the final approval and about a rejection.
    if ((!approve || decision.isFinalApproval) &&
        decision.providerEmail.isNotEmpty) {
      results.add(
        await notifications.notifyProviderOfDecision(
          approved: approve,
          senderEmail: approverEmail,
          providerEmail: decision.providerEmail,
          serviceName: names.serviceEnglish,
          requesterName: names.requesterEnglish,
          isArabic: false,
        ),
      );
    }

    if (approve && decision.nextApproverEmail.isNotEmpty) {
      results.add(
        await notifications.notifyApproverOfNewRequest(
          requestId: docId,
          senderEmail: approverEmail,
          approverEmail: decision.nextApproverEmail,
          serviceName: names.serviceEnglish,
          serviceNameArabic: names.serviceArabic,
          requesterName: names.requesterEnglish,
          requesterNameArabic: names.requesterArabic,
          isArabic: false,
        ),
      );
    }

    return ApprovalOutcome.saved(notificationFailed: results.contains(false));
  }

  /// The approver's English and Arabic names, from the users collection.
  Future<(String, String)> _approverNames(String approverEmail) async {
    try {
      final data = await repository.getUserByEmail(approverEmail);
      if (data == null) return ('', '');
      final first = data['firstName']?.toString() ?? '';
      final last = data['lastName']?.toString() ?? '';
      final firstAr = data['firstNameInArabic']?.toString() ?? first;
      final lastAr = data['lastNameInArabic']?.toString() ?? last;
      return ('$first $last'.trim(), '$firstAr $lastAr'.trim());
    } catch (e) {
      if (kDebugMode) svcLog('Reading the approver name failed: $e');
      return ('', '');
    }
  }
}
