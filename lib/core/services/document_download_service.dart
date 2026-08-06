/// Module: Core · Services · Document Download Service
/// Description: Owns Dio download + storage-permission + destination-path
///              resolution for downloading a document to device storage, so
///              presentation services_management_module no longer call Dio/Permission/File
///              directly (§3 / §11 / §16).
/// Author: Knowticed Team
/// Date: 01/07/2026
/// Dependencies: dio, permission_handler, path_provider
/// Revision History:
///   - 01/07/2026: Extracted from AboutThisAppScreen._downloadPDF().
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

///*************************** FILE INFO ****************************///
/// File Name: document_download_service.dart
/// Purpose: Download a remote document to local device storage.

/// Result of a successful [DocumentDownloadService.downloadToDeviceStorage]
/// call.
class DownloadedFile {
  final String path;
  final String fileName;

  const DownloadedFile({required this.path, required this.fileName});
}

/// Thrown when the user denies the storage permission required to download
/// on Android.
class StoragePermissionDeniedException implements Exception {
  @override
  String toString() => 'Storage permission was not granted.';
}

class DocumentDownloadService {
  /// Resolves the platform-appropriate downloads directory.
  Future<String?> _resolveDownloadPath() async {
    if (Platform.isAndroid) {
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        return directory.path;
      }

      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        final downloadDir = Directory('${appDir.path}/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir.path;
      }
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        return directory.path;
      }

      final home =
          Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (home != null) {
        String downloadPath;
        if (Platform.isMacOS || Platform.isLinux) {
          downloadPath = '$home/Downloads';
        } else if (Platform.isWindows) {
          downloadPath = '$home\\Downloads';
        } else {
          return null;
        }

        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return downloadPath;
      }
    }
    return null;
  }

  Future<bool> _ensureAndroidStoragePermission() async {
    if (!Platform.isAndroid) return true;

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    // For Android 11+ (API 30+), also try manage external storage.
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    return status.isGranted;
  }

  /// Downloads [url] to the resolved platform download directory as
  /// [fileNamePrefix]_<timestamp>.<extension>. Throws
  /// [StoragePermissionDeniedException] if the Android storage permission is
  /// denied, or a plain [Exception] if the download path can't be resolved.
  Future<DownloadedFile> downloadToDeviceStorage({
    required String url,
    required String fileNamePrefix,
    String extension = 'pdf',
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    final hasPermission = await _ensureAndroidStoragePermission();
    if (!hasPermission) {
      throw StoragePermissionDeniedException();
    }

    final downloadPath = await _resolveDownloadPath();
    if (downloadPath == null) {
      throw Exception('Could not determine download path');
    }

    final fileName =
        '${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final filePath = '$downloadPath/$fileName';

    final dio = Dio();
    await dio.download(
      url,
      filePath,
      onReceiveProgress: onReceiveProgress,
    );

    return DownloadedFile(path: filePath, fileName: fileName);
  }
}
