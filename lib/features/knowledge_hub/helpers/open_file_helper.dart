/// Module: knowledge_hub/data/utils
///
///*************************** FILE INFO ****************************///
/// File Name: open_file_helper.dart
/// Description: Opens a downloaded file in another app.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
/// Updated: 7/10/2026 - Replaces the old file-opener package, which declared
/// READ_MEDIA_IMAGES / VIDEO / AUDIO in its own manifest and got the app
/// rejected under the Play "Photo and Video Permissions" policy. Do not add
/// any package that declares those permissions.
///
/// - Android / iOS: the system share sheet (share_plus). The user picks the
///   app that opens the file (PDF viewer, Drive, Word...). No permission needed.
/// - macOS / Windows / Linux: opens the file in its default app (url_launcher).
library;

import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class OpenFileHelper {
  /// Returns true when the file was handed to another app.
  static Future<bool> open(String filePath) async {
    final File file = File(filePath);
    if (!await file.exists()) {
      log('OpenFileHelper: file not found $filePath');
      return false;
    }

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final ShareResult result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(filePath)],
            // iPad needs an anchor for the share popover or it throws.
            sharePositionOrigin: _screenCenter(),
          ),
        );
        log('OpenFileHelper: share status ${result.status}');
        return result.status != ShareResultStatus.unavailable;
      }
      return await launchUrl(Uri.file(filePath));
    } catch (e) {
      log('OpenFileHelper: failed to open $filePath: $e');
      return false;
    }
  }

  static Rect _screenCenter() {
    final views = PlatformDispatcher.instance.views;
    if (views.isEmpty) return const Rect.fromLTWH(0, 0, 1, 1);
    final view = views.first;
    final Size size = view.physicalSize / view.devicePixelRatio;
    return Rect.fromLTWH(size.width / 2, size.height / 2, 1, 1);
  }
}
