/// Module: services / sv10_services_provider / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: provider_request_rules.dart
/// Purpose: The status rules of the provider's queue and request page —
///          which status a request shows, which approver is next, and which
///          status the provider may move it to. Moved out of the pages
///          (Provider rule 2: no business logic in widgets).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';

/// Class Name: [ProviderRequestRules]
///
/// Purpose: Pure functions over one request, shared by the list and the
/// request page so both show the same status (SVC-PROV-18).
abstract final class ProviderRequestRules {
  static bool _allApproved(List<ServiceEmployeeModel> cycle) =>
      cycle.isNotEmpty &&
      cycle.every(
        (e) => (e.state ?? '').toLowerCase() == RequestStatus.approved,
      );

  /// Function Name: [effectiveState]
  ///
  /// Purpose: The status the request page starts from: the saved status,
  /// except that a pending request whose approvers ALL approved counts as
  /// approved. A pending request with no approvers stays pending.
  static String effectiveState(ServicesHistoryModel request) {
    final saved = request.currentState.toLowerCase();
    final waiting = saved.isEmpty || saved == RequestStatus.pending;
    if (waiting && _allApproved(request.currentApprovalCycle)) {
      return RequestStatus.approved;
    }
    return saved;
  }

  /// Function Name: [displayCycle]
  ///
  /// Purpose: The approval cycle as shown: decided entries keep their
  /// status, the first undecided approver is "pending" and the ones after
  /// are "normal" (not their turn yet).
  static List<ServiceEmployeeModel> displayCycle(
    List<ServiceEmployeeModel> cycle,
  ) {
    final adjusted = List<ServiceEmployeeModel>.from(cycle);
    var foundPending = false;
    for (var i = 0; i < adjusted.length; i++) {
      final state = (adjusted[i].state ?? '').toLowerCase();
      if (state == RequestStatus.approved ||
          state == RequestStatus.rejected ||
          state == RequestStatus.cancel) {
        continue;
      }
      adjusted[i] = adjusted[i].copyWith(
        state: foundPending ? 'normal' : RequestStatus.pending,
      );
      foundPending = true;
    }
    return adjusted;
  }

  /// Function Name: [showsStatusMenu]
  ///
  /// Purpose: Whether the provider gets the status menu: never for a
  /// cancelled request; otherwise once the request is approved (or every
  /// approver approved), in progress or done.
  static bool showsStatusMenu(String state, List<ServiceEmployeeModel> cycle) {
    final s = state.toLowerCase();
    if (s == RequestStatus.cancel) return false;
    const open = {
      RequestStatus.approved,
      RequestStatus.inProgress,
      RequestStatus.done,
    };
    if (open.contains(s)) return true;
    return _allApproved(cycle);
  }

  /// Function Name: [nextStates]
  ///
  /// Purpose: The statuses the menu offers from [state]: approved → in
  /// progress, in progress → done; done is final.
  static List<String> nextStates(String state) {
    final s = state.toLowerCase();
    if (s == RequestStatus.done || s == RequestStatus.inProgress) {
      return const [RequestStatus.done];
    }
    return const [RequestStatus.inProgress];
  }
}
