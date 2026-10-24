/// Module: roles/shared_mobile_export
///
///*************************** FILE INFO ****************************///
/// File Name: mobile_export_file_name_dialog.dart
/// Description: `MobileExportFileNameDialog` widget — split out of `mobile_export_widgets.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../mobile_export_widgets.dart';

// Split from mobile_export_widgets.dart to keep every file under 700 lines.

/// The "Export → File Name → Discard / Download" card both flows end on.
///
/// Figma 6975:24036 / 6976:24238: 340x192, white, radius 8, a
/// (-3, 4) blur-20 shadow at 2% black, a 30 primary disc holding the export
/// glyph, the word "Export" in Cairo Medium 16, a labelled 310-wide field and
/// the two 135x38 buttons.
///
/// REWORKED 10/9/2026 — "export page not work". It did nothing a user could
/// find, for the reason `CSVHelper.exportForUser` documents at length: the
/// phone flows wrote through `CSVHelper.exportToCSV`, which on Android throws
/// under scoped storage and on iOS succeeds into a folder no app can open. The
/// card then reported "Your CSV file has been saved" either way, because it was
/// told only true/false and false never arrived.
///
/// So this card now works the way `RoleExportDialog` does — the one export in
/// the module that has been through this bug twice and come out fixed:
///
///  * The field opens with a DEFAULT NAME ([defaultFileName]), so Download is
///    live on the first frame instead of waiting for the user to invent one.
///  * The card OWNS the export ([onExport]) instead of popping and letting the
///    caller run it. That is what lets it show the wait, keep itself open on
///    failure, and tell the three outcomes apart.
///  * The wait is drawn IN THE BUTTON ROW, held for at least
///    [_minimumProgressDuration]. A small export finishes inside one frame,
///    and a card that flickers and closes is indistinguishable from a card that
///    did nothing — which is how this keeps getting reported.
///  * A DISMISSED SAVE SHEET is neither success nor failure: nothing was
///    written and nothing broke, so the card just stays open for another try.
///  * Messages go through `CustomDialogManager` on the ROOT navigator, so they
///    stack above this card rather than under its own barrier.
class MobileExportFileNameDialog extends StatefulWidget {
  const MobileExportFileNameDialog({
    super.key,
    required this.defaultFileName,
    required this.onExport,
  });

  /// Prefills the field. Build it with [mobileExportDefaultFileName].
  final String defaultFileName;

  /// Writes the file. Left = an error message; Right = the saved path, or
  /// `CSVHelper.exportCancelled` when the user dismissed the save sheet.
  final Future<Either<String, String>> Function(String fileName) onExport;

  /// Opens the card. Resolves TRUE when a file was actually written — the
  /// caller pops its own page on true and does nothing otherwise.
  ///
  /// `useRootNavigator: true` matches `CustomDialogManager`: the roles module
  /// runs inside its own nested navigator, and a dialog pushed there would be
  /// clipped by the module frame instead of covering the screen.
  static Future<bool> show(
    BuildContext context, {
    required String defaultFileName,
    required Future<Either<String, String>> Function(String fileName) onExport,
  }) async {
    final bool? exported = await showAppDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (_) => MobileExportFileNameDialog(
        defaultFileName: defaultFileName,
        onExport: onExport,
      ),
    );
    return exported ?? false;
  }

  @override
  State<MobileExportFileNameDialog> createState() =>
      _MobileExportFileNameDialogState();
}
