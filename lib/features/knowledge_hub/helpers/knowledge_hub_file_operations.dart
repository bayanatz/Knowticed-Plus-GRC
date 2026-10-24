/// Module: knowledge_hub/data/utils
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_file_operations.dart
/// Description: `_refreshFirebaseStorageUrl()`, `downloadFile()`, `_downloadFileAndroid()` and 6 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/open_file_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

// ============= HELPER FUNCTIONS FOR FILE OPERATIONS =============

/// Refresh Firebase Storage URL to fix expired token (402 error)
Future<String> _refreshFirebaseStorageUrl(String fileUrl) async {
  try {
    final uri = Uri.parse(fileUrl);
    final pathSegments = uri.path.split('/o/');

    if (pathSegments.length > 1) {
      final storagePath = Uri.decodeComponent(pathSegments[1].split('?').first);
      khLog('📂 Storage path extracted: $storagePath');
      final ref = FirebaseStorage.instance.ref(storagePath);
      final freshUrl = await ref.getDownloadURL();
      khLog('✅ Fresh Firebase URL obtained');
      return freshUrl;
    }
  } catch (e) {
    khLog('⚠️ Could not refresh Firebase URL, using original: $e');
  }
  return fileUrl;
}

/// Download file to device's Downloads folder (Cross-platform)
Future<bool> downloadFile(
  BuildContext context, {
  required String fileUrl,
  required String fileName,
}) async {
  try {
    khLog('🔽 Starting download for: $fileName');
    khLog('📍 Original URL: $fileUrl');

    // ✅ STEP 1: Refresh Firebase Storage URL to fix 402 expired token
    final freshUrl = await _refreshFirebaseStorageUrl(fileUrl);
    khLog('📍 Fresh URL: $freshUrl');

    // ✅ STEP 2: Extract file extension using fresh URL
    String finalFileName = fileName;
    if (!fileName.contains('.')) {
      try {
        final uri = Uri.parse(freshUrl);
        final urlPath = uri.path;
        if (urlPath.contains('.')) {
          final extension = urlPath.substring(urlPath.lastIndexOf('.'));
          finalFileName = '$fileName$extension';
          khLog('📝 Added extension from path: $finalFileName');
        }
      } catch (e) {
        khLog('⚠️ Could not extract extension from URL: $e');
      }
    }

    khLog('✅ Final filename: $finalFileName');

    // ✅ STEP 3: Download using freshUrl
    if (Platform.isAndroid) {
      return await _downloadFileAndroid(freshUrl, finalFileName);
    } else if (Platform.isIOS) {
      if (!context.mounted) return false;
      return await _downloadFileIOS(context, freshUrl, finalFileName);
    } else {
      return await _downloadFileDesktop(freshUrl, finalFileName);
    }
  } catch (e) {
    khLog('❌ Error downloading file: $e');
    khLog('Stack trace: ${StackTrace.current}');
    return false;
  }
}

