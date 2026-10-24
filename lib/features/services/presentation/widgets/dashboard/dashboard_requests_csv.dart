/// Module: services / presentation / widgets / dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_requests_csv.dart
/// Purpose: Exports a dashboard request list (what the table shows) to a
///          CSV file — translated headers, statuses, names and dates — and
///          tells the user how it went. Shared by the department dashboard
///          and the admin dashboard details.
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/csv_helper.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_durations.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/dashboard/service_request_row.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/home_services_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class DashboardRequestsCsv {
  const DashboardRequestsCsv._();

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

  /// The CSV rows: a header row, then one row per request.
  static List<List<String>> rows(
    BuildContext context,
    List<Map<String, dynamic>> items, {
    Map<String, String>? enToArDepartments,
  }) {
    final s = S.of(context);
    return [
      [
        s.number,
        s.Department,
        s.ServiceName,
        s.ServiceRequestor,
        s.requestDate,
        s.Status,
        s.ServiceProvider,
      ],
      for (var i = 0; i < items.length; i++)
        () {
          final row = ServiceRequestRow(
            items[i],
            i,
            enToArDepartments: enToArDepartments,
          );
          return [
            row.number(context),
            row.department(context),
            row.serviceName(context),
            row.requesterName(context),
            row.requestDate(context),
            row.statusLabel(context),
            row.providerName(context),
          ];
        }(),
    ];
  }

  /// Writes [items] to [fileName].csv and shows the result.
  static Future<void> export(
    BuildContext context, {
    required List<Map<String, dynamic>> items,
    required String fileName,
    Map<String, String>? enToArDepartments,
  }) async {
    final s = S.of(context);
    final data = rows(context, items, enToArDepartments: enToArDepartments);

    final permission = await Permission.manageExternalStorage.request();
    if (!permission.isGranted) {
      _snack(
        s.dbStoragePermissionTitle,
        s.dbStoragePermissionMessage,
        AppColors.orange,
      );
      return;
    }

    var saved = true;
    try {
      await CSVHelper().exportToCSV(data, fileName);
    } catch (e, st) {
      svcLog('[DashboardRequestsCsv] export failed: $e\n$st');
      saved = false;
    }

    if (!saved) {
      _snack(s.exportFailed, s.dbExportFailedMessage, AppColors.red);
      return;
    }
    if (!context.mounted) return;
    await showSuccessDialogMaster(
      lottiePath: ServicesLottie.approved,
      context: context,
      title: s.exportSuccessful,
      subtitle: s.csvFileSaved,
    );
  }
}
