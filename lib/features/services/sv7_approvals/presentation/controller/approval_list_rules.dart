/// Module: services / sv7_approvals / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: approval_list_rules.dart
/// Purpose: The rules of the approvals list — whose turn it is, the chip
///          counts, the status / department / search filter and the sort.
///          Moved out of the page (Requests R1: no counting or filtering in
///          widgets); [ApprovalRequestCubit] calls these.
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/domain/enums/request_sort.dart';
import 'package:knowticed_plus/features/services/domain/enums/service_duration_unit.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/controller/approval_request_state.dart';

/// Class Name: [ApprovalListRules]
///
/// Purpose: Pure functions over the signed-in approver's requests.
abstract final class ApprovalListRules {
  static const List<String> _waiting = ['pending', 'normal', ''];

  /// Lower-cased, trimmed, without invisible direction marks.
  static String sanitizeEmail(String email) {
    return email.toLowerCase().trim().replaceAll(RegExp(r'[‎‏‪‫‬‭‮⁦⁧⁨⁩]'), '');
  }

  static int _indexOf(List<ServiceEmployeeModel> cycle, String email) {
    final me = sanitizeEmail(email);
    return cycle.indexWhere((e) => sanitizeEmail(e.email ?? '') == me);
  }

  /// True when every approver before [email] approved and [email] has not
  /// decided yet.
  static bool isMyTurn(List<ServiceEmployeeModel> cycle, String email) {
    final idx = _indexOf(cycle, email);
    if (idx == -1) return false;
    for (int i = 0; i < idx; i++) {
      if ((cycle[i].state ?? '').toLowerCase() != 'approved') return false;
    }
    return _waiting.contains((cycle[idx].state ?? '').toLowerCase());
  }

  /// [email]'s own state in the cycle ('' when absent).
  static String myEntryState(List<ServiceEmployeeModel> cycle, String email) {
    final idx = _indexOf(cycle, email);
    if (idx == -1) return '';
    return (cycle[idx].state ?? '').toLowerCase();
  }

  static bool _rejectedBefore(List<ServiceEmployeeModel> cycle, int myIdx) {
    for (int i = 0; i < myIdx; i++) {
      if ((cycle[i].state ?? '').toLowerCase() == 'rejected') return true;
    }
    return false;
  }

  /// Function Name: [countFor]
  ///
  /// Purpose: The chip counts for [email]: cancelled requests count as
  /// cancelled whatever the approver did; then approved, rejected, or
  /// pending when it is their turn.
  static ApprovalRequestCounts countFor(
    List<ServicesHistoryModel> approvals,
    String email,
  ) {
    int pending = 0, approved = 0, rejected = 0, canceled = 0;
    for (final service in approvals) {
      final cycle = service.currentApprovalCycle;
      if (_indexOf(cycle, email) == -1) continue;
      final myState = myEntryState(cycle, email);
      if (service.currentState.toLowerCase() == 'cancel') {
        canceled++;
      } else if (myState == 'approved') {
        approved++;
      } else if (myState == 'rejected') {
        rejected++;
      } else if (isMyTurn(cycle, email)) {
        pending++;
      }
    }
    return ApprovalRequestCounts(
      total: pending + approved + rejected + canceled,
      pending: pending,
      approved: approved,
      rejected: rejected,
      cancel: canceled,
    );
  }

  /// Function Name: [filter]
  ///
  /// Purpose: The requests shown for the chosen status chip, departments
  /// (compared by id) and search text (English or Arabic name).
  ///
  /// Parameters:
  /// - [departmentOf]: the requester's department id, or null.
  static List<ServicesHistoryModel> filter({
    required List<ServicesHistoryModel> approvals,
    required String email,
    required String statusKey,
    required Set<String> departmentIds,
    required String query,
    required String? Function(String requesterEmail) departmentOf,
  }) {
    final q = query.toLowerCase().trim();
    return approvals.where((service) {
      final cycle = service.currentApprovalCycle;
      final myIndex = _indexOf(cycle, email);
      if (myIndex == -1) return false;

      final myState = myEntryState(cycle, email);
      final finalState = RequestStatus.of(service).toLowerCase();
      // A cancelled request is nobody's outstanding work: cancel wins over
      // the approver's own cycle entry (same rule as the counts).
      final isCanceled = finalState == 'cancel';

      final bool matchesChip;
      switch (statusKey) {
        case 'all':
          matchesChip = myState == 'approved' ||
              myState == 'rejected' ||
              isMyTurn(cycle, email) ||
              [
                'done',
                'cancel',
                'inprogress',
                'branchsla',
                'breached sla',
              ].contains(finalState);
          break;
        case 'approved':
          matchesChip = !isCanceled && myState == 'approved';
          break;
        case 'rejected':
          matchesChip = !isCanceled && myState == 'rejected';
          break;
        case 'pending':
          matchesChip = !isCanceled &&
              isMyTurn(cycle, email) &&
              !_rejectedBefore(cycle, myIndex) &&
              _waiting.contains(myState);
          break;
        case 'cancel':
          matchesChip = isCanceled;
          break;
        default:
          matchesChip = finalState == statusKey;
      }
      if (!matchesChip) return false;

      if (departmentIds.isNotEmpty) {
        final departmentId = departmentOf(service.currentEmailRequester);
        if (departmentId == null || !departmentIds.contains(departmentId)) {
          return false;
        }
      }

      return q.isEmpty ||
          service.currentServiceNameEnglish.toLowerCase().trim().contains(q) ||
          service.currentServiceNameArabic.toLowerCase().trim().contains(q);
    }).toList();
  }

  static int _first(ServicesHistoryModel m) =>
      m.timestamps.isEmpty ? 0 : m.timestamps.first;

  static int _last(ServicesHistoryModel m) =>
      m.timestamps.isEmpty ? 0 : m.timestamps.last;

  static double _durationHours(ServicesHistoryModel m) {
    final value = double.tryParse(m.currentDurationOfServices.toString()) ?? 0;
    final unit = ServiceDurationUnit.parse(m.currentSelectedDurationUnit);
    return unit == null ? value : value * unit.hours;
  }

  /// Function Name: [sort]
  ///
  /// Purpose: Newest first by request date or last update, shortest first
  /// by duration. Returns a new list.
  static List<ServicesHistoryModel> sort(
    List<ServicesHistoryModel> source,
    RequestSort option,
  ) {
    final list = List<ServicesHistoryModel>.from(source);
    switch (option) {
      case RequestSort.duration:
        list.sort((a, b) => _durationHours(a).compareTo(_durationHours(b)));
        break;
      case RequestSort.lastUpdate:
        list.sort((a, b) => _last(b).compareTo(_last(a)));
        break;
      case RequestSort.dateRequested:
        list.sort((a, b) => _first(b).compareTo(_first(a)));
        break;
    }
    return list;
  }
}
