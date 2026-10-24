/// Module: services / sv3_create_master_services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: master_upload_models.dart
/// Purpose: The data classes of the master upload (parse result, parse
///          failure, Step 2 validation texts). Moved out of the cubit file
///          (rule C13).
/// Author: Knowticed Team
/// Updated: 18/10/2026 by Amr Mesbah
/// Created At: 18/10/2026
library;

/// Result of parsing a step's Excel file.
class ParsedStepResult {
  /// The parsed rows as plain values (header → cell). The page wraps them in
  /// its own TextEditingControllers (rule "No text controllers in models").
  final List<Map<String, String>> formData;
  final List<Map<String, String>> validationErrors;
  final String fileName;

  const ParsedStepResult({
    required this.formData,
    required this.validationErrors,
    required this.fileName,
  });
}

/// What went wrong while parsing a step's file. The page turns it into a
/// translated sentence (Create R3: the cubit builds no user-facing text).
enum MasterUploadIssue { missingColumns, unreadableFile, noDataRows }

/// Thrown by [MasterUploadCubit] parse methods on a recoverable parse
/// failure (missing columns, unreadable file, empty file). [message] is the
/// English detail for logs only; the UI shows text chosen from [issue].
class MasterUploadFailure implements Exception {
  final String message;

  /// Which failure this is — the UI picks the translated text from it.
  final MasterUploadIssue issue;

  /// Expected-but-absent column headers. When non-empty the UI builds a
  /// localized message from these instead of showing [message] verbatim —
  /// the cubit has no BuildContext, so it cannot translate on its own.
  final List<String> missingColumns;

  const MasterUploadFailure(
    this.message, {
    required this.issue,
    this.missingColumns = const [],
  });

  @override
  String toString() => message;
}

/// The translated messages for [MasterUploadCubit.validateStep2Cell]. The
/// page fills them from `S.of(context)` so the cubit never needs a
/// BuildContext (Create R3: no hardcoded English defaults).
class Step2ValidationMessages {
  final String required;
  final String invalidEmailFormat;
  final String emailDoesNotExist;
  final String emailsCommaSeparated;
  final String commaAtStartOrEnd;
  final String emptyEmail;
  final String invalidState;
  final String invalidRequestedDate;

  const Step2ValidationMessages({
    required this.required,
    required this.invalidEmailFormat,
    required this.emailDoesNotExist,
    required this.emailsCommaSeparated,
    required this.commaAtStartOrEnd,
    required this.emptyEmail,
    required this.invalidState,
    required this.invalidRequestedDate,
  });
}
