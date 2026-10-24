/// Module: services_management_module
/// ******************* FILE INFO *******************
/// File Name: request_dates.dart
/// Description: The ONE definition of "when a request was made": the FIRST
///              entry of its `timestamps` history. Used by the provider list
///              (SVC-PROV-08) and the dashboards (SVC-DASH-02/13/20), which
///              used the last status change, a field new requests do not
///              have, or "now" for a missing date.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
/// *************************************************
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

class RequestDates {
  const RequestDates._();

  /// When [request] was made, or null when it has no timestamps.
  static DateTime? createdAt(ServicesHistoryModel request) =>
      request.timestamps.isEmpty
          ? null
          : DateTime.fromMillisecondsSinceEpoch(request.timestamps.first);

  /// Same as [createdAt], from a raw request document map.
  static DateTime? createdAtFromRaw(Map<String, dynamic> data) {
    final ts = data['timestamps'];
    final first = ts is List && ts.isNotEmpty ? ts.first : ts;
    if (first is int) return DateTime.fromMillisecondsSinceEpoch(first);
    if (first is num) return DateTime.fromMillisecondsSinceEpoch(first.toInt());
    if (first is Timestamp) return first.toDate();
    if (first is DateTime) return first;
    if (first is String) return DateTime.tryParse(first);
    return null;
  }

  /// "dd MMM yyyy", or "-" for a missing date (never today's date).
  static String format(DateTime? date, {String? locale}) =>
      date == null ? '-' : DateFormat('dd MMM yyyy', locale).format(date);

  /// Sort key: newest first; requests without a date go last.
  static int compareNewestFirst(
    ServicesHistoryModel a,
    ServicesHistoryModel b,
  ) {
    final da = createdAt(a);
    final db = createdAt(b);
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  }
}
