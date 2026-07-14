/// Module: GRC Policy Management
/// Description: Data model for uploaded policy/control document metadata.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: file_picker
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Added `file` + fromPlatformFile factory so
///                                the picked file can be uploaded, not just
///                                displayed.
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_document_info.dart
/// Purpose: Contains PolicyDocumentInfo, an immutable model for a picked
///          document's display metadata plus the actual File to upload.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// class name: [PolicyDocumentInfo]
///
/// purpose: immutable value object that carries display metadata (name,
///          formatted size, formatted date) plus the actual [File] to
///          upload for a picked document.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyDocumentInfo {
  final String name;
  final String sizeLabel;
  final String dateLabel;
  final File file;

  const PolicyDocumentInfo({
    required this.name,
    required this.sizeLabel,
    required this.dateLabel,
    required this.file,
  });

  /// function name: [fromPlatformFile]
  ///
  /// purpose: build a [PolicyDocumentInfo] straight from the [PlatformFile]
  ///          returned by `showUploadDialog`'s onSubmit callback.
  ///
  /// parameters:
  ///            [PlatformFile] platformFile: the file picked via file_picker
  ///
  /// return type: [PolicyDocumentInfo]
  factory PolicyDocumentInfo.fromPlatformFile(PlatformFile platformFile) {
    return PolicyDocumentInfo(
      name: platformFile.name,
      sizeLabel: _formatBytes(platformFile.size),
      dateLabel: _formatToday(),
      file: File(platformFile.path!),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String _formatToday() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
