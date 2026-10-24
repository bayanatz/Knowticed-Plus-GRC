/// Module: services / data / utils
///
///*************************** FILE INFO ****************************///
/// File Name: request_status.dart
/// Purpose: The ONE rule for the current status of a service request, used
///          by the request lists, the approvals page, the provider queue and
///          every dashboard. Before this, six copies returned different
///          values for the same request ('cancel' vs 'canceled',
///          'In Progress' vs 'inprogress', 'breached sla' vs 'branchsla').
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/dashboard_metrics.dart';

/// Canonical status values. Compare against these, never against text.
class RequestStatus {
  const RequestStatus._();

  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String cancel = 'cancel';
  static const String inProgress = 'inprogress';
  static const String breachedSla = 'branchsla';
  static const String done = 'done';

  /// Every status, in the order the filters list them.
  static const List<String> all = [
    pending,
    approved,
    inProgress,
    done,
    rejected,
    cancel,
    breachedSla,
  ];

  /// Function Name: [normalize]
  ///
  /// Purpose: Maps any stored spelling to the canonical value
  /// ('canceled' → 'cancel', 'In Progress' → 'inprogress',
  /// 'breached sla' → 'branchsla').
  ///
  /// Parameters:
  /// - [raw]: the stored value.
  ///
  /// Returns: the canonical value (lower-case).
  static String normalize(String? raw) =>
      DashboardMetrics.normalizeState(raw ?? '');

  /// Function Name: [of]
  ///
  /// Purpose: The current status of a request: a final outer state (cancel,
  /// done, in progress, breached SLA) wins; otherwise the approval cycle
  /// decides (cancel → rejected → all approved → pending); otherwise the
  /// outer state, or pending.
  ///
  /// Parameters:
  /// - [request]: the request.
  ///
  /// Returns: one of the canonical values.
  static String of(ServicesHistoryModel request) {
    final outer = normalize(request.currentState);
    if (outer == cancel ||
        outer == done ||
        outer == inProgress ||
        outer == breachedSla) {
      return outer;
    }

    final states = request.currentApprovalCycle
        .map((approver) => normalize(approver.state))
        .where((state) => state.isNotEmpty)
        .toList();
    if (states.isNotEmpty) {
      if (states.contains(cancel)) return cancel;
      if (states.contains(rejected)) return rejected;
      if (states.every((state) => state == approved)) return approved;
      if (states.contains(pending)) return pending;
    }

    return outer.isNotEmpty ? outer : pending;
  }
}
