import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class MediaHandler {
  final String appName = "Knowticed plus";

  /// Get the app-specific directory
  Future<String> _getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
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
    fileName = fileName.split('?').first;

    // Decode URL-encoded characters (%20 → space, etc.)
    try {
      fileName = Uri.decodeComponent(fileName);
    } catch (e) {
      debugPrint('Ignored error: $e');
    }

    // Replace invalid characters with underscore
    fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]|[\x00-\x1F]'), '_');

    // Trim whitespace from both ends
    fileName = fileName.trim();
    const maxLength = 120;
    if (fileName.length > maxLength) {
      final ext = fileName.substring(fileName.lastIndexOf('.'));
      final base = fileName.substring(0, maxLength - ext.length - 1);
      fileName = '${base}_${DateTime.now().millisecondsSinceEpoch % 10000}$ext';
    }
    final filePath = "$appDirPath$path/$fileName";
    debugPrint("File path: $filePath");
/*
    final file = await _checkFileExists(fileName);
    if (file != null) {
      return file; // File already exists
    }*/

    // File does not exist, download it
    try {
      final dio = Dio();
      await dio.download(fileUrl, filePath);
      debugPrint("File downloaded to: $filePath");
      return File(filePath);
    } catch (e) {
      throw Exception("Failed to download file: $e");
    }
  }

  /// Get the file path (checks if the file exists or downloads it)
  Future<String> getFilePath(String fileUrl, String fileName) async {
    final file = await downloadFile(fileUrl, fileName);
    return file.path;
  }
}