/// Download file on Android devices
Future<bool> _downloadFileAndroid(String fileUrl, String fileName) async {
  try {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    khLog('📱 Android SDK: $sdkInt');

    if (sdkInt >= 33) {
      khLog('✅ Android 13+, no permission needed');
    } else if (sdkInt >= 30) {
      var status = await Permission.manageExternalStorage.status;
      khLog('📋 MANAGE_EXTERNAL_STORAGE status: $status');
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          khLog('❌ MANAGE_EXTERNAL_STORAGE permission denied');
          return false;
        }
      }
      khLog('✅ MANAGE_EXTERNAL_STORAGE granted');
    } else {
      var status = await Permission.storage.status;
      khLog('📋 Storage permission status: $status');
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          khLog('❌ Storage permission denied');
          return false;
        }
      }
      khLog('✅ Storage permission granted');
    }

    final dio = Dio();

    if (sdkInt >= 29) {
      khLog('📲 Using scoped storage (Android 10+)');

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$fileName';

      khLog('⏳ Downloading to temp: $tempPath');
      await dio.download(
        fileUrl,
        tempPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            khLog('⏳ Download progress: $progress%');
          }
        },
      );

      final tempFile = File(tempPath);
      if (!await tempFile.exists()) {
        khLog('❌ Temp file does not exist');
        return false;
      }

      final fileSize = await tempFile.length();
      khLog('✅ Temp file downloaded: $fileSize bytes');

      final params = SaveFileDialogParams(
        sourceFilePath: tempPath,
        fileName: fileName,
      );

      final finalPath = await FlutterFileDialog.saveFile(params: params);

      try {
        await tempFile.delete();
        khLog('🗑️ Temp file deleted');
      } catch (e) {
        khLog('⚠️ Could not delete temp file: $e');
      }

      if (finalPath != null) {
        khLog('✅ File saved to: $finalPath');
        return true;
      } else {
        khLog('❌ User cancelled save dialog');
        return false;
      }
    } else {
      khLog('📲 Using legacy storage (Android 9 and below)');

      Directory? downloadDir = Directory('/storage/emulated/0/Download');
      if (!await downloadDir.exists()) {
        khLog('⚠️ /Download not found, trying /Downloads');
        downloadDir = Directory('/storage/emulated/0/Downloads');
      }

      if (!await downloadDir.exists()) {
        khLog('❌ Downloads directory not found, using external storage');
        downloadDir = await getExternalStorageDirectory();
      }

      final downloadPath = '${downloadDir?.path}/$fileName';
      khLog('📂 Download path: $downloadPath');

      await dio.download(
        fileUrl,
        downloadPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            khLog('⏳ Download progress: $progress%');
          }
        },
      );

      final file = File(downloadPath);
      if (await file.exists()) {
        final fileSize = await file.length();
        khLog('✅ File downloaded: $fileSize bytes at $downloadPath');
        return true;
      } else {
        khLog('❌ File does not exist after download');
        return false;
      }
    }
  } catch (e) {
    khLog('❌ Android download error: $e');
    return false;
  }
}

/// Download file on iOS devices
Future<bool> _downloadFileIOS(
  BuildContext context,
  String fileUrl,
  String fileName,
) async {
  try {
    khLog('📱 iOS download starting');

    final dio = Dio();

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$fileName';

    khLog('⏳ Downloading to temp: $tempPath');
    await dio.download(
      fileUrl,
      tempPath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          khLog('⏳ Download progress: $progress%');
        }
      },
    );

    final tempFile = File(tempPath);
    if (!await tempFile.exists()) {
      khLog('❌ Temp file does not exist');
      return false;
    }

    final fileSize = await tempFile.length();
    khLog('✅ Temp file downloaded: $fileSize bytes');

    final params = SaveFileDialogParams(
      sourceFilePath: tempPath,
      fileName: fileName,
    );

    final finalPath = await FlutterFileDialog.saveFile(params: params);

    try {
      await tempFile.delete();
      khLog('🗑️ Temp file deleted');
    } catch (e) {
      khLog('⚠️ Could not delete temp file: $e');
    }

    if (finalPath != null) {
      khLog('✅ File saved via iOS share sheet');
      return true;
    } else {
      khLog('❌ User cancelled save dialog');
      return false;
    }
  } catch (e) {
    khLog('❌ iOS download error: $e');
    return false;
  }
}

/// Download file on Desktop (Windows/macOS/Linux)
Future<bool> _downloadFileDesktop(String fileUrl, String fileName) async {
  try {
    khLog('💻 Desktop download starting');

    final dio = Dio();

    Directory? downloadDir = await getDownloadsDirectory();

    if (downloadDir == null) {
      khLog('⚠️ getDownloadsDirectory returned null, trying alternatives');

      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          downloadDir = Directory('$userProfile\\Downloads');
          khLog('🪟 Windows Downloads path: ${downloadDir.path}');
        }
      } else if (Platform.isMacOS) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          downloadDir = Directory('$home/Downloads');
          khLog('🍎 macOS Downloads path: ${downloadDir.path}');
        }
      } else if (Platform.isLinux) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          downloadDir = Directory('$home/Downloads');
          khLog('🐧 Linux Downloads path: ${downloadDir.path}');
        }
      }

      if (downloadDir == null || !await downloadDir.exists()) {
        khLog('⚠️ Downloads directory not found, using Documents');
        downloadDir = await getApplicationDocumentsDirectory();
      }
    }

    // Make sure the target directory exists before writing. On macOS the
    // sandbox container's Downloads folder (or the Documents fallback) may not
    // have been created yet, which would otherwise fail file creation.
    try {
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
        khLog('📁 Created download directory: ${downloadDir.path}');
      }
    } catch (e) {
      khLog('⚠️ Could not ensure download directory exists: $e');
    }

    final downloadPath =
        '${downloadDir.path}${Platform.pathSeparator}$fileName';
    khLog('📂 Download path: $downloadPath');

    await dio.download(
      fileUrl,
      downloadPath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          khLog('⏳ Download progress: $progress%');
        }
      },
    );

    final file = File(downloadPath);
    if (await file.exists()) {
      final fileSize = await file.length();
      khLog('✅ File downloaded: $fileSize bytes');
      khLog('✅ Location: $downloadPath');
      return true;
    } else {
      khLog('❌ File does not exist after download');
      return false;
    }
  } catch (e) {
    khLog('❌ Desktop download error: $e');
    return false;
  }
}

