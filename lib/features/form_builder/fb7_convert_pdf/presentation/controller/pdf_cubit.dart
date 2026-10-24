/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: pdf_cubit.dart
/// Description: `PdfCubit`, the PDF screen: which pages are expanded and
///              the download file name. The page capture lives in
///              `PdfExportService`, the page keys in `PdfPageKeys` and the
///              dialogs in `PdfDownloadActions`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Keys, controller, dialogs and page capture moved
///                       out of the cubit (Share rules 2 and 3).
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_log_service.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/controller/pdf_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The PDF screen: which pages are expanded and the download file name.
class PdfCubit extends Cubit<PdfState> {
  PdfCubit() : super(PdfInitial());

  /// Every emit is skipped once the cubit is closed (Share rule 4).
  @override
  void emit(PdfState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Method Name: [initialize]
  ///
  /// Purpose: opens [pagesLength] pages, all expanded.
  ///
  /// Parameters:
  /// - [pagesLength]: the number of pages.
  void initialize(int pagesLength) {
    emit(PdfLoaded(isExpanded: List<bool>.filled(pagesLength, true)));
  }

  /// Method Name: [toggleExpanded]
  ///
  /// Purpose: collapses or expands page [index].
  void toggleExpanded(int index) {
    if (state is! PdfLoaded) return;
    final currentState = state as PdfLoaded;
    final newIsExpanded = List<bool>.from(currentState.isExpanded);
    newIsExpanded[index] = !newIsExpanded[index];
    emit(currentState.copyWith(isExpanded: newIsExpanded));
  }

  /// Method Name: [expandAll]
  ///
  /// Purpose: FB-SHARE-05: collapsed pages are not built, so they cannot be
  /// captured; every page is expanded before a download.
  ///
  /// Returns: true when a page was collapsed (wait one frame before the
  /// capture).
  bool expandAll() {
    if (state is! PdfLoaded) return false;
    final PdfLoaded loaded = state as PdfLoaded;
    if (!loaded.isExpanded.contains(false)) return false;
    emit(
      loaded.copyWith(
        isExpanded: List<bool>.filled(loaded.isExpanded.length, true),
      ),
    );
    return true;
  }

  /// Method Name: [fileNameFor]
  ///
  /// Purpose: the file name the download dialog opens with: the last one
  /// typed, or `<form title> <day> <Mon> <year>`, so a single tap on
  /// Download is enough.
  ///
  /// Parameters:
  /// - [model]: the form.
  ///
  /// Returns: the file name.
  String fileNameFor(FormEntity model) {
    final PdfState current = state;
    if (current is PdfLoaded && current.fileName.trim().isNotEmpty) {
      return current.fileName;
    }
    final String title = model.formHeadModel.title.trim().isEmpty
        ? S.current.form
        : model.formHeadModel.title.trim();
    // Day, month and year from intl (e.g. "12 Oct 2026").
    return '$title ${DateFormat('d MMM y').format(DateTime.now())}';
  }

  /// Method Name: [setFileName]
  ///
  /// Purpose: keeps the file name typed for the next download.
  void setFileName(String fileName) {
    if (state is! PdfLoaded) return;
    emit((state as PdfLoaded).copyWith(fileName: fileName));
  }

  /// Method Name: [pdfSaved]
  ///
  /// Purpose: System Logs entry for a PDF that was actually written.
  void pdfSaved() {
    FormBuilderLogService.log(FormBuilderLogService.actionConvertToPdf);
  }
}
