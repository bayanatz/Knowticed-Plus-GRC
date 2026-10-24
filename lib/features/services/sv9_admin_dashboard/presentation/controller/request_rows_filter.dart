/// Module: services_management_module
/// ******************* FILE INFO *******************
/// File Name: request_rows_filter.dart
/// Description: The ONE search / filter applied to the dashboard request rows,
///              used by the tablet table, the phone list AND the export
///              (SVC-DASH-09, SVC-DASH-10). The phone list used to ignore the
///              search and the Filter dialog, the tablet table re-downloaded
///              every request on each keystroke, and Export saved the
///              unfiltered list.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
/// *************************************************
library;

import 'package:knowticed_plus/features/services/data/utils/dashboard_metrics.dart';
import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';

class RequestRowsFilter {
  const RequestRowsFilter._();

  /// Rows of [rows] that match [search] (service, requester, provider,
  /// department, status — both languages), one of [departments] (names in
  /// either language or ids, compared by id through [departmentNameToId]),
  /// one of [statuses], and — when set — were made on [date].
  static List<Map<String, dynamic>> apply(
    List<Map<String, dynamic>> rows, {
    String search = '',
    List<String> departments = const [],
    List<String> statuses = const [],
    DateTime? date,
    String? Function(String departmentName)? departmentNameToId,
  }) {
    final q = search.trim().toLowerCase();
    String deptKey(String value) {
      final v = value.trim();
      if (v.isEmpty) return '';
      return departmentNameToId?.call(v) ?? v.toLowerCase();
    }

    final wantedDepartments =
        departments.map(deptKey).where((d) => d.isNotEmpty).toSet();
    final wantedStatuses =
        statuses.map(DashboardMetrics.normalizeState).toSet();

    return rows.where((row) {
      if (wantedDepartments.isNotEmpty &&
          !wantedDepartments.contains(
            deptKey(row['department']?.toString() ?? ''),
          )) {
        return false;
      }

      // SVC-DASH-08: one status vocabulary on both sides.
      if (wantedStatuses.isNotEmpty &&
          !wantedStatuses.contains(
            DashboardMetrics.normalizeState(row['status']?.toString() ?? ''),
          )) {
        return false;
      }

      if (date != null) {
        final raw = row['raw'];
        final created = raw is Map<String, dynamic>
            ? RequestDates.createdAtFromRaw(raw)
            : null;
        if (created == null ||
            created.year != date.year ||
            created.month != date.month ||
            created.day != date.day) {
          return false;
        }
      }

      if (q.isEmpty) return true;
      const fields = [
        'serviceName',
        'serviceNameArabic',
        'requestor',
        'firstNameRequesterArabic',
        'lastNameRequesterArabic',
        'provider',
        'firstNameProviderArabic',
        'lastNameProviderArabic',
        'department',
        'status',
        'jobTitleRequester',
        'jobTitleRequesterArabic',
      ];
      return fields.any(
        (f) => (row[f]?.toString().toLowerCase() ?? '').contains(q),
      );
    }).toList();
  }
}
