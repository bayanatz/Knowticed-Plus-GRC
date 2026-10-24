/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: pdf_download_actions.dart
/// Description: `PdfDownloadActions`, the Download flow of a form PDF:
///              file-name dialog, confirm, capture, result. Moved out of
///              PdfCubit, which no longer takes a BuildContext.
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/controller/pdf_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/utils/pdf_page_keys.dart';
import 'package:knowticed_plus/features/form_builder/form_builder_get_it.dart';

/// The Download flow of a form PDF.
class PdfDownloadActions {
  const PdfDownloadActions._();

  /// Method Name: [download]
  ///
  /// Purpose: asks for the file name (pre-filled), confirms, captures the
  /// pages on screen and saves the PDF; the confirm dialog reports the
  /// result.
  ///
  /// Parameters:
  /// - [context]: a context under the PdfCubit and PdfPageKeys providers.
  /// - [model]: the form.
  /// - [fileName]: the page's file-name controller.
  static void download(
    BuildContext context,
    FormEntity model,
    TextEditingController fileName,
  ) {
    final PdfCubit cubit = context.read<PdfCubit>();
    final PdfPageKeys pageKeys = context.read<PdfPageKeys>();
    if (fileName.text.trim().isEmpty) fileName.text = cubit.fileNameFor(model);

    AppDialogs.downloadFile(fileName, context, () {
      // showInput already closed the file-name dialog before calling this.
      if (!context.mounted) return;
      cubit.setFileName(fileName.text);
      AppDialogs.confirmDownloadPdf(
        context,
        fileName: fileName.text,
        onConfirm: () async {
          if (cubit.expandAll()) await WidgetsBinding.instance.endOfFrame;
          final Either<String, String> result = await FormBuilderCubits
              .pdfExport
              .export(
                pageKeys: pageKeys.keys,
                fileName: fileName.text,
                horizontalPadding:
                    model.formHeadModel.horizontalPadding ?? 16.0,
                verticalPadding: model.formHeadModel.verticalPadding ?? 16.0,
              );
          // System Logs: only a PDF that was actually written.
          if (result.getOrElse(() => CSVHelper.exportCancelled) !=
              CSVHelper.exportCancelled) {
            cubit.pdfSaved();
          }
          return result;
        },
      );
    });
  }
}
