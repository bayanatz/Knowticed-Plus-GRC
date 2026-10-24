/// Module: services / presentation / widgets / dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: service_request_row.dart
/// Purpose: Reads one dashboard request row (the maps the dashboard cubits
///          build) into the texts the request tables and cards show, in the
///          reader's language, with "-" for anything missing.
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';

class ServiceRequestRow {
  final Map<String, dynamic> item;
  final int index;
  final Map<String, String>? enToArDepartments;

  const ServiceRequestRow(this.item, this.index, {this.enToArDepartments});

  static const String _missing = '-';

  /// [value] as trimmed text, or '' when it is null, empty or "null".
  static String _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return (text.isEmpty || text.toLowerCase() == 'null' || text == 'N/A')
        ? ''
        : text;
  }

  static String _join(Object? first, Object? last) =>
      '${_text(first)} ${_text(last)}'.trim();

  /// The first non-empty of [candidates], or "-".
  static String _firstOf(List<String> candidates) {
    for (final c in candidates) {
      if (c.isNotEmpty) return c;
    }
    return _missing;
  }

  Map? get _provider =>
      item['selectedProvider'] is Map ? item['selectedProvider'] as Map : null;

  String number(BuildContext context) {
    final stored = item['no'];
    final no = stored is int ? stored : int.tryParse('${stored ?? ''}');
    // A missing or zero stored number falls back to the row position.
    return context.svcNumber((no == null || no <= 0) ? index + 1 : no);
  }

  String department(BuildContext context) {
    final department = _text(item['department']);
    if (department.isEmpty) return _missing;
    final arabic =
        context.svcIsArabic ? (enToArDepartments?[department]) : null;
    // Ids and names in either language resolve through the department list.
    return arabic ?? context.svcDepartmentName(department);
  }

  String serviceName(BuildContext context) => _firstOf([
        if (context.svcIsArabic) _text(item['serviceNameArabic']),
        _text(item['serviceName']),
      ]);

  String requesterName(BuildContext context) => _firstOf([
        if (context.svcIsArabic) ...[
          _join(item['firstNameRequesterArabic'],
              item['lastNameRequesterArabic']),
          _text(item['requestorArabic']),
        ],
        _text(item['requestor']),
        _join(item['firstNameRequester'], item['lastNameRequester']),
      ]);

  /// The job title, shortened to the abbreviation in brackets when there
  /// is one ("Senior Engineer (SE)" → "SE").
  String jobTitle(BuildContext context) {
    final title = _firstOf([
      if (context.svcIsArabic) _text(item['jobTitleRequesterArabic']),
      _text(item['jobTitleRequester']),
    ]);
    final abbreviation = RegExp(r'\(([^)]+)\)').firstMatch(title)?.group(1);
    return abbreviation ?? title;
  }

  String requestDate(BuildContext context) => RequestDates.format(
        dateOf(item['requestDate']),
        locale: Localizations.localeOf(context).languageCode,
      );

  String providerName(BuildContext context) {
    final provider = _provider;
    return _firstOf([
      if (context.svcIsArabic) ...[
        _join(item['firstNameProviderArabic'], item['lastNameProviderArabic']),
        if (provider != null)
          _join(provider['firstNameInArabic'], provider['lastNameInArabic']),
      ],
      _text(item['provider']),
      _join(item['firstNameProvider'], item['lastNameProvider']),
      if (provider != null) _join(provider['firstName'], provider['lastName']),
    ]);
  }

  String get status => _text(item['status']);

  /// [status]'s translated label, or "-".
  String statusLabel(BuildContext context) =>
      status.isEmpty ? _missing : context.svcStatus(status);

  /// Sort key for "newest request first"; rows without a date go last.
  static int compareNewestFirst(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final da = dateOf(a['requestDate']);
    final db = dateOf(b['requestDate']);
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  }

  bool get isRequesterMale => _isMale(item['gender']);

  bool get isProviderMale =>
      _isMale(_provider?['gender'] ?? item['providerGender']);

  static bool _isMale(Object? gender) =>
      gender?.toString().toLowerCase() == 'male';

  /// The request date in whatever form the cubit stored it.
  static DateTime? dateOf(Object? value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value > 1000000000000 ? value : value * 1000,
      );
    }
    if (value is Map && value['seconds'] != null) {
      final seconds = int.tryParse('${value['seconds']}');
      return seconds == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
    final text = _text(value);
    if (text.isEmpty) return null;
    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed;
    final iso = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(text);
    if (iso != null) {
      return DateTime(int.parse(iso.group(1)!), int.parse(iso.group(2)!),
          int.parse(iso.group(3)!));
    }
    final parts = text.split('/');
    if (parts.length >= 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }
}
