/// Module: knowledge_hub/data/utils
///
///*************************** FILE INFO ****************************///
/// File Name: file_preview_loader.dart
/// Description: Downloads and parses files for the in-app viewers (Excel,
///              CSV, video). The failure handling lives HERE, so the viewer
///              widgets need no try/catch (Rule Bug 4 — "no try/catch in
///              pages, widgets, models or domain").
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

/// A parsed spreadsheet ready to draw: every row padded to [maxColumns].
class SheetPreview {
  const SheetPreview({
    required this.sheetNames,
    required this.sheetName,
    required this.rows,
    required this.maxColumns,
  });

  final List<String> sheetNames;
  final String sheetName;
  final List<List<String>> rows;
  final int maxColumns;
}

class FilePreviewLoader {
  const FilePreviewLoader._();

  /// Downloads [url]. Throws on a non-200 answer — the FutureBuilder that
  /// calls this shows its error state.
  static Future<List<int>> fetchBytes(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to download file: ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  /// The first sheet of an Excel file, or null when it cannot be parsed.
  static SheetPreview? parseExcel(List<int> bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);
      final names = excel.tables.keys.toList();
      if (names.isEmpty) {
        return const SheetPreview(
          sheetNames: [],
          sheetName: '',
          rows: [],
          maxColumns: 0,
        );
      }
      final sheet = excel.tables[names.first]!;
      final width = sheet.maxColumns;
      final rows = sheet.rows
          .map(
            (r) => List<String>.generate(
              width,
              (i) => i < r.length ? (r[i]?.value?.toString() ?? '') : '',
            ),
          )
          .toList();
      return SheetPreview(
        sheetNames: names,
        sheetName: names.first,
        rows: rows,
        maxColumns: width,
      );
    } catch (e) {
      khLog('Error parsing Excel: $e', name: 'FilePreviewLoader');
      return null;
    }
  }

  /// The rows of a CSV file, or null when it cannot be parsed.
  static List<List<dynamic>>? parseCsv(List<int> bytes) {
    try {
      return Csv(
        autoDetect: false,
        skipEmptyLines: false,
      ).decode(utf8.decode(bytes));
    } catch (e) {
      khLog('Error parsing CSV: $e', name: 'FilePreviewLoader');
      return null;
    }
  }

  /// An initialised video controller, or null when the video cannot load.
  static Future<VideoPlayerController?> initVideo(String url) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
      return controller;
    } catch (e) {
      khLog('Error initializing video: $e', name: 'FilePreviewLoader');
      await controller.dispose();
      return null;
    }
  }
}
