/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: request_comment_fields.dart
/// Purpose: Field keys of the comments saved on a request document (approve,
///          reject and cancel reasons), and the one reader of the cancel
///          reason.
///
///          The cancel reason used to be saved as `canselComment` (typo).
///          New cancellations write `cancelComment`; reads try the new key
///          first and fall back to the old one, so requests cancelled before
///          the rename still show their reason. Once old documents are
///          migrated (copy `canselComment` to `cancelComment`), the fallback
///          can be deleted.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

class RequestCommentFields {
  const RequestCommentFields._();

  static const String approveComment = 'approveComment';
  static const String rejectComment = 'rejectComment';
  static const String cancelComment = 'cancelComment';

  /// Field of a comment document that holds the request it belongs to.
  static const String requestId = 'Request_Id';

  /// The misspelled key older requests were saved with.
  static const String legacyCancelComment = 'canselComment';

  /// Function Name: [cancelReasonOf]
  ///
  /// Purpose: The cancel reason of a request document, from the new key or,
  /// for older documents, the misspelled one.
  ///
  /// Parameters:
  /// - [data]: the request document.
  ///
  /// Returns: the reason, or '' when there is none.
  static String cancelReasonOf(Map<String, dynamic> data) {
    final reason = data[cancelComment]?.toString() ?? '';
    if (reason.isNotEmpty) return reason;
    return data[legacyCancelComment]?.toString() ?? '';
  }

  /// The text of [key], or '' when it is missing.
  static String textOf(Map<String, dynamic> data, String key) =>
      data[key]?.toString() ?? '';
}
