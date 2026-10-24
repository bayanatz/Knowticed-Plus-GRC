/// Module: knowledge_hub/data/utils
/// ************************* FILE INFO *************************** ///
/// File Name: submission_date_formatter.dart
/// Description: Formats submission dates/times from mixed sources (Firestore
///          Timestamp, millis int, ISO string, TimeOfDay map). Owns the
///          cloud_firestore Timestamp handling so the S5 screen UI stays free
///          of the data SDK (CR-KH-S5 §3).
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Pure formatting helpers for submission date/time values.
///
/// [locale] (a language tag such as `ar` or `en`) makes the date and time
/// come out in that language — digits, month names and AM/PM — from the
/// locale data instead of hand-made replacements. Without it the output is
/// the same as before.
abstract class SubmissionDateFormatter {
  /// Formats a date from Timestamp / int millis / ISO string / List.
  static String? formatDateTime(dynamic timestamp, {String? locale}) {
    final DateTime? date = _toDate(timestamp);
    return date == null ? null : DateFormat('dd MMM yyyy', locale).format(date);
  }

  /// Formats a time from String / Map (TimeOfDay serialization) / List.
  static String? formatTime(dynamic timeData, {String? locale}) {
    if (timeData is List) {
      if (timeData.isEmpty) return null;
      timeData = timeData.first;
    }
    int? hour;
    int? minute;
    if (timeData is Map) {
      hour = timeData['hour'] is int ? timeData['hour'] as int : 0;
      minute = timeData['minute'] is int ? timeData['minute'] as int : 0;
    } else if (timeData is String) {
      // Already formatted ("08:14 PM") — kept as stored.
      if (timeData.contains('AM') || timeData.contains('PM')) return timeData;
      final List<String> parts = timeData.split(':');
      if (parts.length != 2) return timeData;
      hour = int.tryParse(parts[0].trim());
      minute = int.tryParse(parts[1].trim());
      if (hour == null || minute == null) return timeData;
    } else {
      return null;
    }
    return DateFormat(
      'hh:mm a',
      locale,
    ).format(DateTime(2000, 1, 1, hour, minute));
  }

  static DateTime? _toDate(dynamic timestamp) {
    if (timestamp is List) {
      if (timestamp.isEmpty) return null;
      timestamp = timestamp.first;
    }
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (timestamp is String) {
      final int? ms = int.tryParse(timestamp);
      if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
      return DateTime.tryParse(timestamp);
    }
    return null;
  }
}
