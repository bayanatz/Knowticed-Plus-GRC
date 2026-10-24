/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: media_handler.dart
/// Description: `MediaHandler`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:io';

import 'package:dartz/dartz.dart' show Either;
import 'package:dio/dio.dart';
import 'package:knowticed_plus/core/helper/csv_helper.dart' as core_csv;
import 'package:path_provider/path_provider.dart';

/// Downloads a file and saves it where the user can open it.
class MediaHandler {
  final String appName = "Knowticed plus";

  /// Get the app-specific directory
  Future<String> _getAppDirectory() async {
    // Temporary staging folder only; the final copy goes through
    // CSVHelper.exportBytesForUser (FB-RESULT-03).
    final directory = await getTemporaryDirectory();
    final appDir = Directory("${directory.path}/$appName");
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir.path;
  }

  /// Download the file if it doesn't exist
  Future<File> downloadFile(String fileUrl, String fileName,
      {String path = ''}) async {
    final appDirPath = await _getAppDirectory();

    // Remove query parameters from filename
    fileName = fileName.split('?').first;

    // FIX: Only decode if the string actually contains valid percent encoding
    try {
      // Check if the string contains % followed by valid hex characters
      if (fileName.contains('%') &&
          RegExp(r'%[0-9A-Fa-f]{2}').hasMatch(fileName)) {
        fileName = Uri.decodeComponent(fileName);
      }
    } catch (e) {
      // If decoding fails, just continue with the original filename
    }

    // Replace invalid characters with underscore
    fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]|[\x00-\x1F]'), '_');

    // Trim whitespace from both ends
    fileName = fileName.trim();

    // Handle long filenames
    const maxLength = 120;
    if (fileName.length > maxLength) {
      final ext = fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '';
      final base = fileName.substring(0, maxLength - ext.length - 1);
      fileName = '${base}_${DateTime.now().millisecondsSinceEpoch % 10000}$ext';
    }

    // Build the full file path
    final filePath =
        path.isEmpty ? "$appDirPath/$fileName" : "$appDirPath/$path/$fileName";

    // Optional: Check if file exists
    /*
    final file = await _checkFileExists(fileName);
    if (file != null) {
      return file; // File already exists
    }
    */

    // Create directory if path is provided
    if (path.isNotEmpty) {
      final dir = Directory("$appDirPath/$path");
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }

    // FB-RESULT-03: the file is downloaded to a temporary folder, then saved
    // where the user can open it through the same path as the PDF / CSV
    // exports (system save sheet on phones, the Downloads folder on desktop).
    // It used to stay in the app's private Documents folder, which the user
    // cannot open. Any failure is thrown to the caller, which shows it.
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    await dio.download(fileUrl, filePath);

    final File downloaded = File(filePath);
    final List<int> bytes = await downloaded.readAsBytes();
    final int dot = fileName.lastIndexOf('.');
    final String baseName = dot > 0 ? fileName.substring(0, dot) : fileName;
    final String extension = dot > 0 ? fileName.substring(dot + 1) : 'bin';
    final Either<String, String> saved = await core_csv.CSVHelper()
        .exportBytesForUser(
            fileName: baseName, extension: extension, bytes: bytes);
    if (await downloaded.exists()) {
      await downloaded.delete();
    }
    final String? error = saved.fold((String e) => e, (String _) => null);
    if (error != null) throw Exception(error);
    return File(saved.getOrElse(() => ''));
  }

  /// Get the file path (checks if the file exists or downloads it)
  Future<String> getFilePath(String fileUrl, String fileName) async {
    final file = await downloadFile(fileUrl, fileName);
    return file.path;
  }
}
