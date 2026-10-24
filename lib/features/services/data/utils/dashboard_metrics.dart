/// Module: services_management_module
/// ******************* FILE INFO *******************
/// File Name: dashboard_metrics.dart
/// Description: The ONE set of rules every Services dashboard counts with, so
///              the Admin Dashboard, the department dashboard and the service
///              details page agree:
///   • status      — one resolver; "cancel"/"canceled" are both "cancel"
///                   (SVC-DASH-08).
///   • month       — the month the request was MADE (first timestamp), in the
///                   selected year only (SVC-DASH-02).
///   • "Number of services" — every request made, except rejected and
///                   cancelled ones (SVC-DASH-03).
///   • hours       — planned hours of COMPLETED requests only: the service's
///                   current duration for each done request. Requests are
///                   saved without a duration, so the service's is used
///                   (SVC-DASH-04).
///   • history fields — the CURRENT value is the last entry (SVC-DASH-14).
/// Author: Amr Mesbah
/// Created at: 18/10/2026
/// *************************************************
library;

import 'dart:convert';

import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';

import 'package:knowticed_plus/features/services/domain/enums/service_duration_unit.dart';

class DashboardMetrics {
  const DashboardMetrics._();

  /// Statuses that count as a "completed" request.
  static const Set<String> completedStates = {'done', 'branchsla'};

  /// The current value of a history field (last entry), as a string.
  static String current(Object? value) {
    if (value == null) return '';
    if (value is List) {
      for (var i = value.length - 1; i >= 0; i--) {
        final item = value[i]?.toString().trim() ?? '';
        if (item.isNotEmpty) return item;
      }
      return '';
    }
    return value.toString();
  }

  /// Normalises a stored status to the module's single vocabulary.
  static String normalizeState(String raw) {
    final s = raw.trim().toLowerCase();
    switch (s) {
      case 'canceled':
      case 'cancelled':
        return 'cancel';
      case 'breached sla':
        return 'branchsla';
      case 'in progress':
        return 'inprogress';
      default:
        return s;
    }
  }

  /// Final status of a raw request document.
  static String finalState(Map<String, dynamic> data) {
    final stored = normalizeState(current(data['state']));
    const known = {
      'done',
      'inprogress',
      'cancel',
      'branchsla',
      'approved',
      'pending',
      'rejected',
    };
    if (known.contains(stored)) return stored;

    final cycle = data['Approval_Cycle'];
    if (cycle is List && cycle.isNotEmpty && cycle.last is String) {
      try {
        final decoded = jsonDecode(cycle.last as String);
        if (decoded is List) {
          final states = decoded
              .whereType<Map>()
              .map((e) => normalizeState(e['state']?.toString() ?? ''))
              .where((s) => s.isNotEmpty)
              .toList();
          if (states.contains('cancel')) return 'cancel';
          if (states.contains('rejected')) return 'rejected';
          if (states.isNotEmpty && states.every((s) => s == 'approved')) {
            return 'approved';
          }
        }
      } on FormatException {
        return 'pending';
      }
    }
    return 'pending';
  }

  /// SVC-DASH-03: whether a request counts towards "Number of services".
  static bool countsAsService(String state) =>
      state != 'rejected' && state != 'cancel';

  /// SVC-DASH-02: 0-based month the request was made in, or null when it was
  /// not made in [year] (or has no date).
  static int? monthIndex(Map<String, dynamic> data, int year) {
    final created = RequestDates.createdAtFromRaw(data);
    if (created == null || created.year != year) return null;
    return created.month - 1;
  }

  /// An empty 12-month series.
  static Map<int, double> emptyMonths() => {for (var i = 0; i < 12; i++) i: 0};

  /// Converts a duration to hours (English and Arabic, singular and plural)
  /// through the module's one unit parser, [ServiceDurationUnit] (H13).
  static double toHours(double value, String unit) {
    final parsed = ServiceDurationUnit.parse(unit);
    return parsed == null ? 0 : value * parsed.hours;
  }

  /// SVC-DASH-04: planned hours of one request — only when it is completed —
  /// using the request's own duration, else the service's current duration.
  static double plannedHoursIfDone({
    required String state,
    required Map<String, dynamic> request,
    Map<String, dynamic>? service,
  }) {
    if (!completedStates.contains(state)) return 0;
    var duration = current(request['Duration_Of_Services']);
    var unit = current(request['Selected_Duration_Unit']);
    if ((duration.isEmpty || unit.isEmpty) && service != null) {
      duration = current(service['Duration_Of_Services']);
      unit = current(service['Selected_Duration_Unit']);
    }
    final value = double.tryParse(duration) ?? 0;
    if (value <= 0) return 0;
    return toHours(value, unit);
  }
}
