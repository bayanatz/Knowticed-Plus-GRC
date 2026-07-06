// ******************* FILE INFO *******************
// File Name: media_picker_service
// Description: Centralised wrapper around file/image pickers (§20 / §21).
// Module: core / services
// *************************************************

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Result of picking a document/spreadsheet.
class PickedFileData {
  final List<int> bytes;
  final String name;
  final String? path;

  const PickedFileData({required this.bytes, required this.name, this.path});
}

/// Result of picking an image.
class PickedImageData {
  final Uint8List bytes;

  /// Local file path, or null on web.
  final String? path;

  const PickedImageData({required this.bytes, this.path});
}

/// Single place that owns `FilePicker` / `ImagePicker`. Widgets, pages and
/// cubits must depend on this service instead of touching the picker plugins
/// directly (§16 / §20 / §21).
class MediaPickerService {
  MediaPickerService();

  final ImagePicker _imagePicker = ImagePicker();

  /// Picks a single Excel file and returns its bytes + name, or null when the
  /// user cancels or the file cannot be read.
  Future<PickedFileData?> pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    List<int>? bytes;
    if (file.path != null) {
      final f = File(file.path!);
      if (await f.exists()) bytes = await f.readAsBytes();
    } else if (file.bytes != null) {
      bytes = file.bytes;
    }
    if (bytes == null) return null;

    return PickedFileData(bytes: bytes, name: file.name, path: file.path);
  }

  /// Picks an image from the camera or gallery. Returns its path/name/bytes,
  /// or null when the user cancels.
  Future<PickedFileData?> pickImage({
    required bool fromCamera,
    int imageQuality = 70,
  }) async {
    final image = await _imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: imageQuality,
    );
    if (image == null) return null;
    final bytes = await image.readAsBytes();
    return PickedFileData(bytes: bytes, name: image.name, path: image.path);
  }

  /// Picks a single document (pdf/doc/docx by default). Returns null on cancel.
  Future<PickedFileData?> pickDocument({
    List<String> extensions = const ['pdf', 'doc', 'docx'],
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    if (file.path == null && file.bytes == null) return null;
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    return PickedFileData(bytes: bytes, name: file.name, path: file.path);
  }

  /// Picks any single file with no type restriction (e.g. logo uploads that
  /// validate their own extension after picking). Returns null on cancel.
  Future<PickedFileData?> pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    if (file.path == null && file.bytes == null) return null;
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    return PickedFileData(bytes: bytes, name: file.name, path: file.path);
  }

  /// Picks a single gallery image. Returns its bytes (+ path on non-web), or
  /// null when the user cancels.
  Future<PickedImageData?> pickGalleryImage({
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 80,
  }) async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
    if (image == null) return null;

    final bytes = await image.readAsBytes();
    return PickedImageData(bytes: bytes, path: kIsWeb ? null : image.path);
  }
}
