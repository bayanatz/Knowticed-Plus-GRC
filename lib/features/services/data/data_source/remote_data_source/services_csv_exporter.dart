/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: services_csv_exporter.dart
/// Purpose: Builds the services-list CSV rows and saves them through the
///          same CSVHelper.exportRowsForUser path the details export uses
///          (rule H11). Column titles and Yes/No/"No provider" texts come in
///          translated through [ServicesCsvLabels] (rules H21/H22).
/// Author: Knowticed Team
/// Updated: 18/10/2026 by Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';

/// Class Name: [ServicesCsvLabels]
///
/// Purpose: The translated texts the services CSV needs; built by the page
/// from `S.of(context)` so this data-layer class holds no UI text.
class ServicesCsvLabels {
  /// The 13 column titles, in column order.
  final List<String> headers;
  final String yes;
  final String no;
  final String noProvider;

  const ServicesCsvLabels({
    required this.headers,
    required this.yes,
    required this.no,
    required this.noProvider,
  });
}

/// Class Name: [ServicesCsvExporter]
///
/// Purpose: Owns the CSV-export business/IO logic that previously lived
/// inside the export dialog widget, so the widget needs no try/catch or file
/// access.
class ServicesCsvExporter {
  const ServicesCsvExporter();

  /// Function Name: [export]
  ///
  /// Purpose: Builds the CSV for [items] and saves it where the user can open
  /// it (Downloads on desktop, the system save sheet on phones).
  ///
  /// Returns: Left = error message; Right = saved path, or
  /// [CSVHelper.exportCancelled] when the user dismissed the save sheet.
  Future<Either<String, String>> export({
    required List<dynamic> items,
    required Map<dynamic, dynamic> selectedProviders,
    required String fileName,
    required ServicesCsvLabels labels,
  }) async {
    final List<List<dynamic>> rows;
    try {
      rows = buildRows(items, selectedProviders, labels);
    } catch (e, st) {
      svcLog('ServicesCsvExporter.buildRows failed', error: e, stackTrace: st);
      return Left('$e');
    }
    return CSVHelper().exportRowsForUser(fileName: fileName, rows: rows);
  }

  /// Function Name: [buildRows]
  ///
  /// Purpose: The header row followed by one row per service.
  List<List<dynamic>> buildRows(
    List<dynamic> items,
    Map<dynamic, dynamic> selectedProviders,
    ServicesCsvLabels labels,
  ) {
    final rows = <List<dynamic>>[labels.headers];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final serviceId = (item.currentId ?? '').toString();
      rows.add([
        i + 1,
        _safeGet(item.currentServiceNameEnglish),
        _safeGet(item.currentServiceNameArabic),
        _safeGet(item.currentServiceDescriptionEnglish),
        _safeGet(item.currentServiceDescriptionArabic),
        _safeGet(item.currentState),
        _safeGet(item.currentDurationOfServices),
        _safeGet(item.currentSelectedDurationUnit),
        _extractDepartments(item),
        _hasItems(item.currentSelectDepartment) ? labels.yes : labels.no,
        _hasItems(item.currentApprovalCycle) ? labels.yes : labels.no,
        _startDate(item),
        _providerName(serviceId, selectedProviders) ?? labels.noProvider,
      ]);
    }
    return rows;
  }

  /// The provider's name or email; `null` when the service has none.
  String? _providerName(
    String serviceId,
    Map<dynamic, dynamic> selectedProviders,
  ) {
    if (serviceId.isEmpty) return null;
    final provider = selectedProviders[serviceId];
    if (provider is! Map) return null;

    const firstKeys = [
      'firstName',
      'first_name',
      'FirstName',
      'firstname',
      'FIRSTNAME',
    ];
    const lastKeys = [
      'lastName',
      'last_name',
      'LastName',
      'lastname',
      'LASTNAME',
    ];

    String pick(List<String> keys) {
      for (final key in keys) {
        if (provider.containsKey(key)) return provider[key]?.toString() ?? '';
      }
      return '';
    }

    final firstName = pick(firstKeys);
    final lastName = pick(lastKeys);

    if (firstName.isEmpty && lastName.isEmpty) {
      final email = provider['email']?.toString() ?? '';
      return email.isNotEmpty ? email : null;
    }
    return '$firstName $lastName'.trim();
  }

  String _startDate(dynamic item) {
    final state = (item.currentState?.toLowerCase()?.trim() ?? '').toString();
    if (state == 'draft') return '-';

    final timestamps = item.timestamps;
    if (timestamps is List && timestamps.isNotEmpty) {
      final value = timestamps[0];
      if (value is int) {
        return _formatDateEnglish(Timestamp.fromMillisecondsSinceEpoch(value));
      } else if (value is Timestamp) {
        return _formatDateEnglish(value);
      }
    }
    if (item.durationOfServicesTimestamp != null) {
      return _formatDateEnglish(item.durationOfServicesTimestamp);
    }
    return '-';
  }

  /// Always formats in English (used for CSV regardless of UI locale).
  String _formatDateEnglish(dynamic date) {
    if (date == null) return '-';
    DateTime dateTime;
    if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(date);
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return '-';
    }
    return DateFormat('MMM dd, yyyy', 'en_US').format(dateTime);
  }

  String _extractDepartments(dynamic item) {
    final departments = item.currentSelectDepartment;
    if (departments is! List || departments.isEmpty) return '-';

    final names = <String>[];
    for (final dept in departments) {
      String deptName = '';
      if (dept is Map) {
        deptName = dept['departmentName']?.toString() ??
            dept['name']?.toString() ??
            dept['department']?.toString() ??
            '';
      } else if (dept is String) {
        deptName = dept;
      }
      if (deptName.isNotEmpty) names.add(deptName.trim());
    }
    return names.isEmpty ? '-' : names.join('; ');
  }

  bool _hasItems(dynamic value) => value is List && value.isNotEmpty;

  String _safeGet(dynamic value) =>
      value == null ? '' : value.toString().trim();
}
