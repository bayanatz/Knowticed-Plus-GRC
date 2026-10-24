/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: admin_dashboard_export.dart
/// Purpose: Writes the admin dashboard's request list to a CSV file in the
///          folder the user can open, with translated headers, statuses and
///          dates, in both languages where the data has both.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/export_directory.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_durations.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/dashboard/service_request_row.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/home_services_dialog.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/admin_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AdminExportService {
  const AdminExportService._();

  static bool _isExporting = false;

  /// The UTF-8 byte-order mark: makes Excel read Arabic as UTF-8.
  static const List<int> _utf8Bom = <int>[0xEF, 0xBB, 0xBF];

  /// [value] as one CSV field (quoted when it holds a comma, quote or
  /// line break).
  static String _field(Object? value) {
    final text = value?.toString() ?? '';
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  static String _join(Object? first, Object? last) =>
      '${first ?? ''} ${last ?? ''}'.trim();

  static void _snack(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: AppColors.white,
      duration: ServicesDurations.errorDialog,
    );
  }

  /// Writes [displayedItems] to [fileName] (".csv" added when missing).
  /// The department column is written when [selectedDepartment] is
  /// [DashboardAdminCubit.allDepartments], like the table.
  static Future<bool> exportRequestsToCSV({
    required BuildContext context,
    required String fileName,
    required List<Map<String, dynamic>> displayedItems,
    String? selectedDepartment,
  }) async {
    if (_isExporting) return false;
    final s = S.of(context);

    if (fileName.isEmpty) {
      _snack(s.error, s.pleaseEnterFileName, AppColors.orange);
      return false;
    }
    if (displayedItems.isEmpty) {
      _snack(s.noData, s.dbNoRequestsToExport, AppColors.orange);
      return false;
    }

    final withDepartment =
        selectedDepartment == DashboardAdminCubit.allDepartments;
    final en = s.english;
    final ar = s.arabic;
    final locale = Localizations.localeOf(context).languageCode;

    final rows = <List<String>>[
      [
        s.number,
        if (withDepartment) s.Department,
        '${s.ServiceName} ($en)',
        '${s.ServiceName} ($ar)',
        '${s.ServiceRequestor} ($en)',
        '${s.ServiceRequestor} ($ar)',
        s.dbRequesterDepartment,
        '${s.jobTitle} ($en)',
        '${s.jobTitle} ($ar)',
        s.requestDate,
        s.Status,
        '${s.ServiceProvider} ($en)',
        '${s.ServiceProvider} ($ar)',
      ],
      for (var i = 0; i < displayedItems.length; i++)
        _requestRow(context, displayedItems[i], i, withDepartment, locale),
    ];

    final finalName =
        fileName.toLowerCase().endsWith('.csv') ? fileName : '$fileName.csv';

    _isExporting = true;
    final saved = await _write(finalName, rows);
    _isExporting = false;

    if (!context.mounted) return saved;
    if (!saved) {
      _snack(s.exportFailed, s.errorOccurred, AppColors.red);
      return false;
    }
    await showSuccessDialogMaster(
      lottiePath: ServicesLottie.approved,
      title: s.download,
      subtitle: s.successDownloadFile,
      context: context,
    );
    return true;
  }

  static List<String> _requestRow(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
    bool withDepartment,
    String locale,
  ) {
    final row = ServiceRequestRow(item, index);
    final department = row.department(context);
    return [
      row.number(context),
      if (withDepartment) department,
      '${item['serviceName'] ?? ''}',
      '${item['serviceNameArabic'] ?? ''}',
      _join(item['firstNameRequester'], item['lastNameRequester']),
      _join(item['firstNameRequesterArabic'], item['lastNameRequesterArabic']),
      department,
      '${item['jobTitleRequester'] ?? ''}',
      '${item['jobTitleRequesterArabic'] ?? ''}',
      RequestDates.format(
        ServiceRequestRow.dateOf(item['requestDate']),
        locale: locale,
      ),
      row.statusLabel(context),
      _join(item['firstNameProvider'], item['lastNameProvider']),
      _join(item['firstNameProviderArabic'], item['lastNameProviderArabic']),
    ].map(_field).toList();
  }

  /// Writes the rows; false (and logged) when the file cannot be written.
  static Future<bool> _write(String fileName, List<List<String>> rows) async {
    final csv = StringBuffer();
    for (final row in rows) {
      csv.writeln(row.join(','));
    }
    try {
      final directory = await ExportDirectory.resolve();
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(_utf8Bom + utf8.encode(csv.toString()));
      return true;
    } catch (e, st) {
      svcLog('[AdminExportService] export failed: $e\n$st');
      return false;
    }
  }
}
