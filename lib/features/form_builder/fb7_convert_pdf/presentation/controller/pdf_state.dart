/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: pdf_state.dart
/// Description: `PdfState` and its states: which pages are expanded and
///              the file name of the download.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Plain file name instead of a TextEditingController.
library;

import 'package:equatable/equatable.dart';

abstract class PdfState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PdfInitial extends PdfState {}

/// The PDF screen: which pages are expanded and the download file name.
class PdfLoaded extends PdfState {
  final List<bool> isExpanded;

  /// The file name of the last download ('' until one is typed).
  final String fileName;
  final int version;

  PdfLoaded({required this.isExpanded, this.fileName = '', this.version = 0});

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given values changed.
  ///
  /// Parameters:
  /// - [isExpanded]: the new value (null keeps the current one).
  /// - [fileName]: the new value (null keeps the current one).
  ///
  /// Returns: the copy.
  PdfLoaded copyWith({List<bool>? isExpanded, String? fileName}) {
    return PdfLoaded(
      isExpanded: isExpanded ?? this.isExpanded,
      fileName: fileName ?? this.fileName,
      version: version + 1,
    );
  }

  @override
  List<Object?> get props => [isExpanded, fileName, version];
}
