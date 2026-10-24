/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: result_constants.dart
/// Description: `ResultConstants`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';

/// Stable ids of the Results filters, and their translated labels.
abstract class ResultConstants {
  // ── Uploaded media filters ────────────────────────────────────────────
  // Stable ids; the user reads the labels below (FB-RESULT-04: comparing
  // the shown, translated words broke the filters in Arabic).
  static const String mediaImages = 'images';
  static const String mediaAttachments = 'attachments';
  static const String mediaSignatures = 'eSignature';
  static const List<String> mediaTypeFilter = [
    mediaImages,
    mediaAttachments,
    mediaSignatures,
  ];

  /// The translated label of a media type id.
  static String mediaTypeLabel(String id) {
    switch (id) {
      case mediaImages:
        return S.current.fbMediaImages;
      case mediaAttachments:
        return S.current.attachments;
      case mediaSignatures:
        return S.current.fbMediaESignatures;
    }
    return id;
  }

  static const String employeesAll = 'all';
  static const String employeesCustom = 'custom';
  static const List<String> employeeFilter = [employeesAll, employeesCustom];

  /// The translated label of an employee filter id.
  static String employeeFilterLabel(String id) =>
      id == employeesAll ? S.current.all : S.current.custom;

  /// Dropdown value of the "All departments" item. The cubit stores null
  /// for it; departments are filtered by their ID, never by their name.
  static const String allDepartments = '';
}