/// View file inside the application
Future<bool> viewFileInApp(
  BuildContext context, {
  required String fileUrl,
  required String fileName,
}) async {
  try {
    khLog('👁️ Opening file: $fileName');
    khLog('📍 URL: $fileUrl');

    // ✅ Refresh Firebase Storage URL first
    final freshUrl = await _refreshFirebaseStorageUrl(fileUrl);

    String finalFileName = fileName;
    if (!fileName.contains('.')) {
      final uri = Uri.parse(freshUrl);
      final urlPath = uri.path;
      final extension = urlPath.substring(urlPath.lastIndexOf('.'));
      finalFileName = '$fileName$extension';
      khLog('📝 Added extension: $finalFileName');
    }

    if (!finalFileName.contains('.')) {
      try {
        final uri = Uri.parse(freshUrl);
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          final lastSegment = segments.last;
          if (lastSegment.contains('.')) {
            final extension = lastSegment.substring(
              lastSegment.lastIndexOf('.'),
            );
            finalFileName = '$fileName$extension';
            khLog('📝 Extracted extension from path: $finalFileName');
          }
        }
      } catch (e) {
        khLog('⚠️ Could not extract extension from URL: $e');
      }
    }

    khLog('✅ Final filename: $finalFileName');

    final dio = Dio();
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$finalFileName';

    khLog('📂 Cache path: $filePath');

    final file = File(filePath);
    // ✅ Always re-download with fresh URL (avoids stale cached 402 file)
    khLog('⏳ Downloading file to cache with fresh URL...');
    await dio.download(
      freshUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          khLog('⏳ Loading file: $progress%');
        }
      },
    );
    khLog('✅ File cached successfully');

    if (await file.exists()) {
      final fileSize = await file.length();
      khLog('📄 File size: $fileSize bytes');

      if (fileSize == 0) {
        khLog('❌ File is empty');
        return false;
      }
    } else {
      khLog('❌ File does not exist after download');
      return false;
    }

    khLog('🚀 Opening file with default app...');
    final bool opened = await OpenFileHelper.open(filePath);
    khLog(opened ? '✅ File opened successfully' : '❌ Failed to open file');
    return opened;
  } catch (e) {
    khLog('❌ Error viewing file: $e');
    khLog('Stack trace: ${StackTrace.current}');
    return false;
  }
}

// ============= DIALOG FUNCTIONS =============

void showLoadingDialog(BuildContext context, String message) {
  showAppDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          width: 411.w,
          height: 200.h,
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleProgressMaster(),
              SizedBox(height: 16.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showSuccessDialog(BuildContext context, String message) {
  showAppDialog(
    context: context,
    barrierDismissible: true,
    useRootNavigator: true,
    builder: (dialogContext) {
      Future.delayed(Duration(seconds: 2), () {
        if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
          Navigator.of(dialogContext).pop();
        }
      });

      return Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          width: 411.w,
          height: 200.h,
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                width: 70.w,
                height: 70.h,
                fit: BoxFit.scaleDown,
                repeat: true,
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showErrorDialog(BuildContext context, String message) {
  showAppDialog(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) {
      return Material(
        color: AppColors.transparent,
        child: Center(
          child: Container(
            width: 411.sp,
            // 14/10/2026 — KH mobile report p.27: a fixed 273.sp height left a
            // band of empty card under the OK button on phones. The dialog is
            // now exactly as tall as its content.
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
            ),
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AppColors.red, size: 48.sp),
                SizedBox(height: 16.h),
                Text(
                  message,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                customButton(
                  title: S.of(context).ok,
                  function: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
