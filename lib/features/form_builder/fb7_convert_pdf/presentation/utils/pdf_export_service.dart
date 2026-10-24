/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: pdf_export_service.dart
/// Description: `PdfExportService`, renders the page boundaries on screen
///              into one PDF and saves it for the user. Moved out of
///              PdfCubit (Share rule 3).
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dartz/dartz.dart' show Either, Left;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:knowticed_plus/features/form_builder/helpers/fb_failure.dart';
import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Renders the page boundaries on screen into one PDF and saves it.
class PdfExportService {
  const PdfExportService({required this.csvHelper});

  /// Saves the bytes the way every export in the app does (injected).
  final CSVHelper csvHelper;

  /// Method Name: [export]
  ///
  /// Purpose: captures every built page boundary in [pageKeys] (pages that
  /// are not built are skipped) and saves the PDF through
  /// [CSVHelper.exportBytesForUser]: the system save sheet on phones, the
  /// Downloads folder on desktop (bug report p.34 / p.37 / p.64).
  ///
  /// Parameters:
  /// - [pageKeys]: the keys of the page boundaries.
  /// - [fileName]: the file name, without extension.
  /// - [horizontalPadding]: the form's horizontal padding.
  /// - [verticalPadding]: the form's vertical padding.
  ///
  /// Returns: Left = a translated error; Right = the saved path, or
  /// [CSVHelper.exportCancelled] when the user dismissed the save sheet.
  Future<Either<String, String>> export({
    required List<GlobalKey> pageKeys,
    required String fileName,
    required double horizontalPadding,
    required double verticalPadding,
  }) async {
    if (fileName.trim().isEmpty) {
      return Left(S.current.pleaseEnterFileName);
    }
    // Any capture or save error ends in "Download failed".
    return _export(
      pageKeys: pageKeys,
      fileName: fileName.trim(),
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
    ).catchError((Object e, StackTrace stackTrace) {
      fbFailure(e, stackTrace);
      return Left<String, String>(S.current.downloadFailed);
    });
  }

  Future<Either<String, String>> _export({
    required List<GlobalKey> pageKeys,
    required String fileName,
    required double horizontalPadding,
    required double verticalPadding,
  }) async {
    final pdf = pw.Document();
    int pagesAdded = 0;
    for (final GlobalKey key in pageKeys) {
      final RenderObject? renderObject = key.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) continue;

      final ui.Image image = await renderObject.toImage(pixelRatio: 3);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) continue;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginLeft: 0,
            marginRight: 0,
            marginBottom: 0,
            marginTop: 0,
          ),
          build: (pw.Context context) => pw.Container(
            width: double.infinity,
            height: double.infinity,
            color: PdfColor.fromInt(AppColors.card.toARGB32()),
            child: pw.Padding(
              padding: pw.EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: pw.Image(pw.MemoryImage(pngBytes)),
            ),
          ),
        ),
      );
      pagesAdded++;
    }

    if (pagesAdded == 0) return Left(S.current.pdfNoPages);

    final Uint8List bytes = await pdf.save();
    return await csvHelper.exportBytesForUser(
      fileName: fileName,
      extension: 'pdf',
      bytes: bytes,
    );
  }
}
