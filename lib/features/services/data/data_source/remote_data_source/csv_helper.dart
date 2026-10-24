/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: csv_helper.dart
/// Purpose: CSV export helper (CSVHelper) and employeeFunctionHelper
///          (csv_helper_state_updates.dart). The provider-selection copy
///          (csv_helper_provider_lite.dart) and the unused state functions
///          were deleted: providers are picked only by ServiceProviderSelector.
/// Author: Amr Mesbah
/// Date: 30/8/2025
/// Dependencies: csv, path_provider, cloud_firestore, get, core/network/get_base_url.dart,
///               core/network/api_constants.dart, data/models/service_employee_model.dart,
///               data/models/services_management_module.dart
/// Revision History: Initial version — split out of services_helper_function.dart
///                    (deleted; see audit fix #1) to satisfy the 800-LOC file cap.
library;

import 'dart:convert';

import 'package:knowticed_plus/core/di/app_controllers.dart';

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:knowticed_plus/core/helper/export_directory.dart';
// REMOVED 30/8/2026: path_provider — the only call was the
// getApplicationDocumentsDirectory() in saveCsvToFile, now behind
// ExportDirectory. No `part` of this library uses it.

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

part 'csv_helper_state_updates.dart';

class CSVHelper {
  String createCsv(List<List<dynamic>> rows) {
    return Csv(autoDetect: false).encode(rows);
  }

  Future<File> saveCsvToFile(String csvData, String fileName) async {
    // FIXED 30/8/2026: the `else` branch here sent macOS, Windows and Linux to
    // `getApplicationDocumentsDirectory()`. Under `com.apple.security.app-sandbox`
    // that is the container's Documents folder, not `~/Documents`, so every
    // services CSV was written where the user could not find it. The Android
    // branch was already right and is preserved inside ExportDirectory.
    final Directory directory = await ExportDirectory.resolve();

    final path = '${directory.path}${Platform.pathSeparator}$fileName.csv';
    final file = File(path);

    List<int> csvBytes = utf8.encode(csvData);
    List<int> bom = [0xEF, 0xBB, 0xBF]; // Excel compatibility BOM

    return await file.writeAsBytes(bom + csvBytes);
  }

  Future<File> exportToCSV(List<List<dynamic>> rows, String fileName) async {
    final csv = createCsv(rows);
    return await saveCsvToFile(csv, fileName);
  }
}
