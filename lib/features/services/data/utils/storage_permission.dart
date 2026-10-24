/// Module: services / data / utils
///
///*************************** FILE INFO ****************************///
/// File Name: storage_permission.dart
/// Purpose: The one storage-permission request used before reading an Excel
///          file in the services module (rules C1/C8: was copied into two
///          pages, each with its own try/catch).
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';

/// Class Name: [ServicesStoragePermission]
///
/// Purpose: Asks for file access on Android. Other platforms (iOS, web,
/// desktop) read the picked file without it.
class ServicesStoragePermission {
  const ServicesStoragePermission._();

  /// Function Name: [request]
  ///
  /// Purpose: Asks for storage access when the platform needs it.
  ///
  /// Returns: `true` when the file can be read. A plugin failure is logged
  /// and treated as granted, so the picker itself decides.
  static Future<bool> request() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    try {
      var status = await Permission.storage.status;
      if (status.isGranted) return true;
      if (status.isDenied) {
        status = await Permission.storage.request();
        if (status.isGranted) return true;
      }
      if (status.isPermanentlyDenied) {
        var manage = await Permission.manageExternalStorage.status;
        if (manage.isDenied) {
          manage = await Permission.manageExternalStorage.request();
        }
        return manage.isGranted;
      }
      return status.isGranted;
    } catch (e, st) {
      svcLog('storage permission request failed', error: e, stackTrace: st);
      return true;
    }
  }
}
