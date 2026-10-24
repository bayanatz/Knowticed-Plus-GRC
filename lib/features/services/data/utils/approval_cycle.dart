/// Module: services / data / utils
///
///*************************** FILE INFO ****************************///
/// File Name: approval_cycle.dart
/// Purpose: Reads a request's approval cycle: which approver is next, and
///          whether the cycle was rejected, cancelled or fully approved.
///          Shared by the requester, approver and provider screens, which
///          each used to keep their own copy.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';

/// Helpers over a list of approvers in cycle order.
class ApprovalCycle {
  const ApprovalCycle._();

  /// Approver state shown before their turn comes.
  static const String waiting = 'normal';

  static String _state(ServiceEmployeeModel approver) =>
      (approver.state ?? '').trim().toLowerCase();

  static bool _isFinal(String state) =>
      state == 'approved' || state == 'rejected' || state == 'cancel';

  /// Function Name: [forDisplay]
  ///
  /// Purpose: A copy of [cycle] in which exactly the first approver who has
  /// not decided yet is 'pending' and the ones after are [waiting]; decided
  /// approvers keep their state.
  ///
  /// Parameters:
  /// - [cycle]: the approvers in order.
  ///
  /// Returns: the adjusted copy.
  static List<ServiceEmployeeModel> forDisplay(
    List<ServiceEmployeeModel> cycle,
  ) {
    var foundPending = false;
    final adjusted = <ServiceEmployeeModel>[];
    for (final approver in cycle) {
      if (_isFinal(_state(approver))) {
        adjusted.add(approver);
      } else if (!foundPending) {
        foundPending = true;
        adjusted.add(approver.copyWith(state: 'pending'));
      } else {
        adjusted.add(approver.copyWith(state: waiting));
      }
    }
    return adjusted;
  }

  /// Whether any approver rejected or cancelled.
  static bool hasRejection(List<ServiceEmployeeModel> cycle) =>
      cycle.any((a) => _state(a) == 'rejected' || _state(a) == 'cancel');

  /// The first approver who rejected or cancelled, or null.
  static ServiceEmployeeModel? firstRejection(
    List<ServiceEmployeeModel> cycle,
  ) {
    for (final approver in cycle) {
      final state = _state(approver);
      if (state == 'rejected' || state == 'cancel') return approver;
    }
    return null;
  }

  /// Whether any approver is in [state].
  static bool hasState(List<ServiceEmployeeModel> cycle, String state) =>
      cycle.any((a) => _state(a) == state.toLowerCase());

  /// Whether every approver approved (false for an empty cycle).
  static bool allApproved(List<ServiceEmployeeModel> cycle) =>
      cycle.isNotEmpty && cycle.every((a) => _state(a) == 'approved');

  /// E-mail of the approver whose turn it is, or null.
  static String? currentApproverEmail(List<ServiceEmployeeModel> cycle) {
    for (final approver in cycle) {
      if (_state(approver) == 'pending') return approver.email;
    }
    return null;
  }
}
