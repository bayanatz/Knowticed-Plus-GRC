/// Module: services_management_module
/// ******************* FILE INFO *******************
/// File Name: approval_decision.dart
/// Description: Result of an approve / reject written by
///              CreateServicesRepository.decideApproval (SVC-REQ-05/06), and
///              the reason a decision was refused.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
/// *************************************************
library;

/// What happened after an approver's decision was saved — enough for the
/// caller to send the right notifications.
class ApprovalDecision {
  /// True when this approver was the last one and approved.
  final bool isFinalApproval;

  /// The next approver to notify, or empty when there is none.
  final String nextApproverEmail;

  /// The provider assigned to the request (notified on final approval and on
  /// rejection), or empty.
  final String providerEmail;

  /// The requester's e-mail, or empty.
  final String requesterEmail;

  const ApprovalDecision({
    required this.isFinalApproval,
    required this.nextApproverEmail,
    required this.providerEmail,
    required this.requesterEmail,
  });
}

/// Why an approve / reject was refused.
enum ApprovalRefusal {
  /// The request no longer exists.
  notFound,

  /// The request is not pending any more (cancelled, rejected, approved, ...).
  notPending,

  /// The approver is not in the cycle, already decided, or an earlier
  /// approver has not approved yet.
  notYourTurn,
}

class ApprovalNotAllowed implements Exception {
  final ApprovalRefusal reason;

  const ApprovalNotAllowed(this.reason);

  @override
  String toString() => 'ApprovalNotAllowed(${reason.name})';
}
