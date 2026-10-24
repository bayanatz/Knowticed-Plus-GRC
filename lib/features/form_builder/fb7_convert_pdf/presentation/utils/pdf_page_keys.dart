/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: pdf_page_keys.dart
/// Description: `PdfPageKeys`, the keys of the page boundaries a PDF is
///              captured from, and `preparePdfPages`. Kept in the UI layer
///              (provided next to PdfCubit), not in the cubit (Share rule 2).
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/controller/pdf_cubit.dart';

/// The keys of the page boundaries a PDF is captured from.
class PdfPageKeys {
  /// Makes every key unique across all holders and resets.
  static int _globalCounter = 0;

  List<GlobalKey> _keys = <GlobalKey>[];

  /// The current keys, one per page.
  List<GlobalKey> get keys => List<GlobalKey>.unmodifiable(_keys);

  /// Method Name: [reset]
  ///
  /// Purpose: fresh keys for [pagesLength] pages, so a screen opening while
  /// another one is still mounted never shares a key with it.
  ///
  /// Parameters:
  /// - [pagesLength]: the number of pages.
  void reset(int pagesLength) {
    final String uniqueId =
        '${_globalCounter++}_${DateTime.now().microsecondsSinceEpoch}';
    _keys = List<GlobalKey>.generate(
      pagesLength,
      (index) => GlobalKey(debugLabel: 'pdf_page_${uniqueId}_$index'),
    );
  }

  /// Method Name: [keyAt]
  ///
  /// Purpose: the key of page [index]; adds keys when the page count grew.
  ///
  /// Parameters:
  /// - [index]: the page.
  ///
  /// Returns: the key.
  GlobalKey keyAt(int index) {
    while (_keys.length <= index) {
      _keys.add(
        GlobalKey(debugLabel: 'pdf_page_${_globalCounter++}_${_keys.length}'),
      );
    }
    return _keys[index];
  }
}

/// Function Name: [preparePdfPages]
///
/// Purpose: fresh page keys and an open PdfCubit for [pagesLength] pages.
///
/// Parameters:
/// - [context]: a context under the PdfCubit and PdfPageKeys providers.
/// - [pagesLength]: the number of pages.
void preparePdfPages(BuildContext context, int pagesLength) {
  context.read<PdfPageKeys>().reset(pagesLength);
  context.read<PdfCubit>().initialize(pagesLength);
}
